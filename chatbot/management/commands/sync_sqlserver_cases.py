from django.core.management import call_command
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "sync ข้อมูลล่าสุดจาก SQL Server เข้า knowledge base"

    def add_arguments(self, parser):
        parser.add_argument("--table", dest="table", default=None, help="ชื่อ table")
        parser.add_argument("--schema", dest="schema", default=None, help="ชื่อ schema")
        parser.add_argument(
            "--limit",
            dest="limit",
            type=int,
            default=None,
            help="จำกัดจำนวนแถวที่ต้องการ sync",
        )
        parser.add_argument(
            "--days",
            dest="days",
            type=int,
            default=None,
            help="sync เฉพาะข้อมูลที่ Create_date อยู่ในช่วง N วันล่าสุด",
        )

    def handle(self, *args, **options):
        call_command(
            "import_sqlserver_cases",
            table=options.get("table"),
            schema=options.get("schema"),
            limit=options.get("limit"),
            days=options.get("days"),
        )
