# Tech Challenge 3: Cloud Engineer Coding Challenge 3: Infrastructure as Code with Terraform and Ansible

This project demonstrates end-to-end automated infrastructure provisioning and configuration management on AWS using **Terraform** and **Ansible**.

The pipeline provisions a public-facing EC2 instance within an AWS Default VPC, configures security groups allowing SSH (port 22) and HTTP (port 80) access, attaches an IAM instance profile, and utilizes Ansible to automatically install, configure, and serve a custom Nginx web application.

---

## Architecture & Component Design

```text
+-----------------------------------------------------------------------+
| AWS us-east-1 Region                                                  |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | Default VPC (aws_default_vpc.default)                           |  |
|  |                                                                 |  |
|  |  +-----------------------------------------------------------+  |  |
|  |  | Public Subnet (aws_default_subnet.default_az1)          |  |  |
|  |  |                                                           |  |  |
|  |  |  +-----------------------------------------------------+  |  |  |
|  |  |  | EC2 Instance (t2.micro - Ubuntu)                    |  |  |  |
|  |  |  |  - Security Group: Ports 22 & 80                    |  |  |  |
|  |  |  |  - Managed via Ansible (Nginx Service)              |  |  |  |
|  |  |  +-----------------------------------------------------+  |  |  |
|  |  |                           ^                               |  |  |
|  |  +---------------------------|-------------------------------+  |  |
|  |                              | Internet Gateway Route          |  |  |
|  +------------------------------|-----------------------------------+  |
+---------------------------------|--------------------------------------+
                                  |
                           HTTP / SSH
                                  |
                         Local Workstation
Infrastructure & Configuration Features
Terraform S3 Remote Backend: Remote state storage and state locking configuration.
Network & Security Provisioning: Explicit Internet Gateway routing table association, public IP assignment on launch, and security group rules for ports 22 and 80.
AWS IAM & Key Pair Management: EC2 instance profile binding and SSH key pair deployment using deployer_key.
Ansible Configuration Management: Automated Nginx installation, systemd service management, and Jinja2 HTML template rendering using index.html.j2.
Repository Structure
.
├── README.md
├── SUBMISSION_DOCUMENT.md
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── playbook.yaml
│   └── templates/
│       └── index.html.j2
└── terraform/
    ├── backend.tf
    ├── ec2.tf
    ├── iam.tf
    ├── outputs.tf
    ├── security_groups.tf
    ├── terraform.tfvars
    ├── variables.tf
Prerequisites

Before beginning, ensure the following tools and resources are available:

Terraform CLI (>= 1.0)
Ansible CLI
AWS CLI
AWS credentials configured locally
SSH key pair generated locally

Install Ansible on macOS:

brew install ansible

Configure AWS CLI:

aws configure

Generate an SSH key pair if one does not already exist:

ssh-keygen -t rsa

Expected files:

~/.ssh/id_rsa
~/.ssh/id_rsa.pub
Phase 1: Provision Infrastructure with Terraform

Terraform is responsible for creating the AWS infrastructure required for the web server.

1. Navigate to the Terraform directory
cd terraform
2. Initialize Terraform

This initializes the Terraform working directory and configures the remote backend.

terraform init
3. Validate the Terraform configuration
terraform validate
4. Review the infrastructure plan
terraform plan
5. Provision the infrastructure
terraform apply -auto-approve

Terraform provisions the required AWS resources, including:

VPC/networking components
Public subnet
Internet Gateway routing
Security Group
EC2 instance
IAM instance profile
SSH key configuration
6. Retrieve the EC2 public IP
terraform output -raw ec2_public_ip

Save this IP address because Ansible will use it to connect to the EC2 instance.

Phase 2: Configure the Web Server with Ansible

Terraform creates the infrastructure, while Ansible configures the operating system and application environment on the EC2 instance.

1. Navigate to the Ansible directory
cd ../ansible
2. Configure the Ansible inventory

Update inventory.ini with the public IP address returned by Terraform:

[webservers]
<YOUR_EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

Replace <YOUR_EC2_PUBLIC_IP> with the actual EC2 public IP.

3. Test connectivity

Run the Ansible ping module:

ansible all -m ping

Expected output:

SUCCESS => {"ping": "pong"}

This confirms that Ansible can establish an SSH connection to the EC2 instance.

4. Execute the deployment playbook
ansible-playbook playbook.yaml

The playbook automatically:

Connects to the EC2 instance.
Installs Nginx.
Configures the Nginx service.
Starts and enables the Nginx service.
Deploys the custom HTML page using the Jinja2 template.
Makes the web application available through HTTP.
Verification & Testing

After Ansible completes successfully, verify that the web server is accessible.

Test with curl
curl http://<YOUR_EC2_PUBLIC_IP>

Alternatively, open the following in a web browser:

http://<YOUR_EC2_PUBLIC_IP>
Expected Web Application Output
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Tech Challenge 3</title>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>Automated Deployment via Terraform & Ansible</p>
</body>
</html>
Deployment Flow

The complete deployment process follows this sequence:

Local Workstation
       |
       | terraform apply
       v
   Terraform
       |
       v
+----------------------+
| AWS Infrastructure   |
|                      |
| VPC                  |
| Public Subnet        |
| Internet Gateway     |
| Security Group       |
| IAM                  |
| EC2                  |
+----------------------+
       |
       | EC2 Public IP
       v
     Ansible
       |
       | SSH
       v
+----------------------+
| EC2 Ubuntu Server    |
|                      |
| Install Nginx        |
| Configure Nginx      |
| Deploy HTML Template |
| Start Nginx          |
+----------------------+
       |
       | HTTP :80
       v
     Browser
       |
       v
  Web Application
Terraform vs. Ansible Responsibilities
Tool	Primary Responsibility	Example
Terraform	Infrastructure provisioning	Creates EC2, VPC, subnet, security group, IAM
Ansible	Server configuration	Installs Nginx and configures the web server
AWS	Cloud infrastructure platform	Provides the underlying compute and networking
Nginx	Web server	Serves the deployed HTML application

The overall workflow is:

Terraform
    ↓
Create Infrastructure
    ↓
EC2 Server
    ↓
Ansible
    ↓
Configure Server
    ↓
Nginx
    ↓
Serve Application
Deployment Evidence

The snapshots/ directory contains screenshots demonstrating the deployment process and successful application delivery.

snapshots/
├── 01-terraform-apply.png
├── 02-terraform-outputs.png
├── 03-ansible-ping.png
├── 04-ansible-playbook.png
└── 05-webpage-browser.png

These screenshots provide evidence of:

Successful Terraform infrastructure provisioning
Terraform output containing the EC2 public IP
Successful Ansible connectivity
Successful Ansible playbook execution
Successful web application deployment
Project Summary

This challenge demonstrates a fundamental cloud engineering workflow:

Infrastructure as Code
        ↓
    Terraform
        ↓
AWS Infrastructure
        ↓
    EC2 Server
        ↓
    Ansible
        ↓
Server Configuration
        ↓
      Nginx
        ↓
Web Application

The project separates infrastructure provisioning from server configuration, demonstrating how Terraform and Ansible can work together as complementary tools in a cloud engineering environment.