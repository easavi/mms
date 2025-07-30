# Testing the Media Upload API

This document provides examples for testing the new media upload API endpoint.

## Prerequisites

1. Ensure the backend is running on `http://localhost:8080`
2. MinIO server is running on `http://localhost:9000`
3. You have a valid JWT token (obtained from `/auth/login`)

## API Endpoint

- **URL**: `POST /api/media/upload`
- **Content-Type**: `multipart/form-data`
- **Authentication**: Bearer token required

## Request Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | File | Yes | The media file to upload |
| `title` | String | Yes | Display name for the media |
| `mediaType` | String | Yes | Type of media (image, video, etc.) |
| `description` | String | No | Optional description |
| `tags` | String[] | No | Array of tag names |

## Example Usage

### Using cURL

```bash
# First, login to get a token
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "your_username",
    "password": "your_password"
  }'

# Use the token from the response for subsequent requests
export TOKEN="your_jwt_token_here"

# Upload an image file
curl -X POST http://localhost:8080/api/media/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@/path/to/your/image.jpg" \
  -F "title=My Test Image" \
  -F "mediaType=image" \
  -F "description=This is a test upload" \
  -F "tags=test,upload,demo"
```

### Using Postman

1. Set the request method to `POST`
2. Set the URL to `http://localhost:8080/api/media/upload`
3. In the Headers tab, add:
   - `Authorization: Bearer YOUR_JWT_TOKEN`
4. In the Body tab:
   - Select `form-data`
   - Add the following key-value pairs:
     - `file`: Select a file from your computer
     - `title`: "My Test Image"
     - `mediaType`: "image"
     - `description`: "Test upload description"
     - `tags`: "test,upload"

### Using JavaScript/Fetch

```javascript
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('title', 'My Test Image');
formData.append('mediaType', 'image');
formData.append('description', 'Test upload');
formData.append('tags', ['test', 'upload']);

fetch('http://localhost:8080/api/media/upload', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
})
.then(response => response.json())
.then(data => console.log(data))
.catch(error => console.error('Error:', error));
```

## Response Format

On successful upload, the API returns a `MediaResponse` object:

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "My Test Image",
  "mediaType": "image",
  "fileName": "image.jpg",
  "fileUrl": "http://localhost:9000/mms-media/media/123e4567-e89b-12d3-a456-426614174000.jpg",
  "createdAt": "2025-07-30T20:45:00Z",
  "uploadedAt": "2025-07-30T20:45:00Z",
  "tags": ["test", "upload", "demo"]
}
```

## Error Handling

The API returns appropriate HTTP status codes:

- `201 Created`: File uploaded successfully
- `400 Bad Request`: Invalid request format or missing required fields
- `401 Unauthorized`: Missing or invalid JWT token
- `413 Payload Too Large`: File size exceeds the limit (100MB)
- `500 Internal Server Error`: Server error during upload or storage

## File Storage

- Files are stored in the MinIO bucket configured in `application.yml`
- Default bucket name: `mms-media`
- Files are stored with unique names in the `media/` folder
- The original filename is preserved in the database
- Public URLs are generated for accessing the files

## Supported File Types

The API accepts any file type, but common media types include:

- **Images**: jpg, jpeg, png, gif, bmp, webp, svg
- **Videos**: mp4, avi, mov, wmv, flv, webm, mkv
- **Audio**: mp3, wav, flac, aac, ogg
- **Documents**: pdf, doc, docx, txt

## Configuration

Make sure your `application.yml` includes:

```yaml
spring:
  servlet:
    multipart:
      max-file-size: 100MB
      max-request-size: 100MB

storage:
  type: minio
  minio:
    endpoint: http://localhost:9000
    accessKey: admin
    secretKey: adminmms
    bucket: mms-media
```

## Troubleshooting

1. **"Bucket does not exist"**: The MinIO service automatically creates the bucket if it doesn't exist
2. **"Access denied"**: Check MinIO credentials in `application.yml`
3. **"File too large"**: Increase the `max-file-size` in Spring configuration
4. **"Connection refused"**: Ensure MinIO server is running on the configured port
