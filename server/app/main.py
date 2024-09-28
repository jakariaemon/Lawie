import logging
import os

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from typing import List, Optional
from pydantic import EmailStr, Field
from predibase import Predibase
from google.cloud import bigquery
from fastapi.middleware.cors import CORSMiddleware
from google.oauth2 import service_account
from google.cloud import bigquery


from . import models, schemas, utils, email_utils
from .database import SessionLocal, engine
from .config import settings
from .logger import logger

from .routers import ml, progress

# Initialize credentials
try:
    creds = service_account.Credentials.from_service_account_file(
        settings.SERVICE_ACCOUNT_FILE,
        scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )

except Exception as e:
    raise Exception(f"Failed to initialize credentials: {str(e)}")


models.Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(title="lawie", version="0.0.1")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ml.router)
app.include_router(progress.router)

# Initialize Predibase client
API_TOKEN_PREDIBASE_1 = settings.API_TOKEN_PREDIBASE_1
pb = Predibase(api_token=API_TOKEN_PREDIBASE_1)

# Initialize BigQuery client
BQ_DATASET = "chat_data"
BQ_TABLE = "chat_history"
bq_client = bigquery.Client(credentials=creds, project=creds.project_id)


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def authenticate_user(db: Session, email: str, password: str):
    user = db.query(models.User).filter(models.User.email == email).first()
    if not user or not utils.verify_password(password, user.hashed_password):
        return False
    return user


async def get_current_user(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )

        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception

        token_data = schemas.TokenData(email=email)
    except JWTError:
        raise credentials_exception

    user = db.query(models.User).filter(models.User.email == token_data.email).first()
    if user is None:
        raise credentials_exception

    return user


@app.post("/signup", response_model=schemas.User)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    if user.password != user.repeat_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    hashed_password = utils.get_password_hash(user.password)

    db_user = models.User(
        name=user.name,
        email=user.email,
        hashed_password=hashed_password,
        device_id=user.device_id,
        device_type=user.device_type,
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@app.post("/login", response_model=schemas.Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)
):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = utils.create_access_token(data={"sub": user.email})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "name": user.name,
            "subscription_type": user.subscription_type,
            "is_subscribed": user.is_subscribed,
            "email": user.email,
            "device_id": user.device_id,
            "id": user.id,
        },
    }


@app.get("/users/me", response_model=schemas.User)
async def read_users_me(current_user: schemas.User = Depends(get_current_user)):
    return current_user


@app.post("/update_subscription", response_model=schemas.Message)
async def update_subscription(
    is_subscribed: bool,
    subscription_type: str,
    device_id: str,
    current_user: schemas.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    current_user.is_subscribed = is_subscribed
    current_user.subscription_type = subscription_type
    current_user.device_id = device_id

    db.commit()
    return {"message": "Subscription status updated"}


@app.post("/forgot-password", response_model=schemas.Message)
async def forgot_password(email: schemas.EmailStr, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    token = utils.create_password_reset_token(email)
    email_utils.send_password_reset_email(email, token)
    return {"message": "Password reset email sent"}


@app.post("/reset-password", response_model=schemas.Message)
async def reset_password(
    reset_data: schemas.PasswordReset, db: Session = Depends(get_db)
):
    email = utils.verify_password_reset_token(reset_data.token)
    if not email:
        raise HTTPException(status_code=400, detail="Invalid or expired token")

    user = db.query(models.User).filter(models.User.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.hashed_password = utils.get_password_hash(reset_data.new_password)

    db.commit()

    return {"message": "Password updated successfully"}


@app.delete("/delete-account", response_model=schemas.Message)
async def delete_account(
    current_user: schemas.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        db.delete(current_user)
        db.commit()
        return {"message": "Account deleted successfully"}
    except Exception as e:
        logger.error(f"Failed to delete account for user {current_user.id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to delete account")


async def generate_response(input_prompt: str, adapter_id: str, user_id: str) -> str:
    try:
        lorax_client = pb.deployments.client("solar-1-mini-chat-240612")
        logger.debug(
            f"Starting response generation for user {user_id} with adapter {adapter_id}"
        )
        result = lorax_client.generate(
            input_prompt, adapter_id=adapter_id, max_new_tokens=100
        )
        temp = result.generated_text
        logger.debug(f"Successfully generated response for user {temp}")
        return result.generated_text
    except Exception as e:
        logger.error(f"Unexpected error during generation for user {user_id}: {str(e)}")
        raise


async def log_chat_to_bigquery(
    user_id: str,
    conversation_id: str,
    request_id: str,
    device_id: str,
    subscription: bool,
    message: str,
    response: str,
):
    row_to_insert = [
        {
            "user_id": user_id,
            "conversation_id": conversation_id,
            "request_id": request_id,
            "device_id": device_id,
            "subscription": subscription,
            "message": message,
            "response": response,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    ]
    table_ref = bq_client.dataset(BQ_DATASET).table(BQ_TABLE)
    errors = bq_client.insert_rows_json(table_ref, row_to_insert)

    if errors:
        logger.error(f"Error inserting rows to BigQuery: {errors}")
        raise HTTPException(status_code=500, detail="Failed to log chat to BigQuery")


@app.post("/chat/", response_model=schemas.ChatResponse)
async def chat(request: schemas.ChatRequest, db: Session = Depends(get_db)):
    try:
        logger.debug(
            f"Received chat request from user {request.user_id} with message: {request.message}"
        )

        input_prompt = f"""
        <|im_start|>system
        You are a law expert. Based on the given question, generate a single line answer concisely. <|im_end|>
        <|im_start|>Question
        {request.message}
        <|im_start|>Answer
        """

        response_text = await generate_response(
            input_prompt=input_prompt,
            adapter_id=request.adapter_id,
            user_id=request.user_id,
        )

        logger.debug(f"Generated response for user {request.user_id}: {response_text}")

        await log_chat_to_bigquery(
            user_id=request.user_id,
            conversation_id=request.conversation_id,
            request_id=request.request_id,
            device_id=request.device_id,
            subscription=request.subscription,
            message=request.message,
            response=response_text,
        )

        return schemas.ChatResponse(response=response_text)

    except Exception as e:
        logger.error(f"Unexpected error occurred for user {request.user_id}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="An unexpected error occurred. Please try again later.",
        )


@app.get("/chat/history", response_model=List[schemas.ChatHistoryResponse])
async def get_chat_history(
    user_id: str,
    conversation_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db),
):
    try:
        logger.debug(f"Fetching chat history for user {user_id}")

        query = f"""
            SELECT *
            FROM `{BQ_DATASET}.{BQ_TABLE}`
            WHERE user_id = @user_id
        """
        query_params = [bigquery.ScalarQueryParameter("user_id", "STRING", user_id)]

        if conversation_id:
            query += " AND conversation_id = @conversation_id"
            query_params.append(
                bigquery.ScalarQueryParameter(
                    "conversation_id", "STRING", conversation_id
                )
            )

        if start_date:
            query += " AND timestamp >= @start_date"
            query_params.append(
                bigquery.ScalarQueryParameter("start_date", "TIMESTAMP", start_date)
            )

        if end_date:
            query += " AND timestamp <= @end_date"
            query_params.append(
                bigquery.ScalarQueryParameter("end_date", "TIMESTAMP", end_date)
            )

        job_config = bigquery.QueryJobConfig(query_parameters=query_params)

        query_job = bq_client.query(query, job_config=job_config)
        results = query_job.result()

        history = [
            schemas.ChatHistoryResponse(
                user_id=row.user_id,
                conversation_id=row.conversation_id,
                request_id=row.request_id,
                device_id=row.device_id,
                subscription=row.subscription,
                message=row.message,
                response=row.response,
                timestamp=row.timestamp,
            )
            for row in results
        ]

        return history

    except Exception as e:
        logger.error(f"Failed to fetch chat history for user {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch chat history")


@app.post("/contact-us", response_model=schemas.Message)
async def contact_us(contact: schemas.ContactRequest):
    try:
        admin_email = (
            settings.ADMIN_EMAIL
        )  # Add this to your Settings class in config.py
        subject = "New Contact Form Submission"
        body = f"""
        <html>
            <body>
                <h2>New Contact Form Submission</h2>
                <p><strong>From:</strong> {contact.email}</p>
                <p><strong>Message:</strong></p>
                <p>{contact.message}</p>
            </body>
        </html>
        """
        email_utils.send_email(admin_email, subject, body)
        return {"message": "Your message has been sent successfully."}
    except Exception as e:
        logger.error(f"Failed to send contact form: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Failed to send your message. Please try again later.",
        )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
