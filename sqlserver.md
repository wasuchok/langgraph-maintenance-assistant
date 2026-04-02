# SQL Server Setup

โปรเจกต์นี้รองรับการเชื่อมต่อ SQL Server เป็นฐานข้อมูลภายนอกสำหรับดึงข้อมูลเคส/อาการ โดยยังใช้ `SQLite` เดิมของ Django ต่อไปตามปกติ

## Environment

เพิ่มค่าพวกนี้ใน `.env`

```env
SQLSERVER_HOST=192.168.1.10
SQLSERVER_PORT=1433
SQLSERVER_DATABASE=YourDatabase
SQLSERVER_USERNAME=sa
SQLSERVER_PASSWORD=your-password
SQLSERVER_CLIENT=pytds
SQLSERVER_DRIVER=ODBC Driver 18 for SQL Server
SQLSERVER_ENCRYPT=no
SQLSERVER_TRUST_SERVER_CERTIFICATE=yes
SQLSERVER_TRUSTED_CONNECTION=no
SQLSERVER_CONNECTION_TIMEOUT=30
SQLSERVER_CASES_SCHEMA=dbo
SQLSERVER_CASES_TABLE=YourCasesTable
```

## Commands

ทดสอบการเชื่อมต่อ

```bash
python manage.py test_sqlserver_connection
```

ดูตัวอย่างข้อมูลจาก table

```bash
python manage.py preview_sqlserver_table --table YourCasesTable --limit 5
```

ถ้าตั้ง `SQLSERVER_CASES_TABLE` ไว้แล้ว จะรันสั้น ๆ ได้เลย

```bash
python manage.py preview_sqlserver_table --limit 5
```

import เคสจาก SQL Server เข้า knowledge base และ index เข้า RAG

```bash
python manage.py import_sqlserver_cases
```

ถ้าต้องการลองบางส่วนก่อน

```bash
python manage.py import_sqlserver_cases --limit 20
```

ถ้าต้องการ sync เฉพาะข้อมูลที่อยู่ในช่วง N วันล่าสุด

```bash
python manage.py import_sqlserver_cases --days 7
python manage.py sync_sqlserver_cases --days 7
```

สั่ง sync ล่าสุดด้วยชื่อคำสั่งที่ใช้กับ cron ได้ง่ายขึ้น

```bash
python manage.py sync_sqlserver_cases
```

ตัวอย่าง cron sync ทุกวันตอนตีสอง

```cron
0 2 * * * cd /Users/mac_it/Desktop/django-local-chatbot && /Users/mac_it/Desktop/django-local-chatbot/.venv312/bin/python manage.py sync_sqlserver_cases
```

ตัวอย่าง cron sync เฉพาะ 7 วันล่าสุดทุกวันตอนตีสอง

```cron
0 2 * * * cd /Users/mac_it/Desktop/django-local-chatbot && /Users/mac_it/Desktop/django-local-chatbot/.venv312/bin/python manage.py sync_sqlserver_cases --days 7
```

## Notes

- ค่าเริ่มต้นในโปรเจกต์นี้ใช้ `python-tds` (`SQLSERVER_CLIENT=pytds`) เพราะตั้งต้นง่ายกว่าและไม่ต้องพึ่ง ODBC driver ของระบบ
- ถ้าต้องการใช้ ODBC ภายหลัง ค่อยเปลี่ยนเป็น `SQLSERVER_CLIENT=pyodbc`
- ถ้าใช้ `pyodbc` บน macOS ต้องมี ODBC driver ของ SQL Server ให้พร้อมก่อน เช่น Microsoft ODBC Driver 18
- คำสั่ง import ใช้ `CARD_ID` เป็นคีย์อ้างอิงคงที่ ถ้ารันซ้ำจะแก้เฉพาะแถวที่เปลี่ยนและข้ามแถวที่เหมือนเดิม
- เอกสารที่ import จาก SQL Server จะถูกเก็บเป็น knowledge แบบ `shared`
- โหมด `--days N` ในเวอร์ชันนี้ใช้คอลัมน์ `Create_date` เป็นตัวกรองข้อมูลล่าสุด
