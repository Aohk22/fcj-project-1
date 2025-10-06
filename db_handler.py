# query-service/db_handler.py
import boto3
from boto3.dynamodb.conditions import Key
from decimal import Decimal
import json

ENDPOINT_URL = 'http://host-machine.internal:8000'
TABLE_NAME = 'analysis_results'

def get_static_report_by_hash(file_hash: str) -> dict | None:
    dynamodb = boto3.resource('dynamodb', endpoint_url=ENDPOINT_URL)
    table = dynamodb.Table(TABLE_NAME)

    response = table.query(
        KeyConditionExpression=Key('file_hash').eq(file_hash) & Key('report_type').eq('static')
    )
    items = response.get('Items', [])

    if not items:
        return None

    report_item = items[0]
    report_data = report_item.get('data', {})

    # Hàm chuyển đổi Decimal sang kiểu native Python
    def convert_decimals_to_native(obj):
        if isinstance(obj, Decimal):
            return float(obj) if obj % 1 != 0 else int(obj)
        elif isinstance(obj, dict):
            return {k: convert_decimals_to_native(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [convert_decimals_to_native(elem) for elem in obj]
        return obj

    return convert_decimals_to_native(report_data)