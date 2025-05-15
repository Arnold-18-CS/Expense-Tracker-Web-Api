# Expense Tracker
A full-stack application to track expenses, built with a static HTML frontend (served via Nginx), a Node.js/Express backend, and a PostgreSQL database. The app allows users to add, update, delete, and view expenses, with a date picker restricted to today or earlier (formatted as dd/mm/yyyy). A sample expense is included for testing.

## Features

- Add, update, and delete expenses with description, amount, category, and date.
- View a table of all expenses with a total amount calculation.
- Date picker restricted to today or earlier (e.g., max date: 15/05/2025).
- Dates displayed in dd/mm/yyyy format (e.g., 15/05/2025).
- Sample expense included: "Sample Coffee", $5.00, Food, 15/05/2025.

## Prerequisites

- Docker and Docker Compose: Install Docker Desktop (includes Docker Compose) on your machine.
- Git: Install Git to clone the repository.
= A modern web browser (e.g., Chrome, Firefox).

## Setup Instructions
Follow these steps to get the Expense Tracker up and running:

1. Clone the Repository:
```bash
git clone <repository-url>
cd Expense-Tracker-Web-Api
```


2. Ensure Docker Desktop is Running:
- Open Docker Desktop and ensure it’s running on your machine.

3. Kill any other containers:
- Do this to prevent any port conflicts and resource leakage, using the command:
```bash
docker ps -a
docker stop <container-id>
```

3. Start the Application with Docker Compose:

```bash
docker-compose up --build
```

- This command builds and starts three containers:
  - frontend: Serves the static HTML frontend via Nginx (port 8080).
  = api: Runs the Node.js/Express API (port 3000).
  - db: Runs PostgreSQL (port 5432).

- The first run will take a few minutes to pull images and build the containers.


4. Access the Application:
- Open your browser and navigate to http://localhost:8080.
- You should see the Expense Tracker interface with a sample expense:
  - Description: "Sample Coffee"
  - Amount: $5.00
  - Category: Food
  - Date: 15/05/2025

## Usage

- View Expenses: The table displays all expenses, including the sample one, with a total amount at the bottom.
= Add an Expense:
  - Enter a description, amount, category (optional), and date.
  - The date picker restricts dates to today or earlier (e.g., max 15/05/2025).
  - Click "Add Expense" to save.
  
- Update an Expense:
  = Click the ✏️ (edit) button next to an expense.
  - Modify the details and click "Update".

- Delete an Expense:
  - Click the 🗑️ (delete) button next to an expense to remove it.

## Troubleshooting

- Port Conflict (5432):
  - If you see Bind for 0.0.0.0:5432 failed: port is already allocated, another process is using port 5432.
  - Stop the conflicting process:
```bash
netstat -aon | findstr :5432
taskkill /PID <pid> /F
```
  - Or modify docker-compose.yml to use a different port (e.g., "5433:5432" for the db service), then rerun docker-compose up --build.


- Database Connection Issues:
  - If the backend logs ECONNREFUSED, the database isn’t ready. The app will retry up to 10 times (5 seconds each). If it fails, check if the db container is running:
```bash
docker ps
```

  - Restart with:
```bash
docker-compose down --volumes
docker-compose up --build
```



- Fresh Start:
  - To reset the database (e.g., clear all expenses), run:
```bash
docker-compose down --volumes
docker-compose up --build
```
  - This will recreate the expenses table with the sample expense.



## Project Structure
- project/frontend/: Contains the static HTML frontend (index.html) and its Dockerfile.
- project/api: Contains the Node.js/Express backend (src/index.js, src/db.js, src/routes/expenses.js) and its Dockerfile.
- docker-compose.yml: Defines the services (frontend, backend, db).
- kubernetes/: Empty, reserved for future Kubernetes deployment.

