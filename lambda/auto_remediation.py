import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')

def lambda_handler(event, _context):
    logger.info("Received event: %s", json.dumps(event))

    for record in event.get("Records", []):
        try:
            message = json.loads(record.get("Sns", {}).get("Message", "{}"))
            dimensions = message.get("Trigger", {}).get("Dimensions", [])
            instance_id = next(
                (d.get("value") for d in dimensions if d.get("name") == "InstanceId"),
                None
            )

            if not instance_id:
                logger.warning("No InstanceId found in dimensions: %s", dimensions)
                continue

            logger.info("[ACTION] Rebooting instance: %s", instance_id)
            response = ec2.reboot_instances(InstanceIds=[instance_id])
            logger.info("Reboot call succeeded for %s: %s", instance_id, response)

        except Exception as e:
            logger.error("Failed to process record %s: %s", record, str(e))
