#--------------VPC----------------
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  
}

variable "subnet1_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "subnet2_id" {
  description = "The ID of the subnet"
  type        = string
  
}
#--------------S3 Vars----------------

variable "original_reports_bucket" {
  description = "The name of the S3 bucket that will store the original medical reports"
  type        = string
}

variable "summarized_reports_bucket" {
  description = "The name of the S3 bucket that will store the summarized medical reports"
  type        = string
}

variable "config_bucket" {
  description = "The name of the S3 bucket that will store the AWS Config reports"
  type        = string
}


#--------------EC2 Vars----------------
variable "EC2_ami" {
  description = "value of the AMI to use for the EC2 instance"
  type = string
}

#--------------WorkSpaces Vars--------------
variable "workspace_bundle" {
  description = "The ID of the WorkSpace bundle to use"
  type        = string
}

variable "workspace_user" {
  description = "value of the user to use for the WorkSpace"
  type = string
}

variable "directory_password" {
  description = "value of the password to use for the directory"
  type = string
  
}

#--------------IAM----------------
variable "ec2_role" {
  description = "value of the IAM role to use for the EC2 instance"
  type = string
}

variable "S3_user" {
  description = "value of the IAM user to use for the S3 bucket"
  type = string
}