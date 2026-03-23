import json
import logging
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    try:
        # Parse SNS message
        sns_message = json.loads(event['Records'][0]['Sns']['Message'])
        
        # Extract InstanceId safely
        dimensions = sns_message.get('Trigger', {}).get('Dimensions', [])
        instance_id = next(
            (d['value'] for d in dimensions if d.get('name') == 'InstanceId'),
            None
        )

        if not instance_id:
            raise ValueError("No InstanceId found in CloudWatch alarm dimensions")

        logger.info(f"Rebooting EC2 instance: {instance_id}")

        # Reboot the instance
        response = ec2.reboot_instances(InstanceIds=[instance_id])
        
        logger.info("Reboot response: %s", response)

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": f"Reboot initiated for instance {instance_id}"
            })
        }

    except ClientError as e:
        logger.error("AWS ClientError: %s", str(e))
        raise
    except Exception as e:
        logger.error("Unexpected error: %s", str(e))
        raise

