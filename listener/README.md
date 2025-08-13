# MMS Listener Application

A Java 24 Spring Boot application that provides file monitoring capabilities for the MMS (Media Management System).

## Features

### 🎧 Listener Mode
- Monitors specified folders for new and modified files
- Automatically uploads files to the MMS backend via REST APIs
- Configurable file filtering with include/exclude patterns
- Real-time console logging of all upload activities
- Supports multiple folder monitoring simultaneously

## Requirements

- Java 24
- Maven 3.6+
- Running MMS Backend (default: http://localhost:8080)

## Configuration

Edit `src/main/resources/application.yml` to configure:

### Backend Connection
```yaml
mms:
  backend:
    url: http://localhost:8080    # MMS backend URL
    username: admin               # API username
    password: admin123           # API password
```

### Folders to Monitor (Listener Mode)
```yaml
mms:
  folders:
    - "D:/dev/mms/images"        # Add your folders here
    - "D:/dev/mms/documents"
    - "/path/to/another/folder"
```

### File Filtering
```yaml
mms:
  file-patterns:
    include: "\\.(jpg|jpeg|png|gif|bmp|mp4|avi|mov|wmv|pdf|doc|docx|txt)$"
    exclude: "\\.(tmp|temp|log)$"
```

## Building

```bash
cd listener
mvn clean package
```

## Running

### Listener Mode
Monitor folders and upload files to backend:

```bash
# Using Maven
mvn spring-boot:run

# Or with mode parameter
mvn spring-boot:run -Dspring-boot.run.arguments="--mode=listener"

# Using JAR
java -jar target/mms-listener-1.0.0-SNAPSHOT.jar
```

## Operation Modes

### Listener Mode
- ✅ Monitors configured folders continuously
- ✅ Uploads new files immediately when detected
- ✅ Uploads modified files when changes are detected
- ✅ Logs deleted files (no action taken on backend)
- ✅ Automatic authentication with the backend
- ✅ Retry logic for failed uploads
- ✅ File type detection (image, video, audio, file)

## Console Output Examples

### Listener Mode
```
🚀 MMS Listener Application
📋 Operation Mode: LISTENER
🎧 Starting file listener for folders:
  📁 D:/dev/mms/images
✅ Authentication successful for user: admin
📂 Watching: D:\dev\mms\images
✅ File listener started successfully. Watching for file changes...
📝 New file detected: photo.jpg
📤 File uploaded successfully: photo.jpg (ID: 123e4567-e89b-12d3-a456-426614174000)
```

## API Integration

The application uses the following MMS backend APIs:
- `POST /auth/login` - Authentication
- `POST /api/media/upload` - File upload

## Error Handling

- ✅ Automatic re-authentication on token expiry
- ✅ Retry logic for failed uploads
- ✅ Graceful handling of network issues
- ✅ Detailed error logging
- ✅ Skip invalid/inaccessible files

## Stopping the Application

- **Listener Mode**: Press `Ctrl+C` to stop monitoring

## Troubleshooting

1. **Authentication fails**: Check username/password in application.yml
2. **Folders not found**: Verify folder paths exist and are accessible
3. **Upload fails**: Ensure MMS backend is running and accessible
4. **Permission denied**: Check file/folder permissions
