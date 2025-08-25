# MMS Android Frontend Setup Guide

## Overview

The MMS (Media Management System) frontend has been successfully adapted to run as an Android application. This guide covers the setup process, configuration, and deployment instructions.

## Android Configuration Changes

### 1. Android Platform Support Added
- Added `android/` directory with full Android project structure
- Configured Android-specific build files and dependencies
- Set up proper Android manifest with required permissions

### 2. Application Configuration
- **Package Name**: `com.mms.frontend`
- **App Name**: "MMS - Media Management"
- **Supported Android Versions**: API level 21+ (Android 5.0+)
- **Target SDK**: API level 34 (Android 14)

### 3. Network Configuration
- Added network security configuration to allow HTTP connections in development
- Configured permissions for internet access, storage, camera, and network state
- Set up development environment support for Android emulator (`10.0.2.2:8080`)

### 4. API Configuration
- Added platform-aware API configuration
- Automatically detects mobile platform and uses appropriate API endpoints:
  - **Desktop/Web**: `http://localhost:8080`
  - **Mobile (Android/iOS)**: `http://10.0.2.2:8080` (Android emulator)
  - **Production**: Configurable production URL

## Build Artifacts

### APK Location
The built Android APK is located at:
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

### APK Details
- **File Size**: ~23 MB
- **Build Type**: Release
- **Architecture**: Universal APK (supports all Android architectures)

## Installation Options

### 1. Direct APK Installation
1. Transfer the `app-release.apk` file to your Android device
2. Enable "Install from Unknown Sources" in device settings
3. Open the APK file and follow installation prompts

### 2. Development Installation
Using VS Code tasks (if device is connected via USB with USB debugging enabled):
```bash
# Run the Android task from VS Code Task menu
Run Task → "Run Flutter App - Android"
```

### 3. Command Line Installation
```bash
cd frontend
flutter install  # Device must be connected and detected
```

## Available VS Code Tasks

The following tasks have been added for Android development:

1. **Run Flutter App - Android**: Launches the app on connected Android device/emulator
2. **Build Flutter App - Android APK**: Builds a release APK
3. **Build Flutter App - Android Bundle**: Builds an Android App Bundle for Play Store

## Network Configuration for Development

### Backend Server Requirements
When running the Android app in development mode, ensure your MMS backend server is accessible:

1. **If using Android Emulator**: Backend should run on `localhost:8080` (automatically mapped to `10.0.2.2:8080`)
2. **If using Physical Device**: 
   - Find your development machine's IP address
   - Update the API configuration to use your machine's IP instead of `localhost`
   - Ensure firewall allows connections on port 8080

### Updating API Configuration for Physical Devices
If testing on a physical Android device, update the API configuration:

1. Find your development machine's IP address:
   ```bash
   ipconfig  # On Windows
   ifconfig  # On Linux/Mac
   ```

2. Temporarily modify `lib/config/api_config.dart`:
   ```dart
   case Environment.devMobile:
     return 'http://YOUR_MACHINE_IP:8080';  // Replace with actual IP
   ```

## Permissions

The Android app includes the following permissions:
- **Internet**: For API communication
- **Storage**: For file operations and media management
- **Camera**: For photo/video capture
- **Network State**: For connectivity detection

## Features Supported

All MMS frontend features are supported on Android:
- ✅ User authentication (login/signup)
- ✅ Media browsing and viewing
- ✅ File upload and management
- ✅ Storage configuration
- ✅ Thumbnail generation and caching
- ✅ Video playback
- ✅ Responsive UI design

## Development Environment Requirements

- **Flutter SDK**: 3.32.7 or later
- **Android SDK**: API level 34
- **Java**: 17+ (configured in build files)
- **Gradle**: 8.14
- **NDK**: 27.0.12077973 (auto-detected)

## Troubleshooting

### Common Issues

1. **Build Errors with Java 24**
   - The project is configured to use Java 17 for Android builds
   - Gradle version 8.14 is used for compatibility

2. **Network Connection Issues**
   - Ensure backend server is running and accessible
   - Check network security configuration in `android/app/src/main/res/xml/network_security_config.xml`
   - Verify API endpoints in environment configuration

3. **APK Installation Issues**
   - Enable "Install from Unknown Sources" on Android device
   - Check if device has sufficient storage space
   - Ensure APK is not corrupted during transfer

### Development Tips

1. **Using Android Emulator**: 
   - Create an AVD (Android Virtual Device) with API level 28+
   - The emulator will automatically map `localhost` to `10.0.2.2`

2. **USB Debugging**:
   - Enable Developer Options on Android device
   - Enable USB Debugging
   - Install device drivers if necessary

3. **Live Reload**: 
   - Use `flutter run -d android` for hot reload during development
   - Changes to Dart code will be reflected immediately

## Deployment

### For Internal Distribution
1. Build release APK: `flutter build apk --release`
2. Distribute the APK file directly to users

### For Play Store Distribution
1. Build Android App Bundle: `flutter build appbundle --release`
2. Upload the `.aab` file to Google Play Console
3. Follow Play Store submission guidelines

## Security Considerations

- The current configuration allows HTTP connections for development
- For production deployment, ensure all API communications use HTTPS
- Update network security configuration to remove development endpoints
- Consider implementing certificate pinning for enhanced security

## Next Steps

1. Test the APK on various Android devices and screen sizes
2. Configure production API endpoints
3. Set up proper app signing for production releases
4. Implement push notifications if needed
5. Optimize app size and performance for mobile devices
