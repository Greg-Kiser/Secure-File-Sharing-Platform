# main.tf

provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "original_reports" {
  bucket = "original-medical-reports-gk"
  
}


#Create the S3 event notification to trigger the lambda function to process the documents
resource "aws_s3_bucket_notification" "original_reports_notification" {
  bucket = aws_s3_bucket.original_reports.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_transfer.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [ aws_lambda_function.file_transfer ]
}


# Allow S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_transfer.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.original_reports.arn
}

#Apply the KMS SSE configuration to the summarized reports bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "original_reports_encryption" {
  bucket = aws_s3_bucket.original_reports.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_bucket_key.id
    }
  }
}


resource "aws_s3_bucket" "summarized_reports" {
  bucket = "summarized-medical-reports-gk"
  
}
#Apply the KMS SSE configuration to the summarized reports bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "summarized_reports_encryption" {
  bucket = aws_s3_bucket.summarized_reports.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_bucket_key.id
    }
  }
}

#Delivery Bucket for Config
resource "aws_s3_bucket" "config_bucket" {
  bucket = "aws-config-bucket-gk"
}

resource "aws_instance" "file_processor" {
  ami           = "ami-0427090fd1714168b"  # Amazon Linux
  instance_type = "t2.micro"
  iam_instance_profile =  aws_iam_instance_profile.ec2_instance_profile.name
  security_groups = [aws_security_group.allow_ssh.name]

   user_data = file("file_processor.sh")

  tags = {
    Name = "FileProcessor"
  }
}

/*
resource "aws_workspaces_workspace" "workspace" {
  directory_id = "d-9067ecfa60"  # Use a relevant directory ID
  bundle_id    = "wsb-6cbvhvv9f"  # Use a relevant bundle
  user_name    = "Greg"
  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key = "arn:aws:kms:us-east-1:905418112205:key/a440a174-a107-4210-810c-9db04595b28f"

  workspace_properties {
    running_mode                              = "AUTO_STOP"
 } 
}
*/

#Create an SNS topic for security alerts
resource "aws_sns_topic" "security_alerts" {
  name = "security-alerts"
}

resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  name        = "SecurityHubFindings"
  description = "Capture Security Hub findings"
  event_pattern = <<EOF
{
  "source": [
    "aws.securityhub"
  ],
  "detail-type": [
    "Security Hub Findings - Imported"
  ],
  "detail": {
    "findings": {
      "Severity": {
        "Label": [
          "HIGH"
        ]
      }
    }
  }
}
EOF
}

# Create an EventBridge target to send Security Hub findings to the SNS topic
resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.security_hub_findings.name
  target_id = "sendToSNS"
  arn       = aws_sns_topic.security_alerts.arn

    input_transformer {
    input_paths = {
      detail = "$.detail"
    }

    input_template = <<EOF
{
  "default": <detail>,
  "email": "Security Hub Alert: High Severity Finding Detected",
  "detail": <detail>
}
EOF
  }
}

# Lambda function to trigger the EC2 instance
resource "aws_lambda_function" "file_transfer" {
  function_name    = "file_transfer"
  role             = aws_iam_role.lambda_ec2_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  filename         = "lambda_function.zip"
  depends_on = [ aws_lambda_layer_version.lambda_layer]
  source_code_hash = filebase64sha256("lambda_function.zip")
  timeout = 60

  environment {
    variables = {
      INSTANCE_ID = aws_instance.file_processor.id
    }
  }

layers = [aws_lambda_layer_version.lambda_layer.arn]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "layer.zip"
  layer_name = "lambda_layer"
  compatible_runtimes = ["python3.8"]

  source_code_hash = filebase64sha256("layer.zip")
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/file_transfer"
  retention_in_days = 14  # Adjust the retention period as needed
}

resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name = "/ec2/logs"
  retention_in_days = 14  # Adjust as needed
}