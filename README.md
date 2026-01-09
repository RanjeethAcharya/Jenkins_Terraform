# Terraform Jenkins Infrastructure Pipeline

This repository contains a Jenkins pipeline and Terraform configuration to automate the provisioning of AWS infrastructure. The pipeline manages the lifecycle of the infrastructure, from initialization to application and destruction.

## 🚀 Overview

The project automatically provisions:
- An **AWS VPC** with a public subnet.
- An **Internet Gateway** and Route Table for public access.
- A **Security Group** allowing traffic on ports `22` (SSH), `80` (HTTP), `8080`, `9090`, `3000`, and `5000`.
- An **EC2 Instance** (Ubuntu `t3.micro`) hosting an Nginx web server with a custom "Hello from Terraform" page.

## 🛠️ Tech Stack

- **Terraform** (v1.14.3): IaC tool for provisioning.
- **Jenkins**: CI/CD automation server.
- **AWS**: Cloud provider (VPC, EC2, SG, etc.).
- **Bash**: Scripting for local tool installation.

## 📂 Repository Structure

- `Jenkinsfile`: Defines the CI/CD pipeline stages (Checkout, Install, Init, Plan, Apply, Destroy).
- `install_and_run_terraform.sh`: Bootstrapping script to download and install Terraform locally on the Jenkins agent (no sudo required).
- `main.tf`: Core infrastructure definitions (VPC, Subnet, Security Group, EC2).
- `provider.tf`: AWS provider configuration.
- `output.tf`: Outputs public IP, Instance ID, and VPC ID after deployment.
- `variables.tf`: Variable definitions (currently commented out/unused).
- `terraform.tfvars`: Variable values (if applicable).

## ⚡ Pipeline Stages

1.  **Checkout**: Pulls the latest code from the SCM.
2.  **Install and Run Terraform**: Downloads Terraform 1.14.3 locally to the workspace.
3.  **Terraform Init**: Initializes the backend and provider plugins.
4.  **Terraform Plan**: Generates an execution plan (`tfplan`) showing pending changes.
5.  **Terraform Apply**: Applies the plan to create/update resources (Requires Manual Approval).
6.  **Cleanup**: Optional stage to destroy resources if requested (Interactive Input).

## ⚙️ Prerequisites

- **Jenkins** server up and running.
- **AWS Credentials** configured in Jenkins:
    - ID: `aws-access-key-id`
    - ID: `aws-secret-access-key`
- **Internet Access** for the Jenkins agent to download Terraform and AWS plugins.

## 🏃 Usage

1.  Create a **Pipeline Job** in Jenkins.
2.  Point it to this repository.
3.  Ensure the "Pipeline script from SCM" is selected.
4.  Build the job.
5.  **Approve** the "Apply" stage when prompted to provision infrastructure.
6.  **Choose** "Destroy" or "Keep" in the Cleanup stage to manage resource lifecycle.

## 🔍 Outputs

After a successful apply, Terraform will output:
- `instance_IP`: The public IP of the created EC2 instance.
- `instance_id`: The AWS ID of the instance.
- `vpc_id`: The ID of the created VPC.

Access the web server at: `http://<instance_IP>`

## 📜 License

This project is open-source and available for reference and usage.
