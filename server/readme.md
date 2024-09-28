
# Running the Backend Service with Docker

## Prerequisites

- Ensure Docker and Docker Compose are installed on your system.
- The configuration file (`lawieserviceacc.json`) with necessary data.

## Steps to Run

1. **Place the Configuration File**

   Ensure that the `lawieserviceacc.json` file is in the root of your project directory. This file is required for the service to function properly.

2. **Run the Service with Docker**

   Use the following command to build and start the service using Docker Compose:

   ```bash
   docker-compose up --build
   ``` 
   This command will build the Docker image and start the server.

3. **Server Initialization** 

  Once the server starts, you should see the following log message indicating that the server is running:
  ```bash
    INFO:     Uvicorn running on http://0.0.0.0:8000
  ``` 
  This message confirms that the server has been successfully initiated and is running on port 8000.


# API Documentation

This documentation provides a comprehensive guide to the available endpoints and their functionalities. 

## Table of Contents

- [Getting Started](#getting-started)
- [Authentication](#authentication)
- [API Endpoints](#api-endpoints)
  - [Train](#train)
  - [User Management](#user-management)
  - [Subscription](#subscription)
  - [Chat](#chat)
  - [Progress Tracking](#progress-tracking)
  - [Support](#support)
- [Error Handling](#error-handling)

## Getting Started

To interact with the API, you must first obtain an access token. This token is necessary for authenticating your requests. You can get this token by logging in with valid credentials via the `/login` endpoint. Once authenticated, you can access various endpoints provided by the API, which follow standard RESTful principles and return JSON-formatted responses. 

<img width="1117" alt="image" src="https://github.com/user-attachments/assets/5bdfa855-46d3-4296-aed4-d57f2445a944">


## Authentication

The Lawie API uses OAuth 2.0 Bearer Token authentication. To authenticate, follow these steps:

1. **Login**: Obtain an access token by sending your credentials to the `/login` endpoint. 
2. **Include Token**: Use the obtained token in the `Authorization` header for all your API requests as shown below:

   ```http
   Authorization: Bearer <token>
   
Make sure to replace <token> with the actual token you received. This token will allow you to securely access the API endpoints and perform the necessary actions within your account

## Train

| **Endpoint**                     | **Method** | **Description**                                      | **Parameters**                                                                          | **Request body**        | **JSON Body**                                    | **Responses**                             |
|----------------------------------|------------|------------------------------------------------------|------------------------------------------------------------------------------------------|-------------------------|-------------------------------------------------|-------------------------------------------|
| `/ml/upload/`                    | `POST`     | Upload a PDF file to the machine learning adapter.   | `adapter_name` (query, string, required), `user_id` (query, integer, required)            | `file` (string(binary), required)      |  `<string>`           | `200`: Successful upload, `422`: Validation error. |
| `/ml/adapter_list/`              | `POST`     | Retrieve a list of adapters available for the user.  | `user_id` (query, integer, required), `task_id` (query, integer, optional)                 | None     | `{"adapters":[{"name":<string>}, {"id": <integer>}]}` | `200`: Successful response, `422`: Validation error. |
| `/ml/history/`                   | `POST`     | Fetch the history of machine learning tasks.         | `user_id` (query, integer, required), `task_id` (query, integer, required)                 | None   | `{"id":<integer>, "adapter_id": <string>, "user_id": <integer>, "task_id": <integer>, "extracted_text": <string>, "qa_text": <string> }`                                            | `200`: Successful response, `422`: Validation error. |


## User Management

| **Endpoint**          | **Method** | **Description**                    | **Parameters**      |   **Request body**    | **JSON Body**                                         | **Responses**                             |
|-----------------------|------------|------------------------------------|---------------------|----------------------|--------------------------------------------------------|-------------------------------------------|
| `/signup`             | `POST`     | Register a new user account.       | None                 | `{ "name": <string>, "email": <string>, "password": <string>, "repeat_password": <string>, "device_id": <string>, "device_type": <string>, required }` | `{ "name": <string>, "email": <string>, "password": <string>, "repeat_password": <string>, "device_id": <string>, "device_type": <string> }` | `200`: Successful signup, `422`: Validation error. |
| `/login`              | `POST`     | Login and obtain an access token.  | None                  | `username` (string, required), `password` (string, required), `grant_type` (string, default), `scope` (string, default), `client_id` (string, default), `client_secret` (string, default) | `{"access_token": <string>, "token_type": <string>, "user": {"name": <string>, "subscription_type": <string>, "is_subscribed": bool, "email": <string>, "device_id": <string>, "id": integer}}`       | `200`: Successful login, `422`: Validation error. |
| `/users/me`           | `GET`      | Retrieve details of the logged-in user. | None               | None                   | `{"name": <string>, "email": <string>, "id": <integer>, "is_subscribed": bool, "subscription_type": <string>}`                                                   | `200`: Successful response.                |
| `/forgot-password`     | `POST`   | Recover the password for intendent user's account. | `email` (query, string, required)   | None                               | `{"message": <string>}`                                                   | `200`: Successful response, `422`: Validation error.                    |
| `/reset-password`     | `POST`   | Reset the password for the logged-in user's account. | None                                  | `{"message": <string>}`                                                   | `200`: Successful response, `422`: Validation error.                    |
| `/delete-account`     | `DELETE`   | Delete the logged-in user's account. | None                 | None                 | `{"message": <string>}`                                                   | `200`: Account deleted.                    |

## Subscription

| **Endpoint**            | **Method** | **Description**                        | **Parameters**                                                                                  | **JSON Body** | **Responses**                             |
|-------------------------|------------|----------------------------------------|-------------------------------------------------------------------------------------------------|---------------|-------------------------------------------|
| `/update_subscription`  | `POST`     | Update the user's subscription status. | `is_subscribed` (query, boolean, required), `subscription_type` (query, string, required), `device_id` (query, string, required) | None          | `200`: Successful update, `422`: Validation error. |

## Chat

| **Endpoint**        | **Method** | **Description**                 | **Parameters**      |   **Request body**       | **JSON Body**                                                 | **Responses**                             |
|---------------------|------------|---------------------------------|---------------------|--------------------------|---------------------------------------------------------------|-------------------------------------------|
| `/chat/`            | `POST`     | Initiate a chat session.        | None          | `{ "user_id": <string>, "conversation_id": <string>, "request_id": <string>, "device_id": <string>, "subscription": bool, "message": <string>, "adapter_id": <string> }` | `{ "user_id": <string>, "conversation_id": <string>, "request_id": <string>, "device_id": <string>, "subscription": <boolean>, "message": <string>, "adapter_id": <string> }` | `200`: Chat response, `422`: Validation error. |
| `/chat/history`     | `GET`      | Retrieve chat history.          | None        |`user_id` (query, string, required), `conversation_id` (query, string, optional), `start_date` (query, string, optional), `end_date` (query, string, optional) | None | `[{"user_id": <string>, "conversation_id": <string>, "request_id": <string>, "device_id": <string>, "subscription": bool, "message": <string>, "response": <string>, "timestamp": <string>}]` | `200`: Successful response, `422`: Validation error. |

### `/chat/` Request Body Schema

- **Content-Type**: `application/json`

| **Field**          | **Type**    | **Required** | **Description**            |
|--------------------|-------------|--------------|----------------------------|
| `user_id`          | `string`    | Yes          | User ID                    |
| `conversation_id`  | `string`    | Yes          | Conversation ID            |
| `request_id`       | `string`    | Yes          | Request ID                 |
| `device_id`        | `string`    | Yes          | Device ID                  |
| `subscription`     | `boolean`   | Yes          | Indicates subscription status |
| `message`          | `string`    | Yes          | Message                    |
| `adapter_id`       | `string`    | Yes          | Adapter ID                 |

## Progress Tracking

| **Endpoint**                   | **Method** | **Description**                   | **Parameters**                                   | **JSON Body** | **Responses**                             |
|--------------------------------|------------|-----------------------------------|-------------------------------------------------|---------------|-------------------------------------------|
| `/progress/{user_id}/{task_id}` | `GET`      | Get progress of a specific task.  | `user_id` (path, integer, required), `task_id` (path, integer, required) | None          | `200`: Successful response, `422`: Validation error. |

## Support

| **Endpoint**         | **Method** | **Description**           | **Parameters**                | **JSON Body**                                      | **Responses**                             |
|----------------------|------------|---------------------------|-------------------------------|---------------------------------------------------|-------------------------------------------|
| `/contact-us`        | `POST`     | Contact support.          | None                          | `{ "email": <string>, "message": <string> }`       | `200`: Successful contact, `422`: Validation error. |


