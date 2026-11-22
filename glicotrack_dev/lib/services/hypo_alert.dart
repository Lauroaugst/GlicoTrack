import 'package:flutter/services.dart';

class HypoAlert {
  static const _channel = MethodChannel('glicotrack/alerts');
  static Future<void> play() async {
    try {
      await _channel.invokeMethod<void>('hypoglycemia');
    } on PlatformException {
      await SystemSound.play(SystemSoundType.alert);
    } on MissingPluginException {
      await SystemSound.play(SystemSoundType.alert);
    }
  }
}
