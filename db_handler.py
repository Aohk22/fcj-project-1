#!/usr/bin/env python

import boto3
import json
from pprint import pprint
from decimal import Decimal
from custom_types.types import StaticReport
from boto3.dynamodb.types import TypeSerializer


ENDPOINT_URL = 'http://host-machine.internal:8000' # testing purposes
TABLE_NAME = 'analysis_results'


# def list_tables(ddb):
#     '''
#     Needs low level boto3.client()
#     '''
#     table_names: list = list()
#     paginator = ddb.get_paginator('list_tables')
#     page_iterator = paginator.paginate(Limit=10)
#     for page in page_iterator:
#         for table_name in page.get('TableNames', []):
#             table_names.append(table_name)
#     return table_names


# def create_table(ddb):
#     '''
#     Needs low level boto3.client()
#     '''
#     response = ddb.create_table(
#         TableName=TABLE_NAME,
#         KeySchema=[
#             {'AttributeName': 'file_hash', 'KeyType': 'HASH'},
#             {'AttributeName': 'report_type', 'KeyType': 'RANGE'}
#         ],
#         AttributeDefinitions=[
#             {'AttributeName': 'file_hash', 'AttributeType': 'S'},
#             {'AttributeName': 'report_type', 'AttributeType': 'S'},
#         ],
#         BillingMode='PAY_PER_REQUEST'
#     )
#     return response


def insert_static_report(ddb, report: StaticReport):
    data: dict = json.loads(report.model_dump_json(), parse_float=Decimal)
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


# def get_all_static_reports(ddb):
#     table = ddb.Table(TABLE_NAME)
#     response = table.scan()
#     return response
