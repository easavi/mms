# VS Code Launch Configurations for MMS Frontend

## Available Launch Configurations

The project includes several VS Code launch configurations for the Flutter frontend application:

### 🌐 **Chrome Configurations**

#### `frontend (Chrome)`
- **Description**: Runs the Flutter app in Chrome browser (debug mode)
- **Use Case**: Standard web development and debugging
- **Hot Reload**: ✅ Enabled
- **DevTools**: ✅ Available

#### `frontend (Chrome Profile)`
- **Description**: Runs the Flutter app in Chrome with profile mode
- **Use Case**: Performance testing and optimization
- **Hot Reload**: ✅ Enabled  
- **Performance**: Optimized build with debugging symbols

### 📱 **General Configurations**

#### `frontend`
- **Description**: Default Flutter launch configuration
- **Platform**: Auto-detects available devices
- **Use Case**: Quick launch on any available device

#### `frontend (profile mode)`
- **Description**: Profile mode for performance analysis
- **Platform**: Auto-detects available devices
- **Use Case**: Performance testing across platforms

#### `frontend (release mode)`
- **Description**: Release build for production testing
- **Platform**: Auto-detects available devices
- **Use Case**: Final testing before deployment

## 🚀 How to Use

### Method 1: VS Code Debug Panel
1. Open VS Code
2. Go to **Run and Debug** panel (Ctrl+Shift+D)
3. Select desired configuration from dropdown
4. Click **Start Debugging** (F5)

### Method 2: Command Palette
1. Press `Ctrl+Shift+P`
2. Type "Debug: Select and Start Debugging"
3. Choose your preferred configuration

### Method 3: Keyboard Shortcuts
- **F5**: Start debugging with last used configuration
- **Ctrl+F5**: Run without debugging

## 🛠 Available Tasks

You can also use VS Code tasks for running the frontend:

- **Run Flutter App**: `flutter run -d chrome`
- **Run Flutter App - Windows**: `flutter run -d windows`  
- **Build Flutter App - Windows Release**: `flutter build windows --release`

## 📁 Working Directory

All configurations automatically set the working directory to `frontend/` folder, so you don't need to navigate to the frontend directory manually.

## 🔧 Prerequisites

Make sure you have:
- ✅ Flutter SDK installed and in PATH
- ✅ Chrome browser installed
- ✅ VS Code Dart and Flutter extensions installed
- ✅ Backend server running (for API calls)

## 🐛 Troubleshooting

### Chrome not launching
- Ensure Chrome is installed and accessible
- Check if Flutter web support is enabled: `flutter config --enable-web`

### Hot reload not working
- Ensure you're running in debug mode (not release)
- Check that you're modifying Dart files, not other assets

### Backend connection issues
- Verify backend is running on `http://localhost:8080`
- Check CORS configuration if running on different ports
- Update API base URLs in Flutter configuration if needed

## 🎯 Recommended Workflow

1. **Start Backend**: Launch your Spring Boot backend
2. **Chrome Debug**: Use "frontend (Chrome)" for standard development
3. **Performance Testing**: Use "frontend (Chrome Profile)" for optimization
4. **Final Testing**: Use "frontend (release mode)" before deployment
