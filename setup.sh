#!/bin/bash

# Expense Tracker Setup Script
# This script automates the setup of the Expense Tracker application using Docker Compose.
# It assumes a Unix-like environment (e.g., Linux, macOS, or WSL on Windows).
# Replace <repository-url> with your Git repository URL.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Step 1: Check Prerequisites
echo -e "${GREEN}Checking prerequisites...${NC}"

if ! command_exists docker; then
  echo -e "${RED}Error: Docker is not installed. Please install Docker Desktop (https://www.docker.com/products/docker-desktop/) and ensure it’s running.${NC}"
  echo "For Windows: Open Docker Desktop from the Start menu."
  echo "After installation, rerun this script."
  exit 1
fi

if ! command_exists docker-compose; then
  echo -e "${RED}Error: Docker Compose is not found. It should be included with Docker Desktop. Ensure Docker Desktop is installed and updated.${NC}"
  echo "If using an older setup, install Docker Compose separately: https://docs.docker.com/compose/install/"
  exit 1
fi

if ! command_exists git; then
  echo -e "${RED}Error: Git is not installed. Please install Git (https://git-scm.com/downloads) and rerun this script.${NC}"
  exit 1
fi

# Step 2: Clone the Repository
REPO_URL="https://github.com/Arnold-18-CS/Expense-Tracker-Web-Api.git"
echo -e "${GREEN}Cloning the Expense Tracker repository...${NC}"
if [ -d "Expense-Tracker-Web-Api" ]; then
  echo "Directory Expense-Tracker-Web-Api already exists. Pulling latest changes..."
  cd Expense-Tracker-Web-Api
  git pull
else
  git clone "$REPO_URL" Expense-Tracker-Web-Api
  cd Expense-Tracker-Web-Api
fi

if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Failed to clone or update the repository. Check the URL and your internet connection.${NC}"
  exit 1
fi

# Step 3: Start the Application with Docker Compose
echo -e "${GREEN}Building and starting the application with Docker Compose...${NC}"
docker-compose up --build

if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Docker Compose failed. Check the logs above for details.${NC}"
  echo "Troubleshooting:"
  echo " - Ensure no other process is using port 5432 (netstat -aon | findstr :5432 on Windows, then taskkill /PID <pid> /F)."
  echo " - Retry with: docker-compose down --volumes && docker-compose up --build"
  exit 1
fi

# Step 4: Verify the Application
echo -e "${GREEN}Verifying the application...${NC}"
sleep 10 # Wait for services to fully start
if curl -s http://localhost:8080 > /dev/null; then
  echo -e "${GREEN}Success! The Expense Tracker is running at http://localhost:8080${NC}"
  echo "Open your browser and navigate to http://localhost:8080 to see the app with a sample expense."
  echo "Instructions:"
  echo " - Add expenses with a date picker (max: 15/05/2025)."
  echo " - Update or delete expenses using the ✏️ and 🗑️ buttons."
else
  echo -e "${RED}Error: The application did not start correctly. Please check Docker logs.${NC}"
  echo "Manual steps: Open http://localhost:8080 in your browser to verify."
fi

# Keep the script running to show logs (user can Ctrl+C to stop)
echo -e "${GREEN}Setup complete. Press Ctrl+C to stop the containers when done.${NC}"
wait