import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/device_service.dart';

void main() {
  group('DeviceService', () {
    late DeviceService deviceService;

    setUp(() {
      deviceService = DeviceService.instance;
    });

    test('should generate unique device ID', () async {
      final deviceId1 = await deviceService.getDeviceId();
      final deviceId2 = await deviceService.getDeviceId();
      
      // Should return the same ID when called multiple times
      expect(deviceId1, equals(deviceId2));
      expect(deviceId1, isNotEmpty);
      expect(deviceId1.length, equals(16)); // SHA-256 first 16 characters
    });

    test('should provide device info', () async {
      final deviceInfo = await deviceService.getDeviceInfo();
      
      expect(deviceInfo, isNotEmpty);
      expect(deviceInfo, contains('Platform:'));
      expect(deviceInfo, contains('Device ID:'));
    });

    test('should clear device ID', () async {
      // Get initial device ID to ensure service is initialized
      await deviceService.getDeviceId();
      
      // Clear device ID
      await deviceService.clearDeviceId();
      
      // Get new device ID - should still work
      final newId = await deviceService.getDeviceId();
      
      expect(newId, isNotEmpty);
      expect(newId.length, equals(16));
    });
  });
}
