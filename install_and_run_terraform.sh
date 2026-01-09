#!/bin/bash
set -e

# Script to install Terraform locally (no sudo required)
# Installs version 1.14.3

TERRAFORM_VERSION="1.14.3"

echo "Detecting architecture..."
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    TF_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    TF_ARCH="arm64"
else
    echo "Unix architecture $ARCH not explicitly supported by this script (assuming amd64)."
    TF_ARCH="amd64"
fi

echo "Detected architecture: $TF_ARCH"

echo "Downloading Terraform v${TERRAFORM_VERSION}..."
curl -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"

echo "Unzipping Terraform..."
if command -v unzip >/dev/null 2>&1; then
    unzip -o "terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"
else
    echo "Error: 'unzip' command not found. Please ensure unzip is installed on the agent."
    exit 1
fi

echo "Cleaning up zip file..."
rm "terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"

echo "Making terraform executable..."
chmod +x terraform

echo "Terraform installation complete. Local version:"
./terraform --version
