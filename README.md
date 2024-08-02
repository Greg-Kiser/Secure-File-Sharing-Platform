# Secure File Sharing and Analysis Platform

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

_Project Description:_

* _What it does: This service enables secure file sharing and analysis. The platform will process and summarize sensitive medical documents, ensuring compliance with security standards and providing alerts for high-severity security findings. This project can serve as a prototype for a secure document management and analysis system for a healthcare organization. It ensures that sensitive files (e.g., medical records) are securely uploaded, processed, and analyzed while adhering to strict security standards._

* _What technologies it uses: Terraform, Shell, Python, EC2, S3, IAM, KMS, CONFIG, Workspaces, Security Hub, Event Bridge, SNS, Lambda, and Cloudwatch_


## Usage/Architecture Overview

_At this time the admin user, me, will upload all the documents to the original S3 bucket. Once the file is uploaded to the S3 bucket an S3 Event will trigger a Lambda function. This Lambda function will deliver the S3 document to the EC2 instance. The EC2 instance is required to be running 24/7. The EC2 instance will process and summarize the medical document using spaCy. SpaCy is an open-source software library for advanced natural language processing. At the time of writing this I have elected to comment out the portion of the shell script where spaCy will summarize the document. I was having difficulty implementing that portion of the project and skipping over it allows me to showcase my ability to implement with all the services mentioned above. I will circle back and learn to work with spaCy in the future. Once it has summarized the medical document it will send it to the summarized S3 bucket. End users at the medical office will use AWS Workspaces to login and securely access both the original medical documents and the summarized documents. 

Considering the stringent security compliance for healthcare information we will use a combination of IAM, AWS KMS, AWS Config, Security Hub, Event Bridge, and SNS to harden our infrastructure. IAM will ensure users and services can communicate with one another while maintaining the principle of least privilege. AWS KMS will provide our file encryption. This is the superior choice to SSE S3 for this application as KMS can provide an audit trail for all KMS actions. AWS Config must be enabled to utilize Security Hub. Security Hub will monitor our infrastructure for findings based on AWS Foundational Security Best Practices, CIS AWS Foundations Benchmarks, and PCI DSS. When findings occur, we have created an EventBridge Rule to import the finding and send the details to SNS where our security team can be notified and review the findings. 
CloudWatch is currently being implemented for troubleshooting communication difficulties. _

```terraform
module "template" {
  source = "getindata/template/null"
  # version  = "x.x.x"

  example_var = "foo"
}
```

## NOTES

_Additional information that should be made public, for ex. how to solve known issues, additional descriptions/suggestions_


<!-- BEGIN_TF_DOCS -->


## AUTHOR

<!--- Replace repository name -->
https://github.com/Greg-Kiser
