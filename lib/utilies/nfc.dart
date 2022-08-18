import 'package:flutter/services.dart';

class NFC {

  static const MethodChannel _channel = const MethodChannel(
      "org.kitepay.app.emulator");

  /*
   * Enable NFC
   */
  static Future<void> enableNfc() async {
    print("Function: enableNfc");
    await _channel.invokeMethod("enableNfc");
  }

  /*
   * Disable NFC
   */
  static Future<void> disableNfc() async {
    print("Function: disableNfc");
    await _channel.invokeMethod("disableNfc");
  }

  /*
   * Start NFC Emulator
   */
  static Future<void> startNfcEmulator(String text) async {
    print("Function: startNfcEmulator");
    await _channel.invokeMethod('startNfcEmulator', {
      "text": text});
  }

  /*
   * Stop NFC Emulator
   */
  static Future<void> stopNfcEmulator() async {
    print("Function: stopNfcEmulator");
    await _channel.invokeMethod('stopNfcEmulator');
  }
}
