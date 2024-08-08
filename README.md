# Secure File Sharing and Analysis Platform

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

_Project Description:_

* _What it does: This service enables secure file sharing and analysis. The platform will process and summarize sensitive medical documents, ensuring compliance with security standards and providing alerts for high-severity security findings. This project can serve as a prototype for a secure document management and analysis system for a healthcare organization. It ensures that sensitive files (e.g., medical records) are securely uploaded, processed, and analyzed while adhering to strict security standards._

* _What technologies it uses: Terraform, Shell, Python, EC2, S3, IAM, CONFIG, Workspaces, Security Hub, Event Bridge, SNS, Lambda, and Cloudwatch_


## Architecture Overview

At this time the admin user, me, will upload all the documents to the original S3 bucket. Once the file is uploaded to the S3 bucket an S3 Event will trigger a Lambda function. This Lambda function will deliver the S3 document to the EC2 instance. The EC2 instance is required to be running 24/7. The EC2 instance will process and summarize the medical document using spaCy. SpaCy is an open-source software library for advanced natural language processing. Once it has summarized the medical document it will send it to the summarized S3 bucket with the “summarized_ prefix” appended to the document. End users at the medical office will use AWS Workspaces to login and securely access both the original medical documents and the summarized documents. 

Considering the stringent security compliance for healthcare information we will use a combination of IAM, AWS Config, Security Hub, Event Bridge, and SNS to harden our infrastructure. IAM will ensure users and services can communicate with one another while maintaining the principle of least privilege. S3 SSE will provide our file encryption. AWS Config must be enabled to utilize Security Hub. Security Hub will monitor our infrastructure for findings based on AWS Foundational Security Best Practices, CIS AWS Foundations Benchmarks, and PCI DSS. When findings occur, we have created an EventBridge Rule to import the finding and send the details to SNS where our security team can be notified and review the findings. 

<mxfile host="app.diagrams.net" agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" version="24.7.6">
  <diagram id="Ht1M8jgEwFfnCIfOTk4-" name="Page-1">
    <mxGraphModel dx="1025" dy="999" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <mxCell id="UEzPUAAOIrF-is8g5C7q-74" value="AWS Cloud" style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=none;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_aws_cloud_alt;strokeColor=#232F3E;fillColor=none;verticalAlign=top;align=left;spacingLeft=30;fontColor=#232F3E;dashed=0;labelBackgroundColor=#ffffff;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;" parent="1" vertex="1">
          <mxGeometry x="160" y="64" width="820" height="700" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-5" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" source="hocCvkXVjEJjBnLw5MO3-1" target="hocCvkXVjEJjBnLw5MO3-4">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-13" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" source="hocCvkXVjEJjBnLw5MO3-1" target="UEzPUAAOIrF-is8g5C7q-80">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-1" value="Lambda Function" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#ED7100;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.lambda;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="290" y="450" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-9" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" source="hocCvkXVjEJjBnLw5MO3-4" target="hocCvkXVjEJjBnLw5MO3-10">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="589" y="617" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-11" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" source="hocCvkXVjEJjBnLw5MO3-4">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="720.7734731084779" y="470" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-4" value="EC2 File Processor" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#ED7100;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.ec2;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="550" y="450" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="UEzPUAAOIrF-is8g5C7q-78" value="Summarized Reports" style="outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#277116;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;pointerEvents=1;shape=mxgraph.aws4.bucket_with_objects;labelBackgroundColor=#ffffff;" parent="UEzPUAAOIrF-is8g5C7q-74" vertex="1">
          <mxGeometry x="720" y="450" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-6" value="Systems Manager" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#E7157B;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.systems_manager;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="410" y="450" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="UEzPUAAOIrF-is8g5C7q-80" value="Amazon&lt;br&gt;CloudWatch" style="outlineConnect=0;fontColor=#232F3E;gradientColor=#F34482;gradientDirection=north;fillColor=#BC1356;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.cloudwatch;labelBackgroundColor=#ffffff;" parent="UEzPUAAOIrF-is8g5C7q-74" vertex="1">
          <mxGeometry x="290" y="590" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-10" value="Amazon&lt;br&gt;CloudWatch" style="outlineConnect=0;fontColor=#232F3E;gradientColor=#F34482;gradientDirection=north;fillColor=#BC1356;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.cloudwatch;labelBackgroundColor=#ffffff;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="550" y="590" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="UEzPUAAOIrF-is8g5C7q-106" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=open;endFill=0;strokeWidth=2;" parent="UEzPUAAOIrF-is8g5C7q-74" source="UEzPUAAOIrF-is8g5C7q-77" target="hocCvkXVjEJjBnLw5MO3-1" edge="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-17" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" source="UEzPUAAOIrF-is8g5C7q-76" target="UEzPUAAOIrF-is8g5C7q-77">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <object label="Medical Report" id="UEzPUAAOIrF-is8g5C7q-76">
          <mxCell style="outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#277116;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;pointerEvents=1;shape=mxgraph.aws4.object;labelBackgroundColor=#ffffff;" parent="UEzPUAAOIrF-is8g5C7q-74" vertex="1">
            <mxGeometry x="50" y="450" width="40" height="40" as="geometry" />
          </mxCell>
        </object>
        <mxCell id="UEzPUAAOIrF-is8g5C7q-77" value="Original Reports" style="outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#277116;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;pointerEvents=1;shape=mxgraph.aws4.bucket_with_objects;labelBackgroundColor=#ffffff;" parent="UEzPUAAOIrF-is8g5C7q-74" vertex="1">
          <mxGeometry x="160" y="450" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-37" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" source="hocCvkXVjEJjBnLw5MO3-20" target="hocCvkXVjEJjBnLw5MO3-36">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-20" value="AWS Security Hub" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#DD344C;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.security_hub;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="725" width="95" height="95" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-22" value="AWS Config" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#E7157B;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.config;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="120" y="130" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-24" value="Config Bucket" style="outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#277116;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;pointerEvents=1;shape=mxgraph.aws4.bucket_with_objects;labelBackgroundColor=#ffffff;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="120" y="304" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-27" value="" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" target="hocCvkXVjEJjBnLw5MO3-24">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="140" y="168" as="sourcePoint" />
            <mxPoint x="190" y="118" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-28" value="Workspaces" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#01A88D;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.workspaces;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="359" y="290" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-30" value="" style="edgeStyle=elbowEdgeStyle;elbow=vertical;endArrow=classic;html=1;rounded=0;endSize=8;startSize=8;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" target="UEzPUAAOIrF-is8g5C7q-77">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="380" y="344" as="sourcePoint" />
            <mxPoint x="330" y="394" as="targetPoint" />
            <Array as="points">
              <mxPoint x="280" y="400" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-35" value="" style="edgeStyle=elbowEdgeStyle;elbow=vertical;endArrow=classic;html=1;rounded=0;endSize=8;startSize=8;exitX=0.5;exitY=1;exitDx=0;exitDy=0;exitPerimeter=0;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" source="hocCvkXVjEJjBnLw5MO3-28" target="UEzPUAAOIrF-is8g5C7q-78">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="750" y="250" as="sourcePoint" />
            <mxPoint x="550" y="356" as="targetPoint" />
            <Array as="points">
              <mxPoint x="560" y="400" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-39" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="UEzPUAAOIrF-is8g5C7q-74" source="hocCvkXVjEJjBnLw5MO3-36" target="hocCvkXVjEJjBnLw5MO3-38">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-36" value="Event Bridge" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#E7157B;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.eventbridge;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="752.5" y="176" width="40" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hocCvkXVjEJjBnLw5MO3-38" value="SNS" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#E7157B;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.sns;" vertex="1" parent="UEzPUAAOIrF-is8g5C7q-74">
          <mxGeometry x="600" y="176" width="40" height="40" as="geometry" />
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>


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

Hardening the Infrastructure 
•	Swap to using KMS for encryption so that all API calls against the key can be tracked via CloudTrail.
•	IP Access Controls for Work Spaces – Lock down the Ips that access the workstations.
•	Move the EC2 instance into a private subnet and set up a NAT Gateway.



## AUTHOR

<!--- Replace repository name -->
https://github.com/Greg-Kiser
