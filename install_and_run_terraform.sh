#!/bin/bash
set -e

# Script to install Terraform via HashiCorp Official Repositories
# Requires sudo privileges

echo "Starting Terraform installation via HashiCorp apt repo..."

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ] && ! command -v sudo &> /dev/null; then
    echo "Error: This script requires root privileges or sudo to install packages."
    exit 1
fi

# Function to run with sudo if needed
run_sudo() {
    if [ "$EUID" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

echo "Updating package list and installing dependencies..."
run_sudo apt-get update
run_sudo apt-get install -y gnupg software-properties-common curl wget lsb-release

echo "Adding HashiCorp GPG key..."
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
run_sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "Verifying GPG key fingerprint..."
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "Adding HashiCorp repository..."
# Determine OS release safely
if [ -f /etc/os-release ]; then
    UBUNTU_CODENAME=$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || echo "")
fi

if [ -z "$UBUNTU_CODENAME" ]; then
    UBUNTU_CODENAME=$(lsb_release -cs)
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${UBUNTU_CODENAME} main" | run_sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Installing Terraform..."
run_sudo apt-get update
run_sudo apt-get install -y terraform

echo "Terraform installation complete."
terraform --version
