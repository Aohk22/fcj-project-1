import json
from decimal import Decimal
from app.types.main import FileELF, FilePE
from boto3.dynamodb.types import TypeSerializer

TABLE_NAME = 'analysis_results'

def insertReport(ddb, report: FilePE | FileELF):
    data = json.loads(report.model_dump_json(), parse_float=Decimal)
    s = TypeSerializer()
    serialized = s.serialize(data)

    table = ddb.Table(TABLE_NAME)
    response = table.put_item(
        Item={
            'file_hash': data['hashes']['sha256'],
            'report_type': 'static',
            'data': serialized,
        }
    )
    return response
