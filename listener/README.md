# MMS Listener Application

A Java 24 Spring Boot application that provides file monitoring and backup capabilities for the MMS (Media Management System).

## Features

### 🎧 Listener Mode
- Monitors specified folders for new and modified files
- Automatically uploads files to the MMS backend via REST APIs
- Configurable file filtering with include/exclude patterns
- Real-time console logging of all upload activities
- Supports multiple folder monitoring simultaneously

### 💾 Backup Mode
- Downloads all media files from the MMS backend
- Organizes files by media type (image, video, file, etc.)
- Concurrent downloads with configurable limits
- Progress tracking and error handling
- Saves files to a local backup directory

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

### Backup Settings
```yaml
mms:
  backup:
    download-folder: "./backups"     # Where to save downloaded files
    max-concurrent-downloads: 5      # Concurrent download limit
```

## Building

```bash
cd listener
mvn clean package
```

## Running

### Listener Mode (Default)
Monitor folders and upload files to backend:

```bash
# Using Maven
mvn spring-boot:run

# Or with mode parameter
mvn spring-boot:run -Dspring-boot.run.arguments="--mode=listener"

# Using JAR
java -jar target/mms-listener-1.0.0-SNAPSHOT.jar --mode=listener
```

### Backup Mode
Download all files from backend:

```bash
# Using Maven
mvn spring-boot:run -Dspring-boot.run.arguments="--mode=backup"

# Using JAR
java -jar target/mms-listener-1.0.0-SNAPSHOT.jar --mode=backup
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

### Backup Mode
- ✅ Downloads all media files from the backend
- ✅ Organizes files by type in subdirectories
- ✅ Avoids duplicate downloads (checks existing files)
- ✅ Concurrent downloads for better performance
- ✅ Progress reporting with file sizes
- ✅ Automatic authentication with the backend

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

### Backup Mode
```
🚀 MMS Listener Application
📋 Operation Mode: BACKUP
💾 Starting in BACKUP mode...
✅ Authentication successful for user: admin
📊 Found 150 files to backup
📁 Backup directory: D:\dev\mms\listener\backups
💾 Downloaded: 123e4567_photo.jpg (2.5 MB)
💾 Downloaded: 456f7890_video.mp4 (15.3 MB)
✅ Backup process completed!
```

## File Structure

After running backup mode, files are organized as:
```
backups/
├── image/
│   ├── 123e4567_photo1.jpg
│   └── 456f7890_photo2.png
├── video/
│   ├── 789a1234_movie1.mp4
│   └── bcde5678_movie2.avi
└── file/
    ├── 901f2345_document.pdf
    └── 6789abcd_spreadsheet.xlsx
```

## API Integration

The application uses the following MMS backend APIs:
- `POST /auth/login` - Authentication
- `POST /api/media/upload` - File upload
- `GET /api/media/all` - Get all media files
- `GET /api/media/content` - Download file content

## Error Handling

- ✅ Automatic re-authentication on token expiry
- ✅ Retry logic for failed uploads/downloads
- ✅ Graceful handling of network issues
- ✅ Detailed error logging
- ✅ Skip invalid/inaccessible files

## Stopping the Application

- **Listener Mode**: Press `Ctrl+C` to stop monitoring
- **Backup Mode**: Application exits automatically after completion

## Troubleshooting

1. **Authentication fails**: Check username/password in application.yml
2. **Folders not found**: Verify folder paths exist and are accessible
3. **Upload fails**: Ensure MMS backend is running and accessible
4. **Permission denied**: Check file/folder permissions
