# MMS API Documentation

This folder contains Postman collection and environment files for testing the Multimedia Sharing Service (MMS) API.

## Files

- `MMS-API-Collection.postman_collection.json` - Complete Postman collection with all API endpoints
- `MMS-Development.postman_environment.json` - Environment variables for development setup
- `README.md` - This documentation file

## Setup Instructions

### 1. Import Collection and Environment

1. Open Postman
2. Click "Import" button
3. Import both files:
   - `MMS-API-Collection.postman_collection.json`
   - `MMS-Development.postman_environment.json`

### 2. Select Environment

1. In Postman, select "MMS Development Environment" from the environment dropdown (top right)
2. The environment includes these variables:
   - `baseUrl`: http://localhost:8080
   - `username`: admin
   - `password`: admin123
   - `email`: admin@example.com

### 3. Authentication Flow

1. **Login First**: Run the "Authentication > Login" request
2. **Copy Token**: From the login response, copy the `token` value
3. **Set Token**: Set the `token` environment variable with the copied value
4. **Use APIs**: All other requests will automatically use the token

## API Endpoints Overview

### Authentication
- `POST /auth/login` - Login with username/password
- `POST /auth/signup` - Register new user

### Users
- `POST /api/users` - Create user
- `GET /api/users` - Get all users
- `GET /api/users/{username}` - Get user by username
- `GET /api/users/by-email` - Get user by email
- `PUT /api/users/{username}` - Update user
- `DELETE /api/users/{username}` - Delete user
- `GET /api/users/{username}/exists` - Check if user exists
- `GET /api/users/email-exists` - Check if email exists

### Storage
- `POST /api/storage` - Create storage configuration
- `GET /api/storage` - Get all storage configurations
- `GET /api/storage/user/{username}` - Get storage by user
- `GET /api/storage/type/{type}` - Get storage by type (AWS/Minio)
- `GET /api/storage/{id}` - Get storage by ID
- `PUT /api/storage/{id}` - Update storage
- `DELETE /api/storage/{id}` - Delete storage
- `GET /api/storage/user/{username}/total-size` - Get user's total storage size
- `GET /api/storage/user/{username}/total-items` - Get user's total items

### Media
- `POST /api/media` - Create media item
- `POST /api/media/upload` - Upload media file to MinIO bucket
- `GET /api/media` - Get media with filtering and pagination
  - Query parameters:
    - `group` - Grouping method: 'month', 'day', or 'tag' (default: 'month')
    - `sortDirection` - Sort direction: 'asc' or 'desc' (default: 'desc')
    - `start` - Start date in YYYY-MM-DD format (optional)
    - `end` - End date in YYYY-MM-DD format (optional)
    - `type` - Media type: 'image', 'video', or 'file' (optional)
    - `tags` - List of tag names (optional)
    - `page` - Page number (default: 0)
    - `size` - Page size (default: 20)
- `GET /api/media/all` - Get all media without pagination
- `GET /api/media/{id}` - Get media by ID
- `PUT /api/media/{id}` - Update media
- `DELETE /api/media/{id}` - Delete media

### Tags
- `POST /api/tags` - Create tag
- `GET /api/tags` - Get all tags
- `GET /api/tags/names` - Get tag names only
- `GET /api/tags/{id}` - Get tag by ID
- `GET /api/tags/search` - Search tags
- `PUT /api/tags/{id}` - Update tag
- `DELETE /api/tags/{id}` - Delete tag

### Demo
- `POST /api/demo/create` - Create demo data
- `POST /api/demo/clear` - Clear demo data
- `GET /api/demo/info` - Get demo information

## Usage Examples

### Basic Workflow

1. **Login**:
   ```json
   POST /auth/login
   {
     "username": "admin",
     "password": "admin123"
   }
   ```

2. **Create Storage**:
   ```json
   POST /api/storage
   {
     "type": "AWS",
     "name": "My Storage",
     "bucket": "my-bucket",
     "username": "admin"
   }
   ```

3. **Create Media**:
   ```json
   POST /api/media
   {
     "name": "Sample Image",
     "mediaType": "image",
     "fileName": "sample.jpg",
     "fileUrl": "https://example.com/sample.jpg",
     "createdAt": "2025-07-28T10:00:00Z"
   }
   ```

4. **Upload Media File**:
   ```
   POST /api/media/upload
   Content-Type: multipart/form-data
   
   Form Data:
   - file: [binary file data]
   - title: "My uploaded image"
   - mediaType: "image"
   - tags: "nature,landscape" (optional, comma-separated)
   ```

5. **Filter Media**:
   ```
   GET /api/media/filter?sortBy=createdAt&sortDirection=desc&startDate=2025-01-01&endDate=2025-12-31
   ```

### Advanced Features

- **Media Filtering**: Use various filters like date ranges, media types, and tags
- **Grouping**: Group media by month, day, or tag for organized viewing
- **Search**: Full-text search across media names and metadata
- **Statistics**: Get comprehensive statistics about your media collection

## Environment Variables

The collection uses these environment variables (update as needed):

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `baseUrl` | API base URL | http://localhost:8080 |
| `token` | JWT authentication token | (set after login) |
| `username` | Default username | admin |
| `password` | Default password | admin123 |
| `email` | Default email | admin@example.com |
| `storageId` | Storage ID for testing | (set manually) |
| `storageType` | Storage type | AWS |
| `mediaId` | Media ID for testing | (set manually) |
| `tagId` | Tag ID for testing | (set manually) |
| `searchTerm` | Search term for testing | test |

## Notes

1. **Authentication Required**: Most endpoints require JWT token authentication
2. **CORS**: Make sure the backend allows requests from Postman
3. **Database**: Ensure PostgreSQL database is running and populated
4. **Storage Types**: Valid storage types are "AWS" and "Minio"
5. **Media Types**: Valid media types are "image", "video", and "file"
6. **Date Format**: Use ISO 8601 format for dates (YYYY-MM-DDTHH:mm:ssZ)

## Troubleshooting

- **401 Unauthorized**: Check if token is set correctly in environment variables
- **Connection Refused**: Ensure backend server is running on port 8080
- **Database Errors**: Check PostgreSQL connection and schema
- **Validation Errors**: Check request body format and required fields

For more detailed API documentation, refer to the OpenAPI/Swagger documentation when available.
