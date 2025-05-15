# Expense Tracker Setup Script for Windows (PowerShell)
# This script automates the setup of the Expense Tracker application using Docker Compose on Windows.
# Run this script in PowerShell as Administrator to avoid permission issues.

# Step 1: Check Prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Green

# Check if Docker Desktop is installed and running
try {
    $dockerInfo = docker info --format '{{.ServerVersion}}' 2>$null
    if (-not $dockerInfo) {
        Write-Host "Error: Docker Desktop is not running or not installed." -ForegroundColor Red
        Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop/ and ensure it is running."
        Write-Host "After starting Docker Desktop, rerun this script."
        exit 1
    }
    Write-Host "Docker Desktop is running." -ForegroundColor Green
}
catch {
    Write-Host "Error: Docker Desktop is not installed or accessible." -ForegroundColor Red
    Write-Host "Install Docker Desktop from https://www.docker.com/products/docker-desktop/ and ensure it is running."
    exit 1
}

# Check if docker-compose is available (bundled with Docker Desktop)
try {
    $composeVersion = docker-compose --version 2>$null
    if (-not $composeVersion) {
        Write-Host "Error: docker-compose is not found." -ForegroundColor Red
        Write-Host "Docker Compose should be included with Docker Desktop. Ensure you have the latest version of Docker Desktop."
        exit 1
    }
    Write-Host "Docker Compose is available." -ForegroundColor Green
}
catch {
    Write-Host "Error: docker-compose is not found." -ForegroundColor Red
    Write-Host "Ensure Docker Desktop is installed and updated."
    exit 1
}

# Check if Git is installed
try {
    $gitVersion = git --version 2>$null
    if (-not $gitVersion) {
        Write-Host "Error: Git is not installed." -ForegroundColor Red
        Write-Host "Please install Git from https://git-scm.com/downloads and rerun this script."
        exit 1
    }
    Write-Host "Git is installed." -ForegroundColor Green
}
catch {
    Write-Host "Error: Git is not installed." -ForegroundColor Red
    Write-Host "Install Git from https://git-scm.com/downloads and rerun this script."
    exit 1
}

# Step 2: Clone the Repository
$REPO_URL = "https://github.com/Arnold-18-CS/Expense-Tracker-Web-Api.git"
Write-Host "Cloning the Expense Tracker repository..." -ForegroundColor Green

if (Test-Path -Path "Expense-Tracker-Web-Api") {
    Write-Host "Directory Expense-Tracker-Web-Api already exists. Pulling latest changes..."
    Set-Location -Path "Expense-Tracker-Web-Api"
    git pull
}
else {
    git clone $REPO_URL Expense-Tracker-Web-Api
    Set-Location -Path "Expense-Tracker-Web-Api"
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to clone or update the repository. Check the URL and your internet connection." -ForegroundColor Red
    exit 1
}

# Step 3: Start the Application with Docker Compose
Write-Host "Building and starting the application with Docker Compose..." -ForegroundColor Green
docker-compose up --build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker Compose failed. Check the logs above for details." -ForegroundColor Red
    Write-Host "Troubleshooting:"
    Write-Host " - Ensure no other process is using port 5432: netstat -aon | findstr :5432"
    Write-Host " - Stop the conflicting process: taskkill /PID <pid> /F"
    Write-Host " - Retry with: docker-compose down --volumes; docker-compose up --build"
    exit 1
}

# Step 4: Verify the Application
Write-Host "Verifying the application..." -ForegroundColor Green
Start-Sleep -Seconds 10 # Wait for services to fully start
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "Success! The Expense Tracker is running at http://localhost:8080" -ForegroundColor Green
        Write-Host "Open your browser and navigate to http://localhost:8080 to see the app with a sample expense."
        Write-Host "Instructions:"
        Write-Host " - Add expenses with a date picker (max: 15/05/2025)."
        Write-Host " - Update or delete expenses using the ✏️ and 🗑️ buttons."
    }
}
catch {
    Write-Host "Error: The application did not start correctly. Please check Docker logs." -ForegroundColor Red
    Write-Host "Manual steps: Open http://localhost:8080 in your browser to verify."
}

# Step 5: Keep the script running to show logs (user can Ctrl+C to stop)
Write-Host "Setup complete. Press Ctrl+C to stop the containers when done." -ForegroundColor Green
Write-Host "To stop containers manually, run: docker-compose down"
pause