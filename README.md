# Secure File Sharing and Analysis Platform

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

_Project Description:_

* _What it does: This service enables secure file sharing and analysis. The platform will process and summarize sensitive medical documents, ensuring compliance with security standards and providing alerts for high-severity security findings. This project can serve as a prototype for a secure document management and analysis system for a healthcare organization. It ensures that sensitive files (e.g., medical records) are securely uploaded, processed, and analyzed while adhering to strict security standards._

* _What technologies it uses: Terraform, Shell, Python, EC2, S3, IAM, CONFIG, Workspaces, Security Hub, Event Bridge, SNS, Lambda, and Cloudwatch_


## Architecture Overview

At this time the admin user, me, will upload all the documents to the original S3 bucket. Once the file is uploaded to the S3 bucket an S3 Event will trigger a Lambda function. This Lambda function will deliver the S3 document to the EC2 instance. The EC2 instance is required to be running 24/7. The EC2 instance will process and summarize the medical document using spaCy. SpaCy is an open-source software library for advanced natural language processing. Once it has summarized the medical document it will send it to the summarized S3 bucket with the “summarized_ prefix” appended to the document. End users at the medical office will use AWS Workspaces to login and securely access both the original medical documents and the summarized documents. 

Considering the stringent security compliance for healthcare information we will use a combination of IAM, AWS Config, Security Hub, Event Bridge, and SNS to harden our infrastructure. IAM will ensure users and services can communicate with one another while maintaining the principle of least privilege. S3 SSE will provide our file encryption. AWS Config must be enabled to utilize Security Hub. Security Hub will monitor our infrastructure for findings based on AWS Foundational Security Best Practices, CIS AWS Foundations Benchmarks, and PCI DSS. When findings occur, we have created an EventBridge Rule to import the finding and send the details to SNS where our security team can be notified and review the findings. 
![Secure-File-Sharing-Platform-Diagram](https://github.com/user-attachments/assets/e6537ca5-5696-4284-a520-5fe99c7553df)

## USAGE INSTRUCTIONS
1.	Create your own .tfvars file and set your variables.
2.	Run Terraform Apply. (This will fail to create your workspace and attach a policy)
3.	Login to the AWS Console and navigate to the Workspaces dashboard. 
4.	Navigate to Workspaces > Personal and click “Create WorkSpace”.
5.	Click “Next” and select your directory. It will ask you to select your users. Instead, you will click “Create users”. 
![image](https://github.com/user-attachments/assets/b7c14ef8-398e-4c01-b0db-83f62f4b0b45)
6.	Once you create your user re-run Terraform Apply.
7.	You entire project is now built. You may test the functionality by uploading a document to the original-medical-reports bucket.
8.	Within 30 seconds or so you should see the summarized report within the summarized-medical-reports bucket. 
9.	You may additionally follow your workspace registration instructions you received via email from step 5 earlier. Once you have registered and downloaded workspaces login to your workspace.
10.	Open your web browser and navigate to https://s3browser.com/ .
11.	Download and install the S3 browser.
12.	Run the S3 Browser after completing installation.
13.	Back in your AWS dashboard navigate to IAM > Users > S3user.
14.	Under the Security Credentials tab click “Create Access Key”
15.	Securely store your access keys.
16.	Navigate back to your workspace desktop and complete the S3 Browser setup using the Access Keys you generated.
17.	You will see your AWS Buckets listed in a file directory format. You will only have access to the medical document bucket objects though. You may download and read the documents.
18.	If you intend to use the setup in the future I would recommend making an image of your workspace and creating a Bundle from that image. This will allow you to deploy future setups with the S3 Browser downloaded and configured for your S3user. 

## NOTES
With the EC2 instance having its ports closed you will need to use ssm in order to securely access it for troubleshooting. Additionally, be certain to utilize cloudwatch logs and the logging folders created by your fileprocessor.sh.


## LESSONS LEARNED

1.	When I originally implemented the IAM policies I had difficulties getting one of them to correctly translate using the jsonencode() function. I was getting a successful resource creation notification from my Terraform Apply, but the resource was not actually in AWS. This led me to learn about the “EOF” functionality for terraform. I used EOF to create a multiline string of the JSON policy I generated within AWS to import the code directly without translation. 

2.	This was the first hands on project I had built using Terraform. In order to reinforce my learning I would build the resources through terraform, look at them in the AWS Console, destroy them, and then rebuild them in the console. This allowed me to understand exactly how terraform was working. This caused some confusion when I got to the Config portion though. I discovered after reading the official AWS config documentation that you can only view and interact with the recorders through the CLI. 

3.	I could not get the AWS Config Recorder permissions set up for the service to be able to write to the bucket. The s3:GetBucketAcl permission is needed for AWS Config because, during the setup and operation of the AWS Config delivery channel, AWS Config verifies that it has the necessary permissions to write to the S3 bucket by checking the bucket's ACL (Access Control List). I was only giving it the s3:PutObject permission initially. 

4.	When you create an IAM Role with a trust relationship for the ec2 service an instance profile ARN is generated. This instance profile is what you must attach to the EC2 instance in terraform. I was attaching the role itself for a while which was giving me permission errors preventing the ec2 instance from generating. 

5.	I couldn’t get my Lambda function to trigger when uploading a file to the S3 bucket so I needed to enable cloudwatch logs for the Lambda function to have a way to troubleshoot. 

6.	I had a lot of difficulties getting the Lambda function to communicate with the EC2 instance. Eventually realizing the Lambda function uses the SSM agent to communicate with the EC2 instance led me to realize the SSM agent must be installed and running on the EC2 instance. I added lines for this to the shell script that is pulled into the user data of the EC2 instance. The SSM command still wasn’t reaching my EC2 instance so I learned on Stack Overflow that you must have certain SSM permissions to accomplish this. The SSMManagedNode Policy should be attached to your EC2 role. After a short period of time you will be able to see the EC2 instance in your SSM Inventory. Additionally, you can check the status of your ssm agent with the following command: sudo systemctl status amazon-ssm-agent

7.	I then had issues with any logs being generated or showing any activity after I knew the SSM command was reaching the EC2 instance. I cut out the prior portion of my process and began running the SSM command directly through my EC2 instance connect. This allowed me to save the time of deleting, re-uploading, and executing the S3 event/Lambda portion. Once I ran the SSM command I used the following ssm status checks to see what was happening with the command.
a.	aws ssm list-commands --region us-east-1
b.	aws ssm list-command-invocations --command-id 3741697f-5100-451d-8238-22c74f9bf6c6 --details --region us-east-1
These commands showed me my EC2 instance was attempting to fetch the file from the S3 bucket, but did not have the KMS key access I was using to encrypt the files in the S3 bucket.
Ultimately, this combined with several other KMS decryption and encryption issues I decided to use SSE S3 for this project and to update it to use KMS down the road.

8.	Once I was ready to verify the end user could utilize workspaces to securely view the original and summarized documents, I realized I had set them up for a technically sophisticated end-user rather than someone who would likely be using the software. In order to simplify the process, I wanted to provide the end user with a GUI method to access these records that would satisfy HIPPA compliance. I opted for S3 Browser, a free windows application that allows users to access and manage Amazon S3 and Amazon CloudFront files and storage settings without using a web browser. I was unable to access the buckets for a little bit. This is due to the S3 Browser showing the buckets using the "s3:ListAllMyBuckets" on “*” buckets. Once I added this to the IAM policy I was able to generate the list of buckets andaccess the allowed files. 

![image](https://github.com/user-attachments/assets/1d7d0037-9e0c-46e4-8d6a-42f585f4abac)

9. The last portion of my project was finalizing the shell script "s3_operations.sh" that my EC2 instance is using to summarize the documents. This required a lot of logging statements be added to the shell script so I could see what was happening at each stage. As someone without a coding background this was a very helpful lesson in troubleshooting using log statements throughout a peice of code for review at different points. 


## IMPROVING THE PROJECT

There are several improvements that could be made to the project in the future. 

Lambda would be a better for the given use case instead of using an EC2 instance. However, I wanted to utilize the EC2 service for experience on this particular project. I will update this to a Lambda function in the future.

Hardening the Infrastructure:

•	Swap to using KMS for encryption so that all API calls against the key can be tracked via CloudTrail.

•	IP Access Controls for Work Spaces – Lock down the Ips that access the workstations.

•	Move the EC2 instance into a private subnet and set up a NAT Gateway.





## AUTHOR

<!--- Replace repository name -->
https://github.com/Greg-Kiser
