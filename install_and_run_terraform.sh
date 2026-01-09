#!/bin/bash
set -e

# Terraform version to install
# Note: provider.tf specifies the AWS Provider version (6.27.0), NOT the Terraform CLI version.
# We will use valid stable Terraform version 1.9.0 which is compatible.
TERRAFORM_VERSION="1.9.0"

echo "Checking for existing Terraform installation..."
if ! command -v terraform &> /dev/null; then
    echo "Terraform not found. Installing Terraform ${TERRAFORM_VERSION}..."
    
    # Install dependencies if apt-get is available (Debian/Ubuntu)
    if command -v apt-get &> /dev/null; then
        # Check if we have sudo or are root
        if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y unzip wget curl
        elif [ "$EUID" -eq 0 ]; then
            apt-get update && apt-get install -y unzip wget curl
        fi
    fi

    # Detect Architecture
    ARCH="amd64"
    if [[ $(uname -m) == "aarch64" ]]; then
        ARCH="arm64"
    fi

    # Download
    echo "Downloading Terraform..."
    wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -O terraform.zip

    # Unzip
    unzip -o terraform.zip

    # Install
    # Try to move to /usr/local/bin if possible, otherwise use local dir
    if [ -w /usr/local/bin ]; then
        mv terraform /usr/local/bin/
    elif [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then
        sudo mv terraform /usr/local/bin/
    else
        echo "Cannot write to /usr/local/bin. Using local directory and updating PATH."
        chmod +x terraform
        export PATH=$PATH:$(pwd)
    fi

    rm terraform.zip
    echo "Terraform installed successfully."
else
    echo "Terraform is already installed."
fi

terraform --version

echo "--------------------------------------"
echo "Running Terraform Init..."
terraform init

echo "--------------------------------------"
echo "Running Terraform Plan..."
terraform plan -out=tfplan

echo "--------------------------------------"
echo "Running Terraform Apply..."
terraform apply -auto-approve tfplan

echo "Terraform run completed."
