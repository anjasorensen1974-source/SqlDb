# PowerShell script to install and run SQL Server, and PostgreSQL Docker containers

# To allow Windows to execute .ps1 files, 
# In powerShell execute below once:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run this script with: .\install_sql_docker.ps1

# SQL SERVER 2022
##################
Write-Host "Setting up SQL Server 2022 container..." -ForegroundColor Green

# Pull the container image to my computer
docker pull mcr.microsoft.com/mssql/server:2022-latest

# Install and run the container 
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=skYhgS@83#aQ" -p 14333:1433 --name sql2022container --hostname sql2022 -d mcr.microsoft.com/mssql/server:2022-latest

Write-Host "SQL Server 2022 connection string:" -ForegroundColor Yellow
Write-Host "Data Source=localhost,14333;Persist Security Info=True;User ID=sa;Password=skYhgS@83#aQ;Pooling=False;Connect Timeout=30;Encrypt=False;Trust Server Certificate=False;Authentication=SqlPassword;Application Name=vscode-mssql;Connect Retry Count=1;Connect Retry Interval=10;Command Timeout=30;" -ForegroundColor Cyan


# PostgreSQL
############
Write-Host "`nSetting up PostgreSQL container..." -ForegroundColor Green

# Pull the container image to my computer
docker pull postgres

# Create a database container and run the docker 
docker run --name postgrescontainer -e POSTGRES_PASSWORD=<skYhgS@83#aQ> -d -p 5432:5432 postgres

Write-Host "PostgreSQL connection string:" -ForegroundColor Yellow
Write-Host "Server=localhost;Port=5432;User Id=postgres;Password=<skYhgS@83#aQ>;" -ForegroundColor Cyan

Write-Host "`nAll database containers have been created and started!" -ForegroundColor Green
Write-Host "You can check the status with: docker ps" -ForegroundColor White
