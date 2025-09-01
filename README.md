# Coalfire-Project
Webserver-Project

README including:
# Description

Infrastructure Overview

This Terraform configuration provisions a proof-of-concept AWS environment with network segmentation, compute resources, and security controls. The design aligns with the Coal Fire challenge requirements for deploying a web server in a secure, multi-tier architecture.

## Network
• 1 VPC – 10.1.0.0/16
• 3 subnets, spread evenly across two availability zones.
o Application, Management, Backend. All /24
o Management should be accessible from the internet
o All other subnets should NOT be accessible from internet

## Compute
• ec2 in an ASG running Linux (your choice) in the application subnet
o SG allows SSH from management ec2, allows web traffic from the Application Load Balancer. No
external traffic
o Script the installation of Apache
o 2 minimum, 6 maximum hosts
o t2.micro sized
• 1 ec2 running Linux (your choice) in the Management subnet
o SG allows SSH from a single specific IP or network space only
o Can SSH from this instance to the ASG
o t2.micro sized

## Supporting Infrastructure
• One ALB that sends web traffic to the ec2’s in the ASG.

# Deployment instructions

Make sure to put the IP and subnet of the workstation you'll be accessing the management EC2 instance from before running terraform apply. Otherwise you can pass this variable via CLI during the run.

```variable "admin_cidr" {
  description = "Your public IP/CIDR for SSH"
  type        = string
  default = ""
}

Initialize the Terraform working directory:

terraform init
Create an execution plan and verify the resources being created:

terraform plan
Apply the configuration:

terraform apply

# Improvement plan with priorities

Add ClouWatch alarms to monitor the healht of resources. Implement an S3 bucket for backups/logs activity