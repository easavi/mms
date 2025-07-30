# Postman Collection Usage Guide

This guide explains how to use the updated MMS API Postman collection, specifically focusing on the new file upload functionality.

## Collection Overview

The MMS API Collection includes the following main sections:
- **Authentication**: Login and signup endpoints
- **Storage**: Storage management operations
- **Media**: Media operations including the new file upload feature
- **Tags**: Tag management operations
- **Demo**: Demo data operations

## Updated Features

### New Media Upload Endpoints

The collection now includes two upload endpoints in the Media section:

#### 1. Upload Media File (Full)
- **Purpose**: Upload a file with complete metadata
- **Method**: `POST /api/media/upload`
- **Body Type**: `form-data`
- **Parameters**:
  - `file`: Select your media file (required)
  - `title`: Display name for the media
  - `mediaType`: Type of media (image, video, audio, document)
  - `description`: Optional description
  - `tags`: Comma-separated tags (e.g., "test,upload,postman")

#### 2. Upload Media File (Minimal)
- **Purpose**: Upload a file with auto-detection of metadata
- **Method**: `POST /api/media/upload`
- **Body Type**: `form-data`
- **Parameters**:
  - `file`: Select your media file (required only)
  - Auto-detects: title from filename, mediaType from extension

## Setup Instructions

### 1. Import the Collection

1. Open Postman
2. Click "Import" in the top left
3. Select the `MMS-API-Collection.postman_collection.json` file
4. Import the environment file `MMS-Development.postman_environment.json`

### 2. Configure Environment Variables

Make sure your environment includes:
```
baseUrl: http://localhost:8080
token: (will be set after login)
username: admin
mediaId: (will be set when creating/getting media)
```

### 3. Authentication Flow

1. **First, login** using the "Authentication > Login" request
2. **Copy the token** from the response
3. **Set the token** in your environment variables
   - Or use the test script to auto-set it (see below)

### 4. Upload Files

1. **Select the upload endpoint** ("Upload Media File" or "Upload Media File (Minimal)")
2. **Choose your file**:
   - Click on the "file" parameter
   - Select "Choose Files"
   - Browse and select your media file
3. **Adjust parameters** (for the full version):
   - Modify title, mediaType, description, tags as needed
4. **Send the request**

## File Upload Examples

### Supported File Types

The API accepts various file types and automatically detects the media type:

- **Images**: `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.webp`, `.svg`
- **Videos**: `.mp4`, `.avi`, `.mov`, `.wmv`, `.flv`, `.webm`, `.mkv`, `.3gp`
- **Audio**: `.mp3`, `.wav`, `.flac`, `.aac`, `.ogg`
- **Documents**: `.pdf`, `.doc`, `.docx`, `.txt`, `.rtf`

### Example Form Data Values

For the full upload endpoint, you can use these example values:

```
file: [your-selected-file]
title: "My Test Image"
mediaType: "image"
description: "Uploaded via Postman for testing"
tags: "test,upload,postman,demo"
```

### Auto-Generated Values

When using the minimal endpoint, the system will:
- **Title**: Extract from filename (removes extension)
- **Media Type**: Detect from file extension
- **Created At**: Set to current timestamp
- **Uploaded At**: Set to current timestamp

## Response Format

Successful uploads return a `MediaResponse` object:

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "My Test Image",
  "mediaType": "image",
  "fileName": "test-image.jpg",
  "fileUrl": "http://localhost:9000/mms-media/media/123e4567-e89b-12d3-a456-426614174000.jpg",
  "createdAt": "2025-07-30T20:45:00Z",
  "uploadedAt": "2025-07-30T20:45:00Z",
  "tags": ["test", "upload", "postman", "demo"]
}
```

## Test Scripts (Optional)

You can add these test scripts to automate token handling:

### For Login Request (Tests tab):
```javascript
// Auto-set token after successful login
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set("token", response.token);
    console.log("Token set:", response.token);
}
```

### For Upload Request (Tests tab):
```javascript
// Verify upload success and save media ID
pm.test("Upload successful", function () {
    pm.response.to.have.status(201);
});

if (pm.response.code === 201) {
    const response = pm.response.json();
    pm.environment.set("mediaId", response.id);
    console.log("Media uploaded with ID:", response.id);
    console.log("File URL:", response.fileUrl);
}
```

## Troubleshooting

### Common Issues

1. **401 Unauthorized**
   - Make sure you're logged in and have a valid token
   - Check that the Authorization header is set correctly

2. **413 Payload Too Large**
   - File size exceeds 100MB limit
   - Use smaller files or adjust server configuration

3. **500 Internal Server Error**
   - Check that MinIO server is running
   - Verify MinIO configuration in application.yml

4. **File not uploading**
   - Make sure Content-Type is set to multipart/form-data
   - Verify the file parameter is set correctly

### Prerequisites

- Backend server running on `http://localhost:8080`
- MinIO server running on `http://localhost:9000`
- Valid authentication token

## Collection Updates

This collection has been updated to include:
- ✅ File upload endpoints with multipart/form-data support
- ✅ Both full and minimal upload options
- ✅ Proper authentication headers
- ✅ Example form data values
- ✅ Updated collection description

The collection is now ready for testing the complete MMS file upload workflow!
