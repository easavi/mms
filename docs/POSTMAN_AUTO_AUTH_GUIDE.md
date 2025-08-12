# Postman Auto-Authentication Guide

## 🎯 How It Works

The updated MMS API Collection includes **automatic authentication** that handles login and token management seamlessly.

### ✨ Features

1. **Zero-Click Authentication**: Just run any endpoint, authentication happens automatically
2. **Smart Token Management**: Stores and reuses JWT tokens
3. **Auto-Recovery**: Handles token expiration and re-authenticates automatically
4. **Debug Friendly**: Console logging for troubleshooting

### 🔧 Configuration

#### Collection Variables
| Variable | Default Value | Description |
|----------|---------------|-------------|
| `baseUrl` | `http://localhost:8080` | API base URL |
| `username` | `admin` | Login username |
| `password` | `admin123` | Login password |
| `token` | `""` | JWT token (auto-managed) |

#### Customization
To use different credentials:
1. Go to **Collection Variables** in Postman
2. Update `username` and `password` values
3. Save changes

### 🚀 Usage

1. **Import Collection**: Import the `MMS-API-Collection.postman_collection.json` file
2. **Verify Settings**: Check that `baseUrl` points to your running backend
3. **Test Any Endpoint**: Choose any endpoint and click "Send"
4. **Watch Magic Happen**: 
   - First request triggers auto-login
   - Token gets stored automatically
   - Subsequent requests use the stored token

### 📋 Example Flow

```
1. User clicks "Send" on "Get All Media"
2. Pre-request script detects no token exists
3. Script automatically calls POST /auth/login
4. Login response provides JWT token
5. Token gets stored in collection variables
6. Original "Get All Media" request proceeds with token
7. Future requests reuse the stored token
```

### 🛠 Troubleshooting

#### Problem: "Login failed" in console
**Solution**: 
- Check if backend is running on the correct URL
- Verify `username` and `password` variables are correct
- Ensure `/auth/login` endpoint is accessible

#### Problem: Requests still return 401
**Solution**:
- Check Postman console for error messages
- Manually clear the `token` variable to force fresh login
- Verify the backend JWT implementation is working

#### Problem: Infinite login loops
**Solution**:
- Check that auth endpoints (`/auth/*`) are excluded from auto-login
- Verify the pre-request script logic

### 📊 Console Messages

Watch the Postman console for these messages:

- ✅ `"Auto-login successful, token stored"` - Authentication worked
- ℹ️ `"Token already exists, skipping auto-login"` - Using cached token
- ⚠️ `"Authentication failed (401/403), clearing token"` - Token expired, will re-login
- ❌ `"Login failed:"` - Authentication error

### 🎭 Advanced Usage

#### Force Re-authentication
1. Open **Collection Variables**
2. Clear the `token` value (set to empty string)
3. Save and run any request

#### Skip Auto-Authentication for Specific Requests
Add this to a request's **Pre-request Script**:
```javascript
// Skip auto-authentication for this request
pm.collectionVariables.set('skipAutoAuth', 'true');
```

#### Custom Error Handling
The post-request script automatically handles 401/403 errors, but you can add custom logic in individual request test scripts.

### 🔍 Behind the Scenes

#### Pre-Request Script Logic
1. Check if current request is to auth endpoint → skip if yes
2. Check if token exists → skip login if yes
3. Prepare login request with stored credentials
4. Send synchronous login request
5. Extract and store JWT token from response

#### Post-Request Script Logic
1. Check response status for auth failures (401/403)
2. Clear token if authentication failed
3. Store token for successful login responses

### 🎉 Benefits

- **Faster Testing**: No manual login steps
- **Better Developer Experience**: Focus on testing API functionality
- **Automatic Recovery**: Handles token expiration gracefully
- **Consistent Authentication**: Same process across all endpoints
- **Debugging Support**: Clear console messages for troubleshooting
