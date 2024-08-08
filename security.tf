#I was having trouble getting the jsonencode function to work for this policy.
#In looking for an alternative I found the EOF can preserve formatting by allowing you to create a multi line string. 
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "A policy to allow access to S3 buckets"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket",
                "ssm:SendCommand",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}

EOF
}

# IAM role for EC2 to access S3
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the s3_access_policy to the ec2_role
resource "aws_iam_role_policy_attachment" "ec2_s3_access_policy_attachment" {
  role       = var.ec2_role
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Attach the SSM Policy to the ec2_role
resource "aws_iam_role_policy_attachment" "SSM_policy_attachment" {
  role       = var.ec2_role
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  depends_on = [ aws_iam_role.ec2_role ]
}

# Attach the Cloudwatch policy to the ec2_role
resource "aws_iam_role_policy_attachment" "CloudWatch_policy_attachment" {
  role       = var.ec2_role
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  depends_on = [ aws_iam_role.ec2_role ]
}


# IAM instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = var.ec2_role
}

####AWS Config Configuration#####
#Policy to allow Config to write to S3 bucket
resource "aws_s3_bucket_policy" "config_bucket_policy" {
bucket = aws_s3_bucket.config_bucket.bucket

policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.config_bucket.bucket}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.config_bucket.bucket}"
    }
  ]
}
EOF
}

#Create an AWS Config configuration recorder to record resource configurations
resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
  }
}


#Create an AWS Config delivery channel to deliver configuration snapshots and history files to the S3 bucket
resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  depends_on = [ aws_config_configuration_recorder.config_recorder ] #Needed the explicit dependancy 
}

resource "aws_iam_role" "config_role" {
  name = "config-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

####AWS Security Hub Configuration#####

resource "aws_securityhub_account" "Security_Hub" {
  depends_on = [aws_iam_role.ec2_role]
}

# Enable the CIS AWS Foundations Benchmark standard in Security Hub
resource "aws_securityhub_standards_subscription" "cis_aws_foundations_benchmark" {
  depends_on    = [aws_securityhub_account.Security_Hub]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# Enable the AWS Foundational Security Best Practices standard in Security Hub
resource "aws_securityhub_standards_subscription" "aws_foundational_security_best_practices" {
  depends_on    = [aws_securityhub_account.Security_Hub]
  standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
}

#Enable the PCI DSS standard in Security Hub
resource "aws_securityhub_standards_subscription" "pci_dss" {
  depends_on    = [aws_securityhub_account.Security_Hub]
  standards_arn = "arn:aws:securityhub:us-east-1::standards/pci-dss/v/3.2.1"
}


# Create an IAM role for EventBridge with the necessary permissions to publish to SNS
resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create a policy to allow EventBridge to publish to the SNS topic
resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "eventbridge_policy"
  role = aws_iam_role.eventbridge_role.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.security_alerts.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
    
  
}

#Attach the Lambda execution policy to the role I created
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM role for Lambda to access EC2
resource "aws_iam_role" "lambda_ec2_role" {
  name = "lambda-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM policy to allow Lambda to start EC2 instances
resource "aws_iam_policy" "lambda_ec2_policy" {
  name        = "lambda-ec2-policy"
description = "A policy to allow Lambda to interact with S3, EC2, CloudWatch Logs, and SSM"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ssm:SendCommand"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the IAM policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_ec2_policy_attachment" {
  role       = aws_iam_role.lambda_ec2_role.name
  policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}

resource "aws_iam_policy" "workspaces_s3_access" {
  name        = "workspaces_access"
  description = "A policy to allow WorkSpaces to access the S3 buckets"
  policy      = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.original_reports_bucket}",
        "arn:aws:s3:::${var.original_reports_bucket}/*",
        "arn:aws:s3:::summarized-medical-reports-gk",
        "arn:aws:s3:::summarized-medical-reports-gk/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = "workspaces_DefaultRole"
  policy_arn = aws_iam_policy.workspaces_s3_access.arn
  depends_on = [aws_workspaces_workspace.workspace]
}


#Bucket Policies to allow Workspaces users
resource "aws_s3_bucket_policy" "original_medical_reports_policy" {
  bucket = var.original_reports_bucket

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::905418112205:user/S3user"
      },
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.original_reports_bucket}",
        "arn:aws:s3:::${var.original_reports_bucket}/*"
      ]
    }
  ]
}
EOF
depends_on = [ aws_iam_user.S3_user ]
}

resource "aws_s3_bucket_policy" "summarized_medical_reports_policy" {
  bucket = var.summarized_reports_bucket

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::905418112205:user/S3user"
      },
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.summarized_reports_bucket}",
        "arn:aws:s3:::${var.summarized_reports_bucket}/*"
      ]
    }
  ]
}
EOF
depends_on = [ aws_iam_user.S3_user ]
}

#IAM User to access the S3 buckets
resource "aws_iam_user" "S3_user" {
  name = var.S3_user
}

resource "aws_iam_group" "S3_access_group" {
  name = "S3_access_group"

}

resource "aws_iam_group_policy_attachment" "S3_access_group_policy" {
  group      = aws_iam_group.S3_access_group.name
  policy_arn = aws_iam_policy.workspaces_s3_access.arn
  
}

resource "aws_iam_group_membership" "S3_user_membership" {
  name = var.S3_user
  users = [aws_iam_user.S3_user.name]
  group = aws_iam_group.S3_access_group.name
  
}