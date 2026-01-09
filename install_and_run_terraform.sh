#!/bin/bash
set -e

# Terraform version to install
TERRAFORM_VERSION="1.9.0"

echo "Checking for existing Terraform installation..."
if ! command -v terraform &> /dev/null; then
    echo "Terraform not found. Installing Terraform ${TERRAFORM_VERSION}..."
    
    # Attempt to install dependencies only if possible/necessary
    # We avoid sudo if it requires a password
    if command -v apt-get &> /dev/null; then
        if [ "$EUID" -eq 0 ]; then
             apt-get update && apt-get install -y unzip wget curl
        elif command -v sudo &> /dev/null && sudo -n true 2>/dev/null; then
             sudo apt-get update && sudo apt-get install -y unzip wget curl
        else
             echo "Cannot install system dependencies (no passwordless sudo). Verifying fallback tools..."
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
    echo "Unzipping Terraform..."
    if command -v unzip &> /dev/null; then
        unzip -o terraform.zip
    elif command -v python3 &> /dev/null; then
        echo "unzip command not found. Using python3 zipfile..."
        python3 -c "import zipfile,sys; zipfile.ZipFile('terraform.zip','r').extractall()"
    elif command -v python &> /dev/null; then
         echo "unzip command not found. Using python zipfile..."
         python -c "import zipfile,sys; zipfile.ZipFile('terraform.zip','r').extractall()"
    else
        echo "Error: unzip is missing and neither python3 nor python is available to extract the archive."
        exit 1
    fi

    # Cleanup zip
    rm terraform.zip

    # Install to local directory if cannot write to global bin
    if [ -w /usr/local/bin ]; then
        mv terraform /usr/local/bin/
        echo "Terraform installed to /usr/local/bin"
    elif [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null && sudo -n true 2>/dev/null; then
        sudo mv terraform /usr/local/bin/
        echo "Terraform installed to /usr/local/bin (via sudo)"
    else
        echo "Cannot write to /usr/local/bin. Using local directory."
        chmod +x terraform
        export PATH=$PATH:$(pwd)
        echo "Terraform installed locally in $(pwd)"
    fi

    echo "Terraform installed successfully."
else
    echo "Terraform is already installed."
fi

# Print version to verify
# We use logic to find if it's local ./terraform or global terraform
if [ -f "./terraform" ]; then
    ./terraform --version
else
    terraform --version
fi

# Note: We removed the run commands (init/plan/apply) from here because 
# they are now defined as separate stages in the Jenkinsfile.
