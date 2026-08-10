
# Tech Challenge 3: Cloud Engineer Coding Challenge 3: Infrastructure as Code with Terraform and Ansible

##  Project Overview

This project demonstrates end-to-end automated infrastructure provisioning and configuration management on AWS using **Terraform** and **Ansible**.

The pipeline provisions a public-facing EC2 instance within an AWS Default VPC, configures security groups allowing SSH (port 22) and HTTP (port 80) access, attaches an IAM instance profile, and utilizes Ansible to automatically install, configure, and serve a custom **Nginx** web application.

---

## 🏗️ Architecture & Component Design

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
    |  |  |  |  - Managed via Ansible (Nginx Service)             |  |  |  |
    |  |  |  +-----------------------------------------------------+  |  |  |
    |  |  |                           ^                               |  |  |
    |  |  +---------------------------|-------------------------------+  |  |
    |  |                              | (Internet Gateway Route)      |  |  |
    |  +------------------------------|-----------------------------------+  |
    +---------------------------------|--------------------------------------+
                                      |
                              [ HTTP / SSH ]
                                      |
                             Local Workstation

---

##  Repository Structure

    .
    ├── README.md
    ├── SUBMISSION_DOCUMENT.md
    ├── ansible/
    │   ├── ansible.cfg
    │   ├── inventory.ini
    │   ├── playbook.yaml
    │   └── templates/
    │       └── index.html.j2
    ├── snapshots/
    │   ├── 01-terraform-apply.png
    │   ├── 02-terraform-outputs.png
    │   ├── 03-ansible-ping.png
    │   ├── 04-ansible-playbook.png
    │   └── 05-webpage-browser.png
    └── terraform/
        ├── backend.tf
        ├── ec2.tf
        ├── iam.tf
        ├── outputs.tf
        ├── security_groups.tf
        ├── terraform.tfvars
        ├── variables.tf
        └── vpc.tf

---

##  Complete Setup & Prerequisites

### 1. Local Workstation Requirements

Ensure the following CLI tools are installed:

- Terraform CLI (>= 1.0)
- Ansible CLI
- AWS CLI
- SSH client

For macOS:

    brew install terraform
    brew install ansible
    brew install awscli

---

### 2. AWS Authentication & SSH Setup

Configure AWS credentials:

    aws configure

Provide:

- AWS Access Key ID
- AWS Secret Access Key
- Default region: `us-east-1`

### Generate SSH Key Pair

If you do not already have an SSH key pair at `~/.ssh/id_rsa`, generate one:

    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/id_rsa -N ""

The public key (`id_rsa.pub`) is uploaded to AWS by Terraform and is used to authenticate SSH connections to the EC2 instance.

---

#  Code Base & Infrastructure Breakdown

## 1. Terraform Infrastructure Definitions

The Terraform configuration is located in the `terraform/` directory.

### `backend.tf`

Configures remote state storage in an S3 bucket to ensure Terraform state persistence and support team collaboration.

### `vpc.tf`

Configures the public networking components:

- References the AWS Default VPC using `aws_default_vpc`.
- Configures the default subnet with `map_public_ip_on_launch = true`.
- Configures an Internet Gateway.
- Configures a route table with a `0.0.0.0/0` route through the Internet Gateway.

This provides the EC2 instance with internet connectivity.

### `security_groups.tf`

Defines the EC2 firewall rules:

- Inbound TCP port `22` (SSH) from `0.0.0.0/0` for remote management via Ansible.
- Inbound TCP port `80` (HTTP) from `0.0.0.0/0` for public web traffic.
- Outbound `0.0.0.0/0` allowing the EC2 instance to download OS packages and Nginx updates.

### `ec2.tf`

Provisions the Ubuntu EC2 instance:

- Dynamically queries the latest official Ubuntu AMI ID using `data.aws_ami.ubuntu`.
- Creates an AWS key pair using the local public key at `~/.ssh/id_rsa.pub`.
- Associates the security group with the EC2 instance.
- Deploys the EC2 instance into the configured public subnet.

### `outputs.tf`

Exports dynamic deployment values, specifically the EC2 public IP address.

Retrieve the IP using:

    terraform output -raw ec2_public_ip

---

# 2. Ansible Configuration Management

The Ansible configuration is located in the `ansible/` directory.

## `ansible.cfg`

Controls default Ansible execution behavior:

    [defaults]
    inventory = inventory.ini
    remote_user = ubuntu
    private_key_file = ~/.ssh/id_rsa
    host_key_checking = False

## `inventory.ini`

Defines the EC2 instance that Ansible will manage:

    [webservers]
    <EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

Replace `<EC2_PUBLIC_IP>` with the public IP returned by Terraform.

---

## `playbook.yaml`

The Ansible playbook performs the server configuration:

    ---
    - name: Configure Web Server on EC2 Instance
      hosts: webservers
      become: true

      tasks:

        # Step 1: Refresh local apt metadata
        - name: Update apt repository cache
          apt:
            update_cache: yes
            cache_valid_time: 3600

        # Step 2: Install Nginx
        - name: Install Nginx
          apt:
            name: nginx
            state: present

        # Step 3: Start Nginx and enable it at boot
        - name: Ensure Nginx service is started and enabled
          service:
            name: nginx
            state: started
            enabled: yes

        # Step 4: Deploy the custom HTML page
        - name: Deploy Hello World web page template
          template:
            src: templates/index.html.j2
            dest: /var/www/html/index.html
            owner: www-data
            group: www-data
            mode: '0644'

The playbook:

1. Updates the Ubuntu package repository.
2. Installs Nginx.
3. Starts Nginx and enables it at system boot.
4. Uses a Jinja2 template to deploy the custom web page.

---

#  Execution & Deployment

## Phase 1: Provision Infrastructure with Terraform

Navigate to the Terraform directory:

    cd terraform

Initialize Terraform and the remote backend:

    terraform init

Provision the AWS infrastructure:

    terraform apply -auto-approve

Retrieve the EC2 public IP address:

    terraform output -raw ec2_public_ip

---

## Phase 2: Configure Web Server with Ansible

Navigate to the Ansible directory:

    cd ../ansible

Update `inventory.ini` with the EC2 public IP address:

    [webservers]
    <EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

Test SSH connectivity using Ansible:

    ansible all -m ping

Expected output:

    54.x.x.x | SUCCESS => {"changed": false, "ping": "pong"}

Execute the deployment playbook:

    ansible-playbook playbook.yaml

---

#  Verification & Testing

## Terminal HTTP Test

Verify that Nginx is serving the application:

    curl http://<YOUR_EC2_PUBLIC_IP>

Expected response:

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

## Browser Verification

Open the following URL in a web browser:

    http://<YOUR_EC2_PUBLIC_IP>

The custom **Tech Challenge 3** web page should be displayed.

---

#  Deployment Flow

The overall deployment process follows this sequence:

    Local Workstation
           |
           | Terraform
           v
    AWS Infrastructure
           |
           v
    EC2 Instance
           |
           | SSH
           v
        Ansible
           |
           v
    Install & Configure Nginx
           |
           v
    Deploy HTML Template
           |
           v
    Public Web Application

---

#  Project Objectives

This challenge demonstrates the separation of responsibilities between:

- **Terraform** — Infrastructure provisioning
- **AWS** — Cloud infrastructure and networking
- **EC2** — Compute environment
- **Security Groups** — Network access control
- **SSH** — Secure remote access
- **Ansible** — Server configuration and application setup
- **Nginx** — Web server
- **Jinja2** — Dynamic configuration/template rendering

The result is an automated workflow in which Terraform creates the infrastructure and Ansible configures the server and deploys the web application.