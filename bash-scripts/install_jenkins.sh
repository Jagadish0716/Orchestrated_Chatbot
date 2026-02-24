#!/bin/bash

# ------------------------------------------------------------------
# Script Name   : install_jenkins.sh
# Author        : Jagadish V
# Created Date  : 22-01-2026
# Purpose       : Automated installation of Jenkins on Ubuntu OS
# Description   : 
#   - Installs Java 21 (Jenkins prerequisite)
#   - Adds official Jenkins repository
#   - Installs and starts Jenkins service
#   - Enables Jenkins to start at boot
# ------------------------------------------------------------------

# Exit immediately if any command fails
set -e

# -----------------------------
# Step 1: Update Package Index
# -----------------------------
# Ensures we get the latest package versions from repositories
echo "Updating system packages..."
sudo apt update -y


# -----------------------------------------
# Step 2: Install Java (Jenkins Requirement)
# -----------------------------------------
# Jenkins requires Java runtime to run.
# We install OpenJDK 21 JRE (sufficient for running Jenkins).
echo "Installing OpenJDK 21..."
sudo apt install -y fontconfig openjdk-21-jre

# Verify Java installation
echo "Verifying Java installation..."
java -version


# -------------------------------------------------------
# Step 3: Create Keyrings Directory (If Not Present)
# -------------------------------------------------------
# Newer Ubuntu versions store repository keys in /etc/apt/keyrings
echo "Creating keyrings directory..."
sudo mkdir -p /etc/apt/keyrings


# -------------------------------------------------------
# Step 4: Add Official Jenkins Repository GPG Key
# -------------------------------------------------------
# Download and store Jenkins stable repository key securely
echo "Downloading Jenkins repository key..."
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key


# -------------------------------------------------------
# Step 5: Add Jenkins Repository to Source List
# -------------------------------------------------------
# This allows apt to fetch Jenkins packages from official source
echo "Adding Jenkins repository..."
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null


# ---------------------------------
# Step 6: Install Jenkins Package
# ---------------------------------
# Update package list again after adding new repository
echo "Updating package list after adding Jenkins repo..."
sudo apt update -y

# Install Jenkins
echo "Installing Jenkins..."
sudo apt install -y jenkins


# ---------------------------------------------------
# Step 7: Start and Enable Jenkins Service
# ---------------------------------------------------
# Start Jenkins immediately
echo "Starting Jenkins service..."
sudo systemctl start jenkins

# Enable Jenkins to start automatically on system boot
echo "Enabling Jenkins to start at boot..."
sudo systemctl enable jenkins


# ---------------------------------
# Step 8: Verify Jenkins Status
# ---------------------------------
# Check whether Jenkins service is active
echo "Checking Jenkins service status..."
sudo systemctl is-active jenkins


# ------------------------------
# Final Confirmation Message
# ------------------------------
echo "--------------------------------------------------"
echo "Jenkins installation completed successfully!"
echo "Access Jenkins at: http://<server-ip>:8080"
echo "Initial Admin Password Location:"
echo "/var/lib/jenkins/secrets/initialAdminPassword"
echo "--------------------------------------------------"

exit 0
