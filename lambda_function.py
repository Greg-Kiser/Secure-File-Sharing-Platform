import json
import logging
import boto3
import os

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    s3 = boto3.client('s3')
    ec2 = boto3.client('ec2')
    ssm = boto3.client('ssm')

    # Get the S3 bucket and object key from the event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    # Log the file processing initiation
    logger.info(f"File {key} uploaded to {bucket}, triggering EC2 instance for processing.")

    # Get the EC2 instance ID from the environment variables
    instance_id = os.environ.get('INSTANCE_ID')

    # Log the instance ID
    logger.info(f"Using EC2 instance ID: {instance_id}")

    if not instance_id:
        logger.error("No EC2 instance ID found in environment variables.")
        return {
            'statusCode': 500,
            'body': json.dumps('No EC2 instance ID found in environment variables.')
        }

    # Check instance state
    try:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        state = response['Reservations'][0]['Instances'][0]['State']['Name']
        logger.info(f"EC2 instance state: {state}")
    except Exception as e:
        logger.error(f"Error describing EC2 instance: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error describing EC2 instance: {e}")
        }

    if state != 'running':
        logger.error(f"EC2 instance {instance_id} is not in a running state.")
        return {
            'statusCode': 400,
            'body': json.dumps(f"EC2 instance {instance_id} is not in a running state.")
        }

    # Command to run on EC2 instance
    command = f'aws s3 cp s3://{bucket}/{key} /home/ec2-user/reports/ && /home/ec2-user/s3_operations.sh {key}'

    try:
        # Send command to EC2 instance using SSM
        response = ssm.send_command(
            InstanceIds=[instance_id],
            DocumentName="AWS-RunShellScript",
            Parameters={'commands': [command]}
        )
        logger.info("SSM command sent: %s", response)
    except Exception as e:
        logger.error("Error sending SSM command: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error sending SSM command: {e}")
        }

    return {
        'statusCode': 200,
        'body': json.dumps('Process initiated successfully!')
    }
