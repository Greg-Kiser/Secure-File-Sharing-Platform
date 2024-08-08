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

# Install spaCy and its model
echo "$(date): Installing spaCy and its model" >> /var/log/user-data.log
pip3 install spacy >> /var/log/user-data.log 2>&1
python3 -m spacy download en_core_web_sm >> /var/log/user-data.log 2>&1

if [ $? -ne 0 ]; then
    echo "$(date): Failed to install spaCy or its model" >> /var/log/user-data.log
    exit 1
fi

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

# Ensure the summarized directory exists
if [ ! -d /home/ec2-user/summarized ]; then
    mkdir -p /home/ec2-user/summarized
    if [ $? -ne 0 ]; then
        echo "$(date): Failed to create /home/ec2-user/summarized directory" >> $LOG_FILE
        exit 1
    else
        echo "$(date): Created /home/ec2-user/summarized directory" >> $LOG_FILE
    fi
else
    echo "$(date): /home/ec2-user/summarized directory already exists" >> $LOG_FILE
fi

# Process the report using spaCy
echo "$(date): Processing report" >> $LOG_FILE
python3 -c "
import spacy
nlp = spacy.load('en_core_web_sm')
try:
    with open('/home/ec2-user/$1', 'r') as file:
        text = file.read()
    doc = nlp(text)
    summary = ' '.join([sent.text for sent in doc.sents][:5])  # Simple summarization
    with open('/home/ec2-user/summarized/$1', 'w') as out_file:
        out_file.write(summary)
    print('Summarization successful')
except Exception as e:
    print(f'Error processing the report: {e}')
" >> $LOG_FILE 2>&1

if [ $? -ne 0 ]; then
    echo "$(date): Failed to process report" >> $LOG_FILE
    exit 1
fi

# Upload the summarized file to another S3 bucket
echo "$(date): Uploading summarized file to target S3 bucket" >> $LOG_FILE
aws s3 cp /home/ec2-user/summarized/$1 s3://summarized-medical-reports-gk/summarized_$1 >> $LOG_FILE 2>&1

if [ $? -ne 0 ]; then
    echo "$(date): Failed to upload summarized file to S3" >> $LOG_FILE
    exit 1
fi

# Clean up
echo "$(date): Cleaning up" >> $LOG_FILE
rm /home/ec2-user/$1 /home/ec2-user/summarized/$1 >> $LOG_FILE 2>&1

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
