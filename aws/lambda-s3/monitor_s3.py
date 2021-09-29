#!/usr/bin/python
# -*- coding: utf-8 -*-
# This is AWS Lambda function for monitoring S3 size

import os
import re
import sys
import time
import datetime

import json
import copy

import boto3
import botocore
from botocore.exceptions import ClientError

now = datetime.datetime.now()
print('__start monitoring s3: {}'.format(now.strftime('%Y-%m-%d %H:%M:%S')))

class MonitorS3(object):

    name = 'lambda_s3_monitor'

    def __init__(self, event, context):

        """ Main Class init
        Args:
            event (dict): AWS Cloudwatch Scheduled Event
            context (object): AWS running context
        """

        self.context = context
        self.event = event
        
        self.results = []
        self.cfg = {}

        self.cfg['cw_s3_start_date'] = self.set_cloudwatch_date(-3)
        self.cfg['cw_s3_end_date']   = self.set_cloudwatch_date(-2)
        self.cfg['default_region']   = 'us-east-1'
        self.cfg['details'] = {
            'updated': datetime.datetime.now().isoformat(),
            'region':      '',
            'service':     '',
            'identifier':  '',
            'usage':       '',
            'unit':        ''
        }


    def set_cloudwatch_date(self, days):

        timedelta = str(now + datetime.timedelta(days=days))

        return timedelta.split(' ')[0]


    def set_table(self, service, unit, usage=0):

        table            = copy.deepcopy(self.cfg['details'])
        table['service'] = service
        table['unit']    = unit
        table['usage']   = usage

        return table


    def get_s3(self):

        local_session = boto3.session.Session()

        s3_resource = local_session.resource('s3', region_name=self.cfg['default_region'])
        s3_client   = local_session.client('s3',   region_name=self.cfg['default_region'])

        detail_table = self.set_table(service='S3', unit='tb', usage=0)

        try:
            for bucket in s3_resource.buckets.all():
                copy_table               = copy.deepcopy(detail_table)
                copy_table['identifier'] = bucket.name

                try:
                    copy_table['region'] = s3_client.head_bucket(Bucket=bucket.name)['ResponseMetadata']['HTTPHeaders']['x-amz-bucket-region']
                    self.get_bucket_size(local_session, copy_table)

                except Exception as e:
                    copy_table['region'] = self.cfg['default_region']
                
                self.results.append(copy_table)

        except Exception as e:
            print('___error in get_s3: {}'.format(e))


    def get_bucket_size(self, local_session, table):

        cw_client = local_session.client('cloudwatch', region_name=table['region'])

        self.get_bucket_metric(cw_client, table, 'StandardStorage')
        self.get_bucket_metric(cw_client, table, 'StandardIAStorage')
        self.get_bucket_metric(cw_client, table, 'OneZoneIAStorage')
        self.get_bucket_metric(cw_client, table, 'ReducedRedundancyStorage')
        self.get_bucket_metric(cw_client, table, 'GlacierStorage')


    def get_bucket_metric(self, client, table, storage):

        try:
            response = client.get_metric_statistics(
                Namespace  = 'AWS/S3',
                MetricName = 'BucketSizeBytes',
                Dimensions = [
                    {
                        'Name': 'BucketName',
                        'Value': table['identifier']
                    },
                    {
                        'Name': 'StorageType',
                        'Value': storage
                    }
                ],
                StartTime  = self.cfg['cw_s3_start_date'],
                EndTime    = self.cfg['cw_s3_end_date'],
                Period     = 86400,
                Statistics = [ 'Average' ]
            )
            
            datapoints = response['Datapoints']
         
            if datapoints != [] :
                bucket_size_bytes = response['Datapoints'][-1]['Average']/1000/1000/1000/1000 
                table['usage'] += round(bucket_size_bytes, 5)

        except Exception as e:
            print('___error in get_bucket_metric: {}'.format(e))


def print_json(_obj):
    print(json.dumps(_obj, indent=4, ensure_ascii=False))


def lambda_handler(event, context):

    """ Main Lambda function
    Args:
        event (dict): AWS Cloudwatch Scheduled Event
        context (object): AWS running context
    Returns:
        None
    """

    # initialize jobs  
    aws_job = MonitorS3(event, context) 

    # run jobs
    aws_job.get_s3()

    # print jobs
    print('__count of results: {}'.format(len(aws_job.results)))

    for element in aws_job.results:
        print('___Bucket: {:42s} Size: {:9f} TB'.format(element['identifier'], element['usage']))


if __name__ == "__main__":
    
    lambda_handler({}, {})
