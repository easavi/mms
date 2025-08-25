import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_config.dart';

class PlatformUtils {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  static bool get isWeb => kIsWeb;
  
  static Environment getDefaultEnvironment() {
    if (isMobile) {
      return Environment.devMobile;
    } else {
      return Environment.dev;
    }
  }
}
