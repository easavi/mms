# Multi Media Sharing (MMS)

A web application for sharing multimedia content with secure user authentication and storage capabilities.

## Prerequisites

Before you begin, ensure you have the following installed:
- Java 24 or later
- Node.js 20 or later
- npm 10 or later
- PostgreSQL 16 or later
- MinIO (for local development) or AWS S3 access

## Backend Setup

### Database Setup

1. Create a PostgreSQL database:
```sql
CREATE DATABASE mms;
```

2. Configure database connection in `backend/src/main/resources/application.yml`:
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mms
    username: your_username
    password: your_password
```

### Storage Setup

#### Option 1: MinIO (Recommended for local development)

1. Start MinIO server:
```powershell
# Using Docker
docker run -p 9000:9000 -p 9001:9001 minio/minio server /data --console-address ":9001"
```

2. Configure MinIO in `application.yml`:
```yaml
storage:
  type: minio
  minio:
    url: http://localhost:9000
    access-key: minioadmin
    secret-key: minioadmin
    bucket: mms
```

#### Option 2: AWS S3

Configure S3 in `application.yml`:
```yaml
storage:
  type: s3
  s3:
    region: your_region
    bucket: your_bucket
```

### Running the Backend

1. Open the project in your IDE (IntelliJ IDEA recommended)

2. Install Maven dependencies:
   - The IDE should automatically download dependencies based on `pom.xml`
   - Alternatively, run: `mvn clean install`

3. Run the application:
   - Find `MmsApplication.java` in `backend/src/main/java/com/mms`
   - Right-click and select "Run 'MmsApplication'"
   - Or use Spring Boot Maven plugin: `mvn spring-boot:run`

The backend will start on `http://localhost:8080`

## Frontend Setup

1. Navigate to the frontend directory:
```powershell
cd frontend
```

2. Install dependencies:
```powershell
npm install
```

3. Configure the API URL in `frontend/src/config.js`:
```javascript
export const API_BASE_URL = 'http://localhost:8080/api';
```

4. Start the development server:
```powershell
npm run dev
```

The frontend will be available at `http://localhost:5173`

## Testing the Application

1. Open your browser and navigate to `http://localhost:5173`
2. Create a new account using the Sign Up form
3. Log in with your credentials
4. Try uploading and viewing media files

## API Documentation

The backend API is available at:
- Authentication: `http://localhost:8080/api/auth`
  - POST `/signup`: Create a new account
  - POST `/login`: Get authentication token
- Media: `http://localhost:8080/api/media`
  - GET `/`: List media items
  - POST `/`: Upload new media
  - GET `/{id}`: Get media details
  - DELETE `/{id}`: Delete media item

## Troubleshooting

### Common Issues

1. Database Connection:
   - Verify PostgreSQL is running
   - Check database credentials
   - Ensure database exists

2. Storage Issues:
   - For MinIO: Verify the server is running and accessible
   - For S3: Check AWS credentials and bucket permissions

3. CORS Issues:
   - Verify frontend URL is allowed in backend CORS configuration
   - Check browser console for CORS errors

### Logs

- Backend logs: Check IDE console or `logs/` directory
- Frontend logs: Browser developer console

## Development Guidelines

1. Backend:
   - Follow Java code style guidelines
   - Write unit tests for new features
   - Use appropriate HTTP methods for REST endpoints

2. Frontend:
   - Follow React best practices
   - Use TypeScript for type safety
   - Implement proper error handling

## Contributing

1. Create a feature branch
2. Implement changes
3. Write/update tests
4. Create a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
