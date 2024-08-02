#!/bin/bash
set -x  # Enable debugging

# Redirect all output to a log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "$(date): Starting user data script" >> /var/log/user-data.log

# Update and install necessary packages
sudo yum update -y
sudo yum install -y aws-cli python3-pip amazon-ssm-agent

# Install CloudWatch Agent
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -Uvh amazon-cloudwatch-agent.rpm

# Start the SSM agent
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent

# Create directories for logs
if [ ! -d /var/log/myapp ]; then
    sudo mkdir -p /var/log/myapp
    if [ $? -ne 0 ]; then
        echo "$(date): Failed to create /var/log/myapp directory" >> /var/log/user-data.log
    else
        echo "$(date): Created /var/log/myapp directory" >> /var/log/user-data.log
    fi
else
    echo "$(date): /var/log/myapp directory already exists" >> /var/log/user-data.log
fi

sudo touch /var/log/myapp/s3_operations.log
if [ $? -ne 0 ]; then
  echo "$(date): Failed to create /var/log/myapp/s3_operations.log" >> /var/log/user-data.log
else
  echo "$(date): Created /var/log/myapp/s3_operations.log" >> /var/log/user-data.log
fi

# Create a script to handle the S3 operations
sudo tee /home/ec2-user/s3_operations.sh > /dev/null << 'EOF'
#!/bin/bash

LOG_FILE="/var/log/myapp/s3_operations.log"

# Log start of script
echo "$(date): Starting S3 operations script with argument: $1" >> $LOG_FILE

# Download the file from the S3 bucket
echo "$(date): Downloading file from S3 bucket" >> $LOG_FILE
aws s3 cp s3://original-medical-reports-gk/$1 /home/ec2-user/$1 >> $LOG_FILE 2>&1

if [ $? -ne 0 ]; then
    echo "$(date): Failed to download file from S3" >> $LOG_FILE
    exit 1
fi

# Process the report
# echo "$(date): Processing report" >> $LOG_FILE
# python3 -c "
# import spacy
# nlp = spacy.load('en_core_web_sm')
# with open('/home/ec2-user/reports/$1', 'r') as file:
#     text = file.read()
# doc = nlp(text)
# summary = ' '.join([sent.text for sent in doc.sents][:5])  # Simple summarization
# with open('/home/ec2-user/summarized/$1', 'w') as out_file:
#     out_file.write(summary)
# " >> $LOG_FILE 2>&1

# if [ $? -ne 0 ]; then
#   echo "$(date): Failed to process report" >> $LOG_FILE
#   exit 1
# fi
#End Report Processing

# Upload the file to another S3 bucket
echo "$(date): Uploading file to target S3 bucket" >> $LOG_FILE
aws s3 cp /home/ec2-user/$1 s3://summarized-medical-reports-gk/$1 >> $LOG_FILE 2>&1

if [ $? -ne 0 ]; then
    echo "$(date): Failed to upload file to S3" >> $LOG_FILE
    exit 1
fi

# Clean up
echo "$(date): Cleaning up" >> $LOG_FILE
rm /home/ec2-user/$1 >> $LOG_FILE 2>&1

if [ $? -ne 0 ]; then
    echo "$(date): Cleanup failed" >> $LOG_FILE
    exit 1
fi

# Log end of script
echo "$(date): Completed S3 operations script: $1" >> $LOG_FILE
EOF

# Verify script creation
if [ -f /home/ec2-user/s3_operations.sh ]; then
  echo "$(date): Script created successfully" >> /var/log/user-data.log
else
  echo "$(date): Script creation failed" >> /var/log/user-data.log
fi

# Make the script executable
sudo chmod +x /home/ec2-user/s3_operations.sh

# Verify script execution permissions
if [ -x /home/ec2-user/s3_operations.sh ]; then
  echo "$(date): Script is executable" >> /var/log/user-data.log
else
  echo "$(date): Script is not executable" >> /var/log/user-data.log
fi

echo "$(date): Completed user data script" >> /var/log/user-data.log
