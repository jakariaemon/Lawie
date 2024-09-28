from fastapi import APIRouter, File, UploadFile, HTTPException, BackgroundTasks
from sqlalchemy.orm import sessionmaker
from app.models import UserTasks, ProgressStatus
from app.database import engine, Base
from app.logger import logger
from app.config import settings
import httpx
import csv
import json
from predibase import Predibase, FinetuningConfig
from datasets import Dataset, load_dataset
from sklearn.model_selection import train_test_split
from openai import OpenAI
import asyncio
import pandas as pd
from sqlalchemy.sql import func
from sqlalchemy import distinct
import traceback

router = APIRouter(prefix="/ml", tags=["ml"])

UPSTAGE_URL = "https://api.upstage.ai/v1/document-ai/document-parse"

timeout = httpx.Timeout(60.0) 

def create_tables(engine):
    Base.metadata.create_all(engine)


async def update_progress(user_id: int, task_id: int, status: str):
    Session = sessionmaker(bind=engine)
    with Session() as session:
        progress = (
            session.query(ProgressStatus)
            .filter_by(user_id=user_id, task_id=task_id)
            .first()
        )
        if progress:
            progress.status = status
        else:
            progress = ProgressStatus(user_id=user_id, task_id=task_id, status=status)
            session.add(progress)
        session.commit()


async def store_extracted_text(
    user_id,
    task_id,
    extracted_text,
    adapter_id,
    layout_text,
):
    Session = sessionmaker(bind=engine)
    with Session() as session:
        try:
            new_entry = UserTasks(
                user_id=user_id,
                task_id=task_id,
                extracted_text=extracted_text,
                adapter_id=str(f"{adapter_id}/1"),
                layout_text=layout_text,
            )
            session.add(new_entry)
            session.commit()

            logger.info("Data stored successfully!")
            await update_progress(user_id, task_id, "PDF_PROCESSED")
        except Exception as e:
            logger.error(f"Error storing data: {e}")
            await update_progress(user_id, task_id, "FAILED")
            raise HTTPException(status_code=500, detail="Failed to store data.")


async def update_qa_text(user_id, task_id, qa_text):
    Session = sessionmaker(bind=engine)
    with Session() as session:
        try:
            entry = (
                session.query(UserTasks)
                .filter_by(user_id=user_id, task_id=task_id)
                .first()
            )
            if entry:
                entry.qa_text = qa_text
                session.commit()
                logger.info("Q/A text updated successfully!")
                await update_progress(user_id, task_id, "QA_GENERATED")
            else:
                logger.warning("Entry not found!")
                await update_progress(user_id, task_id, "FAILED")
                raise HTTPException(status_code=404, detail="Entry not found.")
        except Exception as e:
            logger.error(f"Error updating Q/A text: {e}")
            await update_progress(user_id, task_id, "FAILED")
            raise HTTPException(status_code=500, detail="Failed to update Q/A text.")


async def hfdataset_to_csv(datalist: list, csv_file_name, max=-1):
    template = {
        "prompt": """<|im_start|>system\nYou are a law expert. Based on the given question, generate a single line answer concisely. Always answer in Japanese.  <|im_end|>
<|im_start|>Question\n {content}
<|im_start|>Answer\n""",
        "completion": "{headline}<|im_end|>",
        "split": "train",
    }

    with open(csv_file_name, "w", newline="", encoding="utf-8") as csvfile:
        fieldnames = template.keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for i, d in enumerate(datalist):
            if i >= max:
                break
            row = {
                "prompt": template["prompt"].format(content=d["Question"]),
                "completion": template["completion"].format(headline=d["Answer"]),
                "split": "train",
            }
            writer.writerow(row)


async def process_and_upload_dataset(
    pb,
    data_file: str,
    dataset_name: str,
    test_size: float = 0.1,
    random_state: int = 42,
):

    hfdataset = await asyncio.to_thread(load_dataset, "csv", data_files=data_file)
    train_hfdataset = hfdataset["train"]

    train_df = await asyncio.to_thread(train_hfdataset.to_pandas)

    train_split, test_split = await asyncio.to_thread(
        train_test_split, train_df, test_size=test_size, random_state=random_state
    )
    train_split.reset_index(drop=True, inplace=True)
    test_split.reset_index(drop=True, inplace=True)

    train_dataset = await asyncio.to_thread(Dataset.from_pandas, train_split)
    # test_dataset = await asyncio.to_thread(Dataset.from_pandas, test_split)

    csv_file_name = f"{dataset_name}.csv"

    print(csv_file_name)
    try:
        pb_dataset = pb.datasets.get(dataset_name)
        print(pb_dataset)
    except RuntimeError:
        print("not found")
        print(train_dataset)
        await hfdataset_to_csv(train_dataset, csv_file_name, max=1321)
        pb_dataset = pb.datasets.from_file(csv_file_name, name=dataset_name)
    return pb_dataset


async def train_adapter(
    csv_path,
    api_key,
    dataset_name,
    repo_name,
    user_id,
    task_id,
):
    try:
        await update_progress(user_id, task_id, "ADAPTER_TRAINING")
        pb = Predibase(api_token=api_key)

        dataset = await process_and_upload_dataset(pb, csv_path, dataset_name)

        repo = pb.repos.create(
            name=repo_name,
            description="Fine-tuning using modified dataset",
            exists_ok=True,
        )
        adapter = pb.finetuning.jobs.create(
            config=FinetuningConfig(
                base_model="solar-1-mini-chat-240612",
                epochs=3,
                rank=16,
            ),
            dataset=dataset,
            repo=repo,
            description="Personal AI assistant",
            watch=False,
        )

        # repo = pb.repos.create(
        #     name=repo_name,
        #     description="Fine-tuning using modified dataset",
        #     exists_ok=True,
        # )
        # adapter = pb.finetuning.jobs.create(
        #     config=FinetuningConfig(
        #         base_model="solar-1-mini-chat-240612",
        #         epochs=3,
        #         rank=16,
        #     ),
        #     dataset=dataset,
        #     repo=repo,
        #     description="Personal AI assistant",
        #     watch=False,
        # )
        await update_progress(user_id, task_id, "COMPLETED")
        return adapter
    except Exception as e:
        logger.error(f"Error training adapter: {e}")
        await update_progress(user_id, task_id, "FAILED")
        raise HTTPException(status_code=500, detail="Failed to train adapter.")


async def chat_with_upstage(api_key, text, user_id, task_id):
    try:
        prompt = (
            "Please generate at least 10 Q/A based on the provided information."
            "Please align the Q/A with the context. Do not include additional information."
            "QA format as follows:\nQuestion:\nAnswer:\nMust obey the format."
        )
        messages = [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": text + prompt},
        ]
        client = OpenAI(
            api_key=api_key,
            base_url="https://api.upstage.ai/v1/solar",
        )
        response = await asyncio.to_thread(
            client.chat.completions.create,
            model="solar-1-mini-chat",
            messages=messages,
            stream=True,
        )

        response_text = "".join(
            chunk.choices[0].delta.content
            for chunk in response
            if chunk.choices[0].delta.content is not None
        )
        #await update_qa_text(user_id, task_id, response_text)
        return response_text
    except Exception as e:
        logger.error(f"Error in Q/A generation: {e}")
        raise HTTPException(status_code=500, detail="Q/A generation failed.")


async def process_pdf_and_train_adapter(
    adapter_name: str,
    user_id: int,
    task_id: int,
    filename: str,
    file_contents: bytes,
):
    try:
        await update_progress(user_id, task_id, "STARTED")

        headers = {"Authorization": f"Bearer {settings.UPSTAGE_API_KEY}"}
        files = {"document": (filename, file_contents, "application/pdf")}
        data = {"output_formats": "['html', 'text']"}

        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(
                UPSTAGE_URL,
                headers=headers,
                files=files,
                data=data,
            )

        if response.status_code != 200:
            logger.error(
                f"Error processing document for user {user_id}, task {task_id}: {response.text}"
            )
            await update_progress(user_id, task_id, "FAILED")
            return

        layout_text = response.json()
        elements = layout_text.get("elements", []) 

        from collections import defaultdict 

        pages_dict = defaultdict(list)
        for element in elements:
            page_number = element.get("page", 0)
            content_text = element.get("content", {}).get("text", "")
            if content_text.strip():
                pages_dict[page_number].append(content_text) 

        extracted_texts = []
        for page_number in sorted(pages_dict.keys()):
            page_text = "\n".join(pages_dict[page_number])
            extracted_texts.append(page_text)

        # Log extracted texts
        logger.info(f"Extracted texts: {extracted_texts}")

        create_tables(engine)
        full_text = "\n".join(extracted_texts)
        await store_extracted_text(
            user_id, task_id, full_text, adapter_name, layout_text
        )
        qa_list = []
        for page_text in extracted_texts:
            qa = await chat_with_upstage(
                settings.UPSTAGE_API_KEY, page_text, user_id, task_id 
            )
            qa_list.append(qa)
        qa_combined = "\n".join(qa_list) 
        await update_qa_text(user_id, task_id, qa_combined) 
        csv_data = []
        for qa in qa_list:
            for entry in qa.split("Question: "):
                if entry.strip():
                    q_and_a = entry.split("Answer: ")
                    if len(q_and_a) == 2:
                        q, a = q_and_a
                        csv_data.append([q.strip(), a.strip()])

        csv_path = f"questions_answers_{user_id}_{task_id}.csv"
        dataset_name = f"dataset_{user_id}_{task_id}"
        repo_name = adapter_name

        with open(csv_path, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["Question", "Answer"])
            writer.writerows(csv_data)

        await train_adapter(
            csv_path=csv_path,
            api_key=settings.API_TOKEN_PREDIBASE_1,
            dataset_name=dataset_name,
            repo_name=repo_name,
            user_id=user_id,
            task_id=task_id,
        )
        logger.info(f"Model training completed for user {user_id}, task {task_id}.")
    except Exception as e:
        error_message = f"Error in background task for user {user_id}, task {task_id}: {e}\n{traceback.format_exc()}"
        logger.error(error_message)
        await update_progress(user_id, task_id, "FAILED")


@router.post("/upload/")
async def upload_pdf(
    adapter_name: str,
    user_id: int,
    file: UploadFile = File(...),
    background_tasks: BackgroundTasks = BackgroundTasks(),
):
    if file.content_type != "application/pdf":
        raise HTTPException(status_code=400, detail="File must be a PDF")

    try:
        file_contents = await file.read()
        logger.info(f"file upload complete")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read file: {str(e)}")

    Session = sessionmaker(bind=engine)
    with Session() as session:
        max_task_id = (
            session.query(func.max(UserTasks.task_id))
            .filter_by(user_id=user_id)
            .scalar()
        )
        new_task_id = (max_task_id or 0) + 1

    background_tasks.add_task(
        process_pdf_and_train_adapter,
        adapter_name,
        user_id,
        new_task_id,
        file.filename,
        file_contents,
    )

    return {
        "message": "Your personal AI is being prepared. We will notify you the status of your personal AI.",
        "task_id": new_task_id,
    }


@router.post("/adapter_list/")
async def adapter_list(user_id: int, task_id: int = None):
    Session = sessionmaker(bind=engine)
    session = Session()
    try:
        adapter_entries = (
            session.query(UserTasks.adapter_id, UserTasks.id)
            .filter(UserTasks.user_id == user_id)
            .all()
        )

        if not adapter_entries:
            raise HTTPException(
                status_code=404, detail="No adapters found for the given user."
            )

        adapter_list = []

        for entry in adapter_entries:
            user_tasks_id = entry.id
            adapter_id = entry.adapter_id
            adapter_list.append({"name": adapter_id, "id": user_tasks_id})

        return {"adapters": adapter_list}
    except Exception as e:
        logger.error(f"Error fetching adapter list for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch adapter names.")
    finally:
        session.close()


@router.post("/history/")
async def get_history(user_id: int, task_id: int):
    Session = sessionmaker(bind=engine)
    session = Session()
    try:
        entry = (
            session.query(
                UserTasks.id,
                UserTasks.adapter_id,
                UserTasks.user_id,
                UserTasks.task_id,
                UserTasks.extracted_text,
                UserTasks.qa_text,
            )
            .filter_by(user_id=user_id, task_id=task_id)
            .first()
        )
        if not entry:
            raise HTTPException(
                status_code=404, detail="History not found for the given user and task."
            )
        return {
            "id": entry.id,
            "adapter_id": entry.adapter_id,
            "user_id": entry.user_id,
            "task_id": entry.task_id,
            "extracted_text": entry.extracted_text,
            "qa_text": entry.qa_text,
        }
    except Exception as e:
        logger.error(f"Error fetching history for user {user_id}, task {task_id}: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch history.")
    finally:
        session.close()


@router.get("/progress/{user_id}/{task_id}")
async def get_progress(user_id: int, task_id: int):
    Session = sessionmaker(bind=engine)

    with Session() as session:
        progress = (
            session.query(ProgressStatus)
            .filter_by(user_id=user_id, task_id=task_id)
            .first()
        )

        if progress:
            return {"status": progress.status, "updated_at": progress.updated_at}
        else:
            raise HTTPException(status_code=404, detail="Progress not found")
