# main.tf

provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "original_reports" {
  bucket = var.original_reports_bucket
  
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

resource "aws_s3_bucket" "summarized_reports" {
  bucket = var.summarized_reports_bucket
}

#Delivery Bucket for Config
resource "aws_s3_bucket" "config_bucket" {
  bucket = "aws-config-bucket-gk"
}

resource "aws_instance" "file_processor" {
  ami           = var.EC2_ami # Amazon Linux
  instance_type = "t2.micro"
  iam_instance_profile =  aws_iam_instance_profile.ec2_instance_profile.name

   user_data = file("file_processor.sh")

  tags = {
    Name = "FileProcessor"
  }
}


#Creating the Workspaces Directory 
resource "aws_directory_service_directory" "workspaces_directory" {
  name = "securefile.example.com"
  short_name = "securefile"
  password = var.directory_password
  type = "SimpleAD" 
  size = "Small"
  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = [
      var.subnet1_id, 
      var.subnet2_id
      ]
  }
}

#Register the Directory
resource "aws_workspaces_directory" "directory" {
  directory_id = aws_directory_service_directory.workspaces_directory.id
}


#Create a WorkSpace Desktop
resource "aws_workspaces_workspace" "workspace" {
  directory_id = aws_directory_service_directory.workspaces_directory.id
  bundle_id    = var.workspace_bundle  # Use a relevant bundle
  user_name    = var.workspace_user
  workspace_properties {
    running_mode                              = "AUTO_STOP"
     running_mode_auto_stop_timeout_in_minutes = 60  # Ensure this value is within the permissible range
 } 

depends_on = [ aws_workspaces_directory.directory ]
}

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