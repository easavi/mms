# File Upload Service Documentation

## Overview

The File Upload Service automatically monitors configured storage paths and uploads new files to the backend when they are detected. This service runs in the background after successful login and provides real-time file synchronization.

## Features

### 1. Automatic File Monitoring
- Monitors all enabled storage directories for new files
- Uses platform-specific file system watchers for efficient monitoring
- Supports recursive directory monitoring
- Filters files to only upload supported media types

### 2. Supported File Types
- **Images**: .jpg, .jpeg, .png, .gif, .bmp, .webp, .svg
- **Videos**: .mp4, .avi, .mov, .wmv, .flv, .webm, .mkv, .3gp
- **Audio**: .mp3, .wav, .flac, .aac, .ogg
- **Documents**: .pdf, .doc, .docx, .txt, .rtf

### 3. Upload Queue Management
- Queues uploads to prevent overwhelming the server
- Supports up to 3 concurrent uploads
- Automatically retries failed uploads
- Provides real-time upload progress tracking

### 4. Upload Status Tracking
- **Pending**: File is queued for upload
- **Uploading**: File is currently being uploaded
- **Completed**: File uploaded successfully
- **Failed**: Upload failed with error details

### 5. Duplicate Prevention
- Tracks processed files to avoid re-uploading existing files
- Scans existing files in directories when monitoring starts
- Maintains file state across application sessions

## How It Works

### 1. Initialization
When the user logs in successfully, the service:
1. Loads all user storage configurations
2. Creates file watchers for each enabled storage path
3. Scans existing files to mark them as already processed
4. Starts monitoring for new file additions

### 2. File Detection
When a new file is added to a monitored directory:
1. Checks if the file is a supported media type
2. Verifies the file hasn't been processed before
3. Adds the file to the upload queue
4. Starts processing the queue if not already running

### 3. Upload Process
For each file in the queue:
1. Generates metadata (title, media type, etc.)
2. Creates multipart form data with file and metadata
3. Uploads to the backend API endpoint
4. Updates the upload status and progress
5. Handles errors and retries if necessary

### 4. Real-time Updates
The service provides real-time updates through:
- Upload status indicators in the main screen
- Detailed upload progress in the upload status screen
- Notification badges showing pending upload counts

## Usage

### Starting the Service
The service automatically starts after successful login. No manual intervention required.

### Monitoring Status
1. **Main Screen**: Shows upload indicator with pending count
2. **Upload Status Screen**: Detailed view of all uploads
3. **Storage Configuration**: Toggle monitoring per storage

### Managing Uploads
1. **View Progress**: Navigate to Upload Status screen
2. **Retry Failed**: Tap retry button on failed uploads
3. **Clear History**: Clear completed/failed uploads
4. **Pause Monitoring**: Disable storage in Storage Configuration

## Storage Integration

### Adding Storage
1. Go to Storage Configuration
2. Add new storage path
3. Service automatically starts monitoring if enabled
4. Existing files are scanned and marked as processed

### Enabling/Disabling
1. Toggle storage on/off in Storage Configuration
2. Service starts/stops monitoring immediately
3. Pending uploads are preserved when re-enabling

### Removing Storage
1. Delete storage in Storage Configuration
2. Service stops monitoring immediately
3. Pending uploads for that storage are cancelled

## Technical Details

### File System Monitoring
- Uses `watcher` package for cross-platform file monitoring
- Supports Windows, macOS, and Linux
- Web platform shows warning (file monitoring not supported)
- Monitors for ADD and REMOVE events

### Upload Implementation
- Uses Dio HTTP client with multipart/form-data
- Concurrent upload limit: 3 simultaneous uploads
- Automatic retry on failure
- Progress tracking for large files

### Memory Management
- Processed file tracking uses Set<String> for efficiency
- Upload queue manages memory usage
- Automatic cleanup of completed uploads
- Proper disposal of file watchers

### Error Handling
- Network errors are caught and displayed
- File access errors are logged
- Service continues operating despite individual failures
- Failed uploads can be manually retried

## Platform Support

### Desktop (Windows/macOS/Linux)
- Full file monitoring support
- Native folder picker for storage configuration
- Real-time file system events

### Web
- File monitoring not supported (browser security restrictions)
- Manual path entry for storage configuration
- Upload functionality works for manually selected files

### Mobile (Android/iOS)
- File monitoring support varies by platform
- Uses platform-specific file pickers
- May require additional permissions

## Performance Considerations

### File Scanning
- Initial scan of existing files may take time for large directories
- Files are processed in batches to avoid memory issues
- Recursive scanning depth is unlimited but monitored

### Upload Performance
- Concurrent upload limit prevents server overload
- Large files show progress indicators
- Failed uploads don't block queue processing

### Memory Usage
- Processed file list grows with directory size
- Upload queue is managed to prevent memory leaks
- File watchers are properly disposed on service shutdown

## Troubleshooting

### Service Not Starting
1. Check authentication status
2. Verify storage paths exist and are accessible
3. Check console for initialization errors

### Files Not Uploading
1. Verify file type is supported
2. Check storage is enabled
3. Review upload status screen for errors
4. Verify network connectivity

### Performance Issues
1. Reduce number of monitored directories
2. Check for very large directories
3. Monitor memory usage
4. Restart service if necessary

### Upload Failures
1. Check network connectivity
2. Verify server is running
3. Check file permissions
4. Review error messages in upload status

## API Integration

### Upload Endpoint
- **URL**: `/api/media/upload`
- **Method**: POST
- **Content-Type**: multipart/form-data
- **Authentication**: Bearer token required

### Form Data Fields
- `file`: Binary file data
- `title`: Generated from filename
- `mediaType`: Auto-detected from file
- `description`: "Auto-uploaded from {storage_path}"
- `tags`: "auto-upload,{storage_bucket}"

### Response Format
Standard MediaResponse object with:
- File URL for accessing uploaded content
- Generated unique ID
- Upload timestamp
- File metadata

## Future Enhancements

### Planned Features
1. Upload bandwidth throttling
2. Upload scheduling (time-based)
3. File filtering by size/type
4. Incremental sync for modified files
5. Conflict resolution for duplicate files

### Potential Improvements
1. Cloud storage integration (AWS S3, Google Drive)
2. Batch upload optimization
3. Upload progress notifications
4. Automatic folder organization
5. File versioning support
