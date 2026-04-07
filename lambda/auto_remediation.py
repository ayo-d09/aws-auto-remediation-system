import json
import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, _context):
    for record in event.get("Records", []):
        message = json.loads(record.get("Sns", {}).get("Message", "{}"))
        dimensions = message.get("Trigger", {}).get("Dimensions", [])
        for d in dimensions:
            if d.get("Name") == "InstanceId":
                instance_id = d.get("Value")
                print("[ACTION] Rebooting instance:", instance_id)
                ec2.reboot_instances(InstanceIds=[instance_id])
                