import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'botika_va_method_channel.dart';

abstract class BotikaVaPlatform extends PlatformInterface {
  BotikaVaPlatform() : super(token: _token);

  static final Object _token = Object();

  static BotikaVaPlatform _instance = MethodChannelBotikaVa();

  static BotikaVaPlatform get instance => _instance;

  static set instance(BotikaVaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
