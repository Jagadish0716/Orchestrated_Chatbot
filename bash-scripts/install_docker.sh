#!/bin/bash

# ------------------------------------------------------------------
# Script Name   : install_docker.sh
# Author        : Jagadish V
# Created Date  : 20-02-2026
# Purpose       : Install Docker on Ubuntu using official script
# Description   :
#   - Downloads official Docker installation script
#   - Installs Docker Engine
#   - Starts and enables Docker service
#   - Adds current user to docker group
#   - Verifies Docker installation
# ------------------------------------------------------------------

# Exit immediately if any command fails
set -e

echo "Updating system packages..."
sudo apt update -y


# ---------------------------------------------------
# Step 1: Download Official Docker Installation Script
# ---------------------------------------------------
# The official convenience script is provided by Docker
echo "Downloading Docker installation script..."
curl -fsSL https://get.docker.com -o get-docker.sh


# ---------------------------------------------------
# Step 2: Execute Docker Installation Script
# ---------------------------------------------------
# This script installs Docker Engine, CLI, and containerd
echo "Installing Docker..."
sudo sh get-docker.sh


# ---------------------------------------------------
# Step 3: Start and Enable Docker Service
# ---------------------------------------------------
echo "Starting Docker service..."
sudo systemctl start docker

echo "Enabling Docker to start at boot..."
sudo systemctl enable docker


# ---------------------------------------------------
# Step 4: Add Current User to Docker Group
# ---------------------------------------------------
# This allows running docker commands without sudo
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER


# ---------------------------------------------------
# Step 5: Verify Docker Installation
# ---------------------------------------------------
echo "Verifying Docker installation..."
docker --version

echo "Checking Docker service status..."
sudo systemctl is-active docker


# ---------------------------------------------------
# Final Message
# ---------------------------------------------------
echo "--------------------------------------------------"
echo "Docker installation completed successfully!"
echo "Please logout and login again to apply group changes."
echo "Test with: docker run hello-world"
echo "--------------------------------------------------"

exit 0