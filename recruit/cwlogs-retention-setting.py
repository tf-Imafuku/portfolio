import boto3
import logging
import time

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# 保持期間を設定する
RETENTION_IN_DAYS = 400


def lambda_handler(event, context):
    accounts = event['accounts']

    for account in accounts:
        target_regions = account['target_regions']
        target_account_id = account['account_id']
        env = account['env']
        sid = account['sid']

        # STSクライアントを作成して、アカウントIDとロール名からロールを引き受ける
        sts_client = boto3.client('sts')
        role_arn = f'arn:aws:iam::{target_account_id}:role/sys-{env}-cwlogs-retention-setting-assume-role-{sid}'
        role = sts_client.assume_role(RoleArn=role_arn, RoleSessionName=context.function_name)

        logger.info(f'Start process {env}-{sid}')

        # 引き受けたロールからセッション情報を取得
        credentials = role['Credentials']
        access_key = credentials['AccessKeyId']
        secret_key = credentials['SecretAccessKey']
        session_token = credentials['SessionToken']

        for target_region in target_regions:
            logger.info(f'Start process {env}-{sid} in {target_region}')
            # CloudWatch Logsクライアントを作成して、セッション情報を使用して認証する
            logs_client = boto3.client(
                'logs',
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key,
                aws_session_token=session_token,
                region_name=target_region
            )

            paginator = logs_client.get_paginator('describe_log_groups')
            target_logs = []
            for page in paginator.paginate():
                # ロググループを取得して、保持期間が設定されていないものをtarget_logsに追加
                for log_group in page['logGroups']:
                    if 'retentionInDays' not in log_group:
                        logger.info(f"LogGroup {log_group['logGroupName']} has no retentionInDays")
                        target_logs.append(log_group['logGroupName'])

            # target_logsのロググループに保持期間を設定する
            for log_group_name in target_logs:
                retries = 0
                while True:
                    try:
                        logs_client.put_retention_policy(logGroupName=log_group_name, retentionInDays=RETENTION_IN_DAYS)
                        logger.info(f'Succeeded to set {RETENTION_IN_DAYS} retentionInDays to {log_group_name}')
                        # PutRetentionPolicyのスロットリング制限5/秒のため設定
                        time.sleep(0.2)
                        break
                    except Exception as e:
                        # エラーが発生した場合、エクスポネンシャルバックオフを使用してリトライする
                        retries += 1
                        retry_delay = 2 ** retries
                        logger.warning(f'Failed to set retentionInDays to {log_group_name}. Retrying in {retry_delay} seconds... (Retry {retries}). Exception: {e}')
                        time.sleep(retry_delay)