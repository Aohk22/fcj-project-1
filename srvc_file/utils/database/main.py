import json
from decimal import Decimal
from utils.types_files.main import FileAll

TABLE_NAME = 'analysis_results'

def insertReport(ddb, report: FileAll):
    data = json.loads(report.model_dump_json(), parse_float=Decimal)
    # data = report.model_dump()

    table = ddb.Table(TABLE_NAME)
    response = table.put_item(
        Item={
            'file_hash': data['general']['hashes']['sha256'],
            'data': data,
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']
