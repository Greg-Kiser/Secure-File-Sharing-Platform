#!/bin/bash
yum update -y
yum install -y aws-cli
aws s3 cp s3://secure-file-bucket /home/ec2-user/files --recursive
# Add file processing logic here
