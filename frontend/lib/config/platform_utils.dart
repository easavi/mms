import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_config.dart';

class PlatformUtils {
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
  
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }
  
  static bool get isWeb => kIsWeb;
  
  static Environment getDefaultEnvironment() {
    if (isWeb) {
      return Environment.dev; // or Environment.devWeb if you have a specific web environment
    } else if (isMobile) {
      return Environment.devMobile;
    } else {
      return Environment.dev;
    }
  }
}
