Tech Challenge 3: Cloud Engineer Coding Challenge 3: Infrastructure as Code with Terraform and Ansible
📌 Project Overview
This project demonstrates end-to-end automated infrastructure provisioning and configuration management on AWS using Terraform and Ansible.

The pipeline provisions a public-facing EC2 instance within an AWS Default VPC, configures security groups allowing SSH (port 22) and HTTP (port 80) access, attaches an IAM instance profile, and utilizes Ansible to automatically install, configure, and serve a custom Nginx web application.

🏗️ Architecture & Component Design
Plaintext
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
  |  |  |  |  - Security Group: Ports 22 & 80                      |  |  |  |
  |  |  |  |  - Managed via Ansible (Nginx Service)               |  |  |  |
  |  |  |  +-----------------------------------------------------+  |  |  |
  |  |  |                           ^                               |  |  |
  |  |  +---------------------------|-------------------------------+  |  |
  |  |                              | (Internet Gateway Route)          |  |
  |  +------------------------------|-----------------------------------+  |
  +---------------------------------|--------------------------------------+
                                    |
                            [ HTTP / SSH ]
                                    |
                           Local Workstation
📁 Repository Structure
Plaintext
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
🛠️ Complete Setup & Prerequisites Instructions
1. Local Workstation Requirements
Ensure the following CLI tools are installed on your workstation:

Terraform CLI: brew install terraform (>= 1.0)

Ansible CLI: brew install ansible

AWS CLI: brew install awscli

2. AWS Authentication & SSH Setup
Configure AWS Credentials:

Bash
aws configure
Provide your AWS Access Key ID, AWS Secret Access Key, and set default region to us-east-1.

Generate SSH Key Pair:
If you do not have an existing SSH key pair at ~/.ssh/id_rsa, generate one:

Bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/id_rsa -N ""
🔍 Code Base & Infrastructure Breakdown
1. Terraform Infrastructure Definitions (terraform/)
backend.tf: Configures remote state storage in an S3 bucket to ensure state persistence and team collaboration.

vpc.tf: Sets up public networking components:

aws_default_vpc: References the default AWS VPC.

aws_default_subnet: Enables map_public_ip_on_launch = true so the instance automatically receives a reachable public IPv4 address.

aws_internet_gateway & aws_route_table: Configures explicit routes mapping 0.0.0.0/0 through the Internet Gateway to grant external access.

security_groups.tf: Defines inbound/outbound firewall rules:

Inbound TCP Port 22 (SSH) from 0.0.0.0/0 for remote management via Ansible.

Inbound TCP Port 80 (HTTP) from 0.0.0.0/0 for public web traffic.

Outbound 0.0.0.0/0 (all traffic) allowing the EC2 instance to download OS packages and Nginx updates.

ec2.tf: Provisions the Ubuntu virtual machine:

data.aws_ami.ubuntu: Dynamically queries the latest official Ubuntu AMI ID.

aws_key_pair: Uploads your local ~/.ssh/id_rsa.pub public key to AWS for secure SSH authentication.

vpc_security_group_ids: Binds the security group ID directly to the instance network interface.

outputs.tf: Exports dynamic deployment values, specifically ec2_public_ip, using terraform output -raw ec2_public_ip.

2. Ansible Configuration Management (ansible/)
ansible.cfg: Controls default execution behaviors, overriding strict host key checking to enable seamless SSH execution in automated pipelines:

Ini, TOML
[defaults]
inventory = inventory.ini
remote_user = ubuntu
private_key_file = ~/.ssh/id_rsa
host_key_checking = False
inventory.ini: Maps target hosts for playbooks:

Ini, TOML
[webservers]
<EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
playbook.yaml Explained Step-by-Step:

YAML
---
- name: Configure Web Server on EC2 Instance
  hosts: webservers
  become: true
  tasks:
    # Step 1: Refresh local apt metadata and keep cache fresh for 1 hour
    - name: Update apt repository cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    # Step 2: Install Nginx package via Ubuntu package manager
    - name: Install Nginx
      apt:
        name: nginx
        state: present

    # Step 3: Ensure systemd manages Nginx service lifecycle (started & enabled at boot)
    - name: Ensure Nginx service is started and enabled
      service:
        name: nginx
        state: started
        enabled: yes

    # Step 4: Process Jinja2 template and place rendered HTML at web root path
    - name: Deploy Hello World web page template
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: '0644'
🚀 Execution & Deployment Steps
Phase 1: Provision Infrastructure with Terraform
Navigate to the terraform/ directory:

Bash
cd terraform
Initialize provider plugins and backend storage:

Bash
terraform init
Provision resources:

Bash
terraform apply -auto-approve
Retrieve the assigned public IP:

Bash
terraform output -raw ec2_public_ip
Phase 2: Configure Web Server with Ansible
Navigate to the ansible/ directory:

Bash
cd ../ansible
Update inventory.ini with your provisioned EC2 public IP address.

Test SSH connectivity via Ansible ping:

Bash
ansible all -m ping
Expected Output: 54.x.x.x | SUCCESS => {"changed": false, "ping": "pong"}

Execute the deployment playbook:

Bash
ansible-playbook playbook.yaml
🧪 Verification & Testing
Terminal HTTP Test:

Bash
curl http://<YOUR_EC2_PUBLIC_IP>
Browser Verification: Open http://<YOUR_EC2_PUBLIC_IP> in your web browser.