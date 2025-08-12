# Postman Collection Updates

## Overview
The MMS API Collection has been updated to accurately reflect the actual REST controllers implemented in the backend codebase, and includes automatic authentication handling.

## 🆕 **Auto-Authentication Feature**

### Pre-Request Script (Collection Level)
- **Automatic Login**: Before each request (except auth endpoints), the collection automatically performs login if no token exists
- **Token Management**: Stores and reuses JWT tokens across requests
- **Smart Skipping**: Skips auto-login for `/auth/` endpoints to avoid infinite loops
- **Configurable Credentials**: Uses collection variables for username/password

### Post-Request Script (Collection Level)
- **Token Expiration Handling**: Automatically clears tokens on 401/403 responses
- **Re-authentication**: Forces new login on next request after auth failures
- **Token Updates**: Automatically stores tokens from successful login responses

### Collection Variables Added
- `password`: Default login password (admin123)
- `bucketName`: Default bucket name (mms)
- `fileId`: For content retrieval endpoints

## Changes Made

### 1. MediaController Updates
- **Updated Upload Endpoint**: Fixed `/api/media/upload` to use individual tag parameters instead of comma-separated string
- **Added Test Upload Endpoint**: Added `/api/media/test-upload` for debugging file uploads
- **Added Content Endpoints**: 
  - `/api/media/content/{id}` - Get media content by media ID
  - `/api/media/content?bucket={bucket}&fileId={fileId}` - Get media content by bucket and file ID
- **Updated Main GET Endpoint**: Fixed `/api/media` parameters to match actual controller implementation
- **Removed Non-existent Endpoints**: Removed endpoints that don't exist in the actual controller:
  - Search, grouping, filtering, statistics, and validation endpoints

### 2. StorageController Updates
- **Added Missing Endpoints**:
  - `/api/storage/{bucket}/quantity` - Get storage quantity by bucket
  - `/api/storage/{bucket}/size` - Get storage size by bucket

### 3. TagController Updates
- **Fixed Search Parameter**: Changed search parameter from `q` to `name` in `/api/tags/search`

### 4. ValidationController (New)
- **Added Complete ValidationController Section**:
  - `/api/validation/health` - System health check
  - `/api/validation/features` - Advanced features validation
  - `/api/validation/info` - Validation API information

### 5. Removed Sections
- **Demo Controller**: Removed completely as no DemoController exists in the codebase

### 6. Updated Variables
- Added `bucketName` variable (default: "mms")
- Added `fileId` variable for content endpoints

## Controller Mappings

### Verified Controllers:
1. **AuthController** (`/auth`) ✅
   - POST `/auth/signup`
   - POST `/auth/login`

2. **UserController** (`/api/users`) ✅
   - All endpoints verified and match

3. **StorageController** (`/api/storage`) ✅
   - All endpoints verified, added missing bucket endpoints

4. **MediaController** (`/api/media`) ✅
   - Major updates to match actual implementation
   - Added new content retrieval endpoints

5. **TagController** (`/api/tags`) ✅
   - Fixed search parameter name

6. **ValidationController** (`/api/validation`) ✅ (New)
   - Complete new section added

## Testing Recommendations

### 🚀 **Quick Start with Auto-Authentication**
1. **Import the Collection**: Import the updated JSON file into Postman
2. **Set Base URL**: Update the `baseUrl` variable if needed (default: http://localhost:8080)
3. **Configure Credentials**: Update `username` and `password` variables if different from defaults
4. **Start Testing**: Run any endpoint - authentication will happen automatically!

### 📝 **Manual Testing Steps**
1. **File Upload Testing**: Use the updated upload endpoint with proper tag parameters
2. **Content Retrieval**: Test both content endpoints for media file access
3. **Validation Testing**: Use validation endpoints to verify system health
4. **Storage Testing**: Test new bucket-specific endpoints

### 🔧 **Authentication Configuration**
- **Default Credentials**: admin/admin123
- **Custom Credentials**: Update collection variables `username` and `password`
- **Token Management**: Automatic - no manual intervention needed
- **Debug Logging**: Check Postman console for auto-login status messages

### 🛠 **Troubleshooting**
- **Login Issues**: Check console for error messages
- **Token Problems**: Manually clear the `token` variable to force re-login
- **Auth Loops**: Ensure auth endpoints don't have the auto-login logic triggered

## Testing Recommendations

1. **File Upload Testing**: Use the updated upload endpoint with proper tag parameters
2. **Content Retrieval**: Test both content endpoints for media file access
3. **Validation Testing**: Use validation endpoints to verify system health
4. **Storage Testing**: Test new bucket-specific endpoints

## Notes

- All endpoints now accurately reflect the actual Spring Boot controller implementations
- Collection maintains backward compatibility where possible
- Authentication headers preserved for all protected endpoints
- Parameter descriptions added for better usability
