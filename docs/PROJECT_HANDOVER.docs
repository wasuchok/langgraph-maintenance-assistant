# Project Handover

- Project: `Django Local Chatbot / MT RAG Assistant`
- Updated from source review: `2026-04-20`

## 1. Overview

โปรเจกต์นี้เป็นระบบ AI Assistant ภายในองค์กรที่ใช้แนวทาง RAG (Retrieval-Augmented Generation)  
stack หลักคือ `Django + Chainlit + Ollama + ChromaDB` และมีการเชื่อม `SQL Server`

ความสามารถหลัก:

- มีหน้าแชตผ่าน `Chainlit`
- มี `REST API` สำหรับเรียกจากระบบภายนอก
- ใช้ข้อมูลใน knowledge base เป็นหลักก่อนตอบ
- รองรับการ import ข้อมูลจาก `SQL Server` เข้า knowledge base
- รองรับการ import ไฟล์ `xlsx` กลุ่ม `History-*` แบบ `1 row = 1 document`
- เก็บ `chat history`, `feedback`, และ `checkpoint` การ sync
- รองรับคำตอบภาษาไทย อังกฤษ และญี่ปุ่น

แนวคิดการทำงาน:

- ถ้ามีข้อมูลใน knowledge base ระบบจะพยายามตอบจากข้อมูลนั้นก่อน
- ถ้าคำถามเป็นเชิง follow-up เช่น `แล้ว...` หรือ `กรณีนี้...` ระบบจะใช้ประวัติข้อความก่อนหน้ามาช่วยตีความ
- มีโหมด analytics สำหรับคำถามแนว `เกิดกี่ครั้ง`, `บ่อยไหม`, `ต่อเดือน`, `ต่อปี`
- orchestration ปัจจุบันใช้ `LangGraph` เป็นค่าเริ่มต้น

## 2. Tech Stack

- Python
- Django 6
- Django REST Framework
- Chainlit
- LangChain / LangGraph
- Ollama
- ChromaDB
- SQLite
- SQL Server ผ่าน `python-tds` หรือ `pyodbc`

แพ็กเกจที่ pin ไว้ใน `requirements.txt`

- `Django==6.0.3`
- `djangorestframework==3.16.1`
- `requests==2.32.5`
- `chromadb==1.5.5`
- `python-dotenv==1.2.2`
- `chainlit==2.10.1`
- `pypdf==6.1.3`
- `openpyxl==3.1.5`
- `pyodbc==5.2.0`
- `python-tds==1.17.1`
- `langchain-core==1.2.27`
- `langchain-ollama==1.1.0`
- `langgraph==1.1.6`

## 3. Important Files And Folders

Entry points / config:

- `manage.py`
- `config/settings.py`
- `config/urls.py`
- `config/asgi.py`
- `chainlit_app.py`
- `run_api.sh`
- `run_chainlit.sh`

โฟลเดอร์หลัก:

- `chatbot/`
- `config/`
- `public/`
- `chroma_data/`

ไฟล์ข้อมูลสำคัญในเครื่องปัจจุบัน:

- `.env` = ค่า config runtime จริงของเครื่องนี้
- `db.sqlite3` = ฐานข้อมูลหลักของ Django/SQLite
- `chroma_data/` = vector store ของ Chroma
- `.chainlit/` = ข้อมูล/setting บางส่วนของ Chainlit

หมายเหตุ:

- ถ้าจะย้ายเครื่องหรือส่งมอบจริง ควรสำรองอย่างน้อย `.env`, `db.sqlite3` และ `chroma_data/`

## 4. System Architecture

### 4.1 Chat UI

- `chainlit_app.py` คือ UI หลักของ Chainlit
- login ใช้บัญชี Django
- user ทั่วไปใช้งานถามตอบจาก shared knowledge ได้
- admin สามารถจัดการเอกสาร shared, import/sync SQL Server, import xlsx, ดู dashboard และ feedback ได้

### 4.2 API Layer

- `config/urls.py` map `/api/` ไปที่ `chatbot.urls`
- `chatbot/views.py` คือ REST endpoints หลัก

### 4.3 Chat Orchestration

- `chatbot/services/chat_service.py`
  ทำหน้าที่เรียก generate/stream reply และบันทึกข้อความลงฐานข้อมูล

- `chatbot/services/ollama_service.py`
  เป็นชั้น logic หลักเรื่อง prompt, language detection, follow-up handling, analytics detection, knowledge grounding, fallback และการเรียกโมเดล

- `chatbot/services/langgraph_chat_service.py`
  เป็น orchestration ใหม่ด้วย LangGraph  
  flow โดยรวมคือ `prepare -> route -> analytics / missing_knowledge / llm_generate`

### 4.4 RAG Layer

- `chatbot/services/rag_service.py`

หน้าที่หลัก:

- chunk เอกสาร
- embed ด้วย Ollama embedding model
- index เข้า Chroma
- search จาก Chroma ตาม document ที่ user มีสิทธิ์เข้าถึง

### 4.5 SQL Server Integration

- `chatbot/services/sqlserver_service.py`
  connection layer สำหรับ `pytds / pyodbc`

- `chatbot/services/sqlserver_case_ingestion_service.py`
  import ข้อมูลจากตาราง `TB_MT_JOB_DETAIL` เข้า `KnowledgeDocument`

- `chatbot/services/sqlserver_job_card_ingestion_service.py`
  import ข้อมูลจาก view `v_MT_JOB_CARD` เข้า `KnowledgeDocument`

- `chatbot/services/sqlserver_job_card_sync_service.py`
  sync แบบ checkpoint โดยใช้ฟิลด์ `J_CREATE_DATE`

### 4.6 File Ingestion

- `chatbot/services/knowledge_ingestion_service.py`
  รองรับ `txt`, `md`, `csv`, `json`, `log`, `html`, `xml`, `yaml`, `pdf`, `xlsx`

- `chatbot/services/xlsx_history_ingestion_service.py`
  ใช้สำหรับไฟล์ประวัติซ่อมกลุ่ม `History-*` โดยแยก `1 row = 1 document`

## 5. Main Database Models

อยู่ใน `chatbot/models.py`

- `ConversationThread`
  เก็บข้อมูลห้องสนทนา

- `ChatMessage`
  เก็บข้อความ `user / assistant` แยกตาม `conversation_id`

- `ChatMessageFeedback`
  เก็บ feedback ของคำตอบ เช่น `correct / incorrect`

- `KnowledgeDocument`
  เก็บเอกสารฐานความรู้

field สำคัญ:

- `title`
- `content`
- `source`
- `visibility = private/shared`
- `owner`

- `SyncCheckpoint`
  เก็บ checkpoint ของการ sync SQL Server

## 6. Runbook

### 6.1 Create Virtualenv

แนะนำใช้ `Python 3.12` เพราะใน `run_chainlit.sh` มี note ว่า Chainlit ในโปรเจกต์นี้มีปัญหาบน `Python 3.14`

```bash
/opt/homebrew/bin/python3.12 -m venv .venv312
.venv312/bin/python -m pip install -r requirements.txt
```

### 6.2 Migrate

```bash
.venv312/bin/python manage.py migrate
```

### 6.3 Create Admin User

```bash
.venv312/bin/python manage.py createsuperuser
```

### 6.4 Pull Ollama Models

```bash
ollama pull qwen3:14b
ollama pull nomic-embed-text-v2-moe
```

### 6.5 Start Ollama

```bash
ollama serve
```

### 6.6 Run Django API

```bash
./run_api.sh
```

ค่า default:

- host = `0.0.0.0`
- port = `8000`

ตัวเลือกเสริม:

```bash
RELOAD=true ./run_api.sh
PORT=8001 ./run_api.sh
```

### 6.7 Run Chainlit

```bash
./run_chainlit.sh
```

ค่า default:

- host = `0.0.0.0`
- port = `8100`

## 7. Important Environment Variables

ไฟล์จริงอยู่ที่ `.env` ใน root โปรเจกต์

กลุ่ม Ollama / chat:

- `OLLAMA_BASE_URL`
- `OLLAMA_CHAT_URL`
- `OLLAMA_EMBED_URL`
- `OLLAMA_MODEL`
- `AI_ORCHESTRATOR`
- `OLLAMA_THINK`
- `OLLAMA_KEEP_ALIVE`
- `OLLAMA_NUM_PREDICT`
- `OLLAMA_EMBED_MODEL`
- `OLLAMA_TEMPERATURE`

กลุ่ม RAG:

- `RAG_ONLY_MODE`
- `RAG_INCLUDE_CHAT_HISTORY`
- `RAG_SEARCH_TOP_K`

กลุ่ม SQL Server:

- `SQLSERVER_HOST`
- `SQLSERVER_PORT`
- `SQLSERVER_DATABASE`
- `SQLSERVER_USERNAME`
- `SQLSERVER_PASSWORD`
- `SQLSERVER_DRIVER`
- `SQLSERVER_CLIENT`
- `SQLSERVER_ENCRYPT`
- `SQLSERVER_TRUST_SERVER_CERTIFICATE`
- `SQLSERVER_TRUSTED_CONNECTION`
- `SQLSERVER_CONNECTION_TIMEOUT`
- `SQLSERVER_CASES_SCHEMA`
- `SQLSERVER_CASES_TABLE`
- `SQLSERVER_JOB_CARD_SCHEMA`
- `SQLSERVER_JOB_CARD_VIEW`
- `SQLSERVER_JOB_CARD_SYNC_OVERLAP_MINUTES`

กลุ่ม import / access control:

- `IMPORT_API_KEY`

กลุ่ม health check:

- `SYSTEM_HEALTH_OLLAMA_TIMEOUT_SECONDS`
- `SYSTEM_HEALTH_CHECKPOINT_STALE_MINUTES`
- `SYSTEM_HEALTH_CHECKPOINT_RUNNING_STALE_MINUTES`

กลุ่ม CORS:

- `CORS_ALLOW_ALL_ORIGINS`
- `CORS_ALLOWED_ORIGINS`
- `CORS_ALLOW_CREDENTIALS`
- `CORS_ALLOW_METHODS`
- `CORS_ALLOW_HEADERS`
- `CORS_EXPOSE_HEADERS`
- `CORS_PREFLIGHT_MAX_AGE`

หมายเหตุ:

- ค่า default หลายตัวถูกกำหนดใน `config/settings.py`
- ถ้าจะขึ้น production ควรทำ `.env.example` แยกไว้ให้ชัดเจน

## 8. Main API Endpoints

Base path:

- `/api/`

Endpoints สำคัญ:

- `GET /api/health/`
  health check แบบง่าย

- `GET /api/system-health/`
  รายงานสุขภาพระบบ เช่น Ollama, SQL Server, checkpoint  
  สิทธิ์: admin หรือมี `X-API-Key` ที่ตรงกับ `IMPORT_API_KEY`

- `POST /api/chat/`
  รับ `conversation_id + message` แล้วตอบกลับพร้อมบันทึกประวัติ

- `GET /api/chat/<conversation_id>/history/`
  ดูประวัติข้อความในห้อง

- `GET /api/knowledge/`
  list knowledge ตามสิทธิ์ที่ user เห็นได้

- `POST /api/knowledge/`
  เพิ่ม knowledge ใหม่  
  สิทธิ์: admin

- `GET/PUT/DELETE /api/knowledge/<document_id>/`
  ดู/แก้ไข/ลบ knowledge  
  `PUT/DELETE` ใช้ admin

- `GET /api/feedback/summary/`
  ดู summary feedback ล่าสุด  
  สิทธิ์: admin

- `POST /api/knowledge/import/mt-job-cards/`
  import job cards เข้า knowledge base  
  สิทธิ์: admin หรือมี `X-API-Key`

- `POST /api/knowledge/sync/mt-job-cards/`
  sync job cards แบบ checkpoint  
  สิทธิ์: admin หรือมี `X-API-Key`

- `POST /api/analytics/mt-job-cards/problem-stats/`
  วิเคราะห์สถิติจาก job card  
  สิทธิ์: admin หรือมี `X-API-Key`

## 9. Management Commands

- `python manage.py test_sqlserver_connection`
  ทดสอบการเชื่อมต่อ SQL Server

- `python manage.py import_sqlserver_cases`
  import จากตารางเคสซ่อมเข้า knowledge base

- `python manage.py sync_mt_job_cards`
  sync จาก view `v_MT_JOB_CARD` แบบ checkpoint

- `python manage.py import_history_xlsx "/path/to/file.xlsx"`
  import ไฟล์ xlsx แบบ `History-*` เข้า knowledge base

- `python manage.py preview_sqlserver_table`
  preview ข้อมูลจาก SQL Server

## 10. Data Storage And Retrieval

`KnowledgeDocument` คือ source of truth ของเอกสารความรู้ในฝั่ง Django

ตอนเพิ่ม/แก้เอกสาร:

- ระบบจะบันทึกลง SQLite
- chunk content
- embed ด้วย Ollama embedding model
- เก็บ vector ลง Chroma

ตอนค้น:

- query จะถูก embed
- search จาก Chroma เฉพาะ document ที่ user มีสิทธิ์เห็น
- มี deduplicate และกรองด้วย distance

ผลที่ตามมา:

- ถ้า `db.sqlite3` กับ `chroma_data` ไม่สอดคล้องกัน อาจค้นเจอข้อมูลไม่ครบ
- ถ้ามีการย้ายเครื่องโดยเอาเฉพาะ `db.sqlite3` ไป แต่ไม่เอา `chroma_data` ไปด้วย จะต้อง re-index เอกสารใหม่

## 11. Access Control

user ทั่วไป:

- login เข้า Chainlit ได้
- ถามตอบจาก knowledge shared ได้
- ดูประวัติห้องของตัวเองได้

admin / staff:

- จัดการ shared knowledge ได้
- import/sync SQL Server ได้
- ดู feedback summary ได้
- ดู system health ได้

external automation:

- เรียก endpoint import/sync/health บางตัวได้ถ้าใส่ `X-API-Key` ให้ตรงกับ `IMPORT_API_KEY`

## 12. Recommended Reading Order

1. `README.md`
2. `chainlit.md`
3. `config/settings.py`
4. `chatbot/views.py`
5. `chatbot/services/ollama_service.py`
6. `chatbot/services/langgraph_chat_service.py`
7. `chatbot/services/rag_service.py`
8. `chatbot/services/sqlserver_service.py`
9. `chatbot/services/sqlserver_job_card_sync_service.py`
10. `chatbot/services/xlsx_history_ingestion_service.py`

## 13. Technical Notes / Risks

1. `config/settings.py` ปัจจุบันเป็นค่าแนว development มากกว่า production
   - `DEBUG = True`
   - `ALLOWED_HOSTS = ["*"]`
   - มี `SECRET_KEY` เขียนอยู่ในไฟล์โดยตรง

2. `TIME_ZONE` ใน Django ตั้งเป็น `UTC`
   - ถ้าหน้างานจริงใช้เวลาไทย อาจต้องคุยต่อว่าควรปรับ `TIME_ZONE` หรือไม่

3. CORS default เปิดกว้าง
   - `CORS_ALLOW_ALL_ORIGINS = true` เป็นค่า default ใน settings
   - ถ้าจะ deploy จริงควร lock origin ให้ชัด

4. Chainlit ควรใช้ `Python 3.12`
   - ใน `run_chainlit.sh` มีการเช็กและเตือนเรื่อง `Python 3.14`

5. ข้อมูลระบบไม่ได้อยู่แค่ `db.sqlite3`
   - ยังมี `chroma_data/` ที่จำเป็นต่อการค้น RAG

6. `uvicorn` ไม่ได้ pin แยกตรง ๆ ใน `requirements.txt`
   - ตอนนี้น่าจะได้มาจาก dependency อื่น
   - ถ้าสภาพแวดล้อมใหม่มีปัญหาเรื่องรัน API ให้เช็กเรื่องนี้ก่อน

## 14. Recommended First-Day Checklist

1. อ่าน `README.md` และไฟล์นี้ก่อน
2. ขอ `.env` ตัวจริงจากคนส่งมอบ
3. เช็กว่ามี `db.sqlite3` และ `chroma_data` ครบ
4. สร้าง/เปิด venv ที่เป็น `Python 3.12`
5. `pip install -r requirements.txt`
6. รัน migrate
7. เปิด `ollama serve`
8. รัน `./run_api.sh` และ `./run_chainlit.sh`
9. login ด้วยบัญชี admin
10. ทดสอบ
    - `/api/health/`
    - `/api/system-health/`
    - ถามคำถามใน Chainlit
    - ทดสอบ import/sync SQL Server ถ้ามีสิทธิ์และ environment พร้อม

## 15. Summary

โปรเจกต์นี้เป็น chatbot ภายในที่ผูก RAG กับข้อมูลเอกสารและข้อมูลซ่อมจาก SQL Server  
แกนหลักที่ต้องเข้าใจมี 4 ส่วน:

- Django API
- Chainlit UI
- RAG / Chroma / Ollama
- SQL Server ingestion + sync checkpoint

ถ้าระบบมีปัญหา ให้ไล่เช็กตามลำดับนี้ก่อน:

- `.env` ถูกไหม
- Ollama ทำงานไหม และมี model ครบไหม
- `db.sqlite3` กับ `chroma_data` อยู่ครบไหม
- SQL Server ต่อได้ไหม
- endpoint `/api/system-health/` รายงานอะไร
