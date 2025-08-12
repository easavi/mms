# Local Storage Implementation

## Overview

The MMS backend has been migrated from MinIO/S3 cloud storage to a local file system storage solution. This provides simpler deployment and eliminates external dependencies.

## Changes Made

### 🗂️ **File Organization**

Files are now stored locally in the following structure:
```
buckets/
├── {username}/
│   ├── images/     # Image files (jpg, png, gif, etc.)
│   ├── videos/     # Video files (mp4, avi, mov, etc.)
│   └── files/      # Other files (documents, audio, etc.)
```

### 🔧 **Code Changes**

#### New Files:
- `LocalStorageService.java` - Implements local file storage
- `buckets/.gitkeep` - Ensures storage directory is tracked

#### Removed Files:
- `MinioStorageService.java` - Removed MinIO implementation
- `S3StorageService.java` - Removed AWS S3 implementation  
- `MinioConfig.java` - Removed MinIO configuration
- `S3Config.java` - Removed S3 configuration

#### Modified Files:
- `MediaService.java` - Updated to use local storage paths
- `application.yml` - Changed storage type from 'minio' to 'local'
- `pom.xml` - Removed MinIO and AWS S3 dependencies
- `docker-compose.yml` - Removed MinIO service

### 🎯 **Key Features**

#### Automatic Directory Creation
- Creates user-specific directories when users upload files
- Organizes files by type (images, videos, files)
- Uses authenticated user's username for folder names

#### File Management
- Generates unique UUIDs for file names to prevent conflicts
- Preserves original file extensions
- Stores original filenames in database

#### Content Delivery
- Files served directly through `/api/media/content` endpoints
- Proper MIME type detection and headers
- Caching headers for better performance

### 🔑 **Authentication Integration**

- Uses Spring Security context to get current user
- Creates user-specific folders automatically
- Falls back to "anonymous" for unauthenticated requests

### 📁 **Storage Path Examples**

#### Upload Flow:
1. User "admin" uploads "vacation.jpg"
2. File stored as: `buckets/admin/images/uuid-123.jpg`
3. Database stores URL: `/api/media/content?bucket=local&fileId=admin/images/uuid-123.jpg`
4. Frontend requests file using the stored URL

#### File Retrieval:
1. Frontend requests: `/api/media/content/media-uuid`
2. Service looks up media record by ID
3. Extracts file path from stored URL
4. Returns file content with proper headers

## Configuration

### Application Properties
```yaml
storage:
  type: local
  local:
    base-path: ./buckets  # Relative to application working directory
```

### Directory Permissions
- Application needs read/write access to `buckets/` directory
- Directories are created automatically with default permissions

## API Endpoints

### File Upload
```
POST /api/media/upload
Content-Type: multipart/form-data

Parameters:
- file: Required - The media file
- title: Required - Title for the media
- mediaType: Required - Type (image, video, file)
- description: Optional - Description
- tags: Optional - Tags (can be multiple)
```

### File Retrieval
```
GET /api/media/content/{mediaId}
Returns: File content with proper MIME type headers

GET /api/media/content?bucket={bucket}&fileId={path}
Returns: File content by direct path
```

## Advantages

✅ **Simplified Deployment** - No external services required  
✅ **Reduced Dependencies** - Fewer external libraries  
✅ **Cost Effective** - No cloud storage costs  
✅ **Better Performance** - Direct file system access  
✅ **Easier Development** - No need for MinIO/S3 setup  
✅ **Data Control** - Files stored locally  

## Migration Notes

### From Previous MinIO Setup:
1. Existing file URLs in database may need migration
2. Old MinIO data can be manually copied to new structure
3. Update any frontend code expecting MinIO URLs

### Backup Strategy:
- Include `buckets/` directory in backup procedures
- Consider file storage size in backup planning
- Implement file cleanup for deleted media records

## Development Notes

### Testing:
- Start backend application
- Upload files through API or frontend
- Check `buckets/` directory for proper organization
- Verify file retrieval through content endpoints

### Debugging:
- Enable debug logging: `logging.level.com.mms: DEBUG`
- Check console output for storage operations
- Verify file permissions on storage directory

### Production Considerations:
- Configure proper base-path for production
- Set up file storage monitoring
- Implement file rotation/cleanup if needed
- Consider storage capacity planning
