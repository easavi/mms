import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service to generate and manage unique device identifiers
/// Works on both Windows desktop and web platforms
class DeviceService {
  static DeviceService? _instance;
  static DeviceService get instance => _instance ??= DeviceService._();
  
  DeviceService._();
  
  String? _deviceId;
  
  /// Get unique device ID
  /// On Windows: Uses machine-specific identifiers
  /// On Web: Uses browser fingerprinting with localStorage persistence
  Future<String> getDeviceId() async {
    if (_deviceId != null) {
      return _deviceId!;
    }
    
    try {
      if (kIsWeb) {
        _deviceId = await _getWebDeviceId();
      } else if (Platform.isWindows) {
        _deviceId = await _getWindowsDeviceId();
      } else {
        // Fallback for other platforms
        _deviceId = await _getFallbackDeviceId();
      }
      
      return _deviceId!;
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      // Fallback to generated ID
      _deviceId = await _getFallbackDeviceId();
      return _deviceId!;
    }
  }
  
  /// Generate device ID for web platform
  Future<String> _getWebDeviceId() async {
    const String storageKey = 'mms_device_id';
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String? existingId = prefs.getString(storageKey);
      
      if (existingId != null && existingId.isNotEmpty) {
        return existingId;
      }
      
      // Generate new device ID based on browser characteristics
      String deviceId = await _generateWebFingerprint();
      
      // Store for future use
      await prefs.setString(storageKey, deviceId);
      
      return deviceId;
    } catch (e) {
      debugPrint('Error with SharedPreferences, using session-based ID: $e');
      return _generateWebFingerprint();
    }
  }
  
  /// Generate device ID for Windows platform
  Future<String> _getWindowsDeviceId() async {
    try {
      // Try to get machine GUID from Windows registry
      ProcessResult result = await Process.run(
        'reg', 
        ['query', 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Cryptography', '/v', 'MachineGuid'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        String output = result.stdout.toString();
        RegExp guidRegex = RegExp(r'MachineGuid\s+REG_SZ\s+([A-F0-9-]+)', caseSensitive: false);
        Match? match = guidRegex.firstMatch(output);
        
        if (match != null) {
          String machineGuid = match.group(1)!;
          // Hash the GUID for privacy and consistency, include platform mode
          return _hashString('mms_windows_app_$machineGuid');
        }
      }
      
      // Fallback: use computer name + username with platform mode
      String computerName = Platform.environment['COMPUTERNAME'] ?? 'unknown';
      String userName = Platform.environment['USERNAME'] ?? 'unknown';
      
      return _hashString('mms_windows_app_${computerName}_$userName');
      
    } catch (e) {
      debugPrint('Error getting Windows device ID: $e');
      
      // Final fallback for Windows with platform mode
      String computerName = Platform.environment['COMPUTERNAME'] ?? 'unknown';
      String userName = Platform.environment['USERNAME'] ?? 'unknown';
      return _hashString('mms_windows_app_fallback_${computerName}_$userName');
    }
  }
  
  /// Generate web browser fingerprint
  Future<String> _generateWebFingerprint() async {
    // Combine various browser characteristics with platform mode
    List<String> characteristics = [
      'web_browser', // Platform identifier with mode
      DateTime.now().millisecondsSinceEpoch.toString(), // Timestamp for uniqueness
      // Note: In a real implementation, you might use packages like:
      // - device_info_plus for more browser details
      // - platform_device_id for cross-platform device identification
    ];
    
    // Add screen resolution if available (would need additional packages)
    try {
      // This is a simplified version. In production, you might use:
      // - window.screen.width, window.screen.height via dart:html
      // - User agent information
      // - Browser language settings
      characteristics.add('screen_unknown');
      characteristics.add('browser_flutter_web');
    } catch (e) {
      // Ignore errors in web environment
    }
    
    String fingerprint = characteristics.join('_');
    return _hashString('mms_web_browser_$fingerprint');
  }
  
  /// Fallback device ID generation
  Future<String> _getFallbackDeviceId() async {
    const String storageKey = 'mms_device_id_fallback';
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String? existingId = prefs.getString(storageKey);
      
      if (existingId != null && existingId.isNotEmpty) {
        return existingId;
      }
      
      // Generate random device ID
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String randomComponent = DateTime.now().microsecondsSinceEpoch.toString();
      String deviceId = _hashString('mms_fallback_${timestamp}_$randomComponent');
      
      await prefs.setString(storageKey, deviceId);
      return deviceId;
      
    } catch (e) {
      // If SharedPreferences fails, generate a session-only ID
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      return _hashString('mms_session_$timestamp');
    }
  }
  
  /// Hash a string using SHA-256 and return first 16 characters
  String _hashString(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Use first 16 characters
  }
  
  /// Clear stored device ID (for testing purposes)
  Future<void> clearDeviceId() async {
    _deviceId = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mms_device_id');
      await prefs.remove('mms_device_id_fallback');
    } catch (e) {
      debugPrint('Error clearing device ID: $e');
    }
  }
  
  /// Get device info string for debugging
  Future<String> getDeviceInfo() async {
    String deviceId = await getDeviceId();
    String platform;
    
    if (kIsWeb) {
      platform = 'Web Browser';
    } else if (Platform.isWindows) {
      platform = 'Windows App';
    } else {
      platform = Platform.operatingSystem;
    }
    
    return 'Platform: $platform, Device ID: $deviceId';
  }
}
