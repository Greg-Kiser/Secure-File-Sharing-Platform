# main.tf

provider "aws" {
  region = "us-east-1"
}

/*
resource "aws_s3_bucket" "file_bucket" {
  bucket = "secure-file-bucket-GK"
}
*/
/*
resource "aws_instance" "file_processor" {
  ami           = "ami-0427090fd1714168b"  # Amazon Linux
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_role.s3_access_role.name

    user_data = file("file_processor.sh")

  tags = {
    Name = "FileProcessor"
  }
}
*/

resource "aws_workspaces_workspace" "workspace" {
  directory_id = "d-9067ecfa60"  # Use a relevant directory ID
  bundle_id    = "wsb-6cbvhvv9f"  # Use a relevant bundle
  user_name    = "Greg"

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key = "arn:aws:kms:us-east-1:905418112205:key/a440a174-a107-4210-810c-9db04595b28f"

#I did not want to create and destroy my workspace while building and troubleshooting this project as it takes 15 minutes or so to build. You may remove the life cycle policy if desired.
  lifecycle {
    prevent_destroy = true
  }
}
