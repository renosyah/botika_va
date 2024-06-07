import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'botika_va_platform_interface.dart';

class MethodChannelBotikaVa extends BotikaVaPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('botika_va');

  @override
  Future<String?> getPlatformVersion() async {
    String? version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
