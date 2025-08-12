# MMS Listener Quick Start Guide

## Prerequisites
1. Make sure the MMS Backend is running on http://localhost:8080
2. Ensure you have valid credentials (username/password) for the backend
3. Have Java 24 installed

## Quick Setup

### 1. Configure the application
Edit `src/main/resources/application.yml`:

```yaml
mms:
  backend:
    username: your_username    # Replace with your MMS username
    password: your_password    # Replace with your MMS password
  folders:
    - "C:/path/to/your/folder" # Replace with actual folder paths
```

### 2. Build the application
```bash
mvn clean package -DskipTests
```

### 3. Run in Listener Mode
```bash
java -jar target/mms-listener-1.0.0-SNAPSHOT.jar --mode=listener
```

### 4. Run in Backup Mode
```bash
java -jar target/mms-listener-1.0.0-SNAPSHOT.jar --mode=backup
```

## Testing the Listener Mode

1. Start the listener application
2. Copy a file to one of the monitored folders
3. Check the console output - you should see upload confirmation
4. Verify in the MMS backend that the file was uploaded

## Testing the Backup Mode

1. Make sure you have some files in the MMS backend
2. Run the backup mode
3. Check the `./backups` folder for downloaded files
4. Files will be organized by type (image/, video/, file/)

## Common Issues

**Authentication Failed**: Check your username/password in application.yml
**Folder Not Found**: Ensure the folder paths exist and are accessible
**Backend Not Accessible**: Verify the backend URL and that the service is running
