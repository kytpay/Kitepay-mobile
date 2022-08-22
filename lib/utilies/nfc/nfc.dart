import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/material_key.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/payments/utilities/uri_pay.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/utilies/nfc/NdefRecordInfo.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFC {
  static const MethodChannel _channel =
      const MethodChannel("org.kitepay.app.emulator");
  static late WidgetRef homeRef;

  static void setup(WidgetRef ref) {
    print("Function: setupNfc");
    homeRef = ref;
  }

  /*
   * Enable NFC
   */
  static Future<void> enableNfc() async {
    print("Function: enableNfc");
    // await _channel.invokeMethod("enableNfc");

    if (await NfcManager.instance.isAvailable()) {
      // Start Session
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          Ndef? ndef = Ndef.from(tag);
          if (ndef != null) {
            var ndefMessage = ndef.cachedMessage;

            if (ndefMessage != null) {
              print(ndefMessage);

              var record = ndefMessage.records[0];
              var recordText = NdefRecordInfo.fromNdef(record).subtitle;
              print(recordText);

              uriPay(
                  AppNavigation.homeScaffoldKey.currentContext!,
                  homeRef.read(selectedAccountProvider) as WalletAccount,
                  recordText);
            }
          }
        },
      );
    }
  }

  /*
   * Disable NFC
   */
  static Future<void> disableNfc() async {
    print("Function: disableNfc");
    // await _channel.invokeMethod("disableNfc");
    await NfcManager.instance.stopSession();
  }

  /*
   * Start NFC Emulator
   */
  static Future<void> startNfcEmulator(String text) async {
    print("Function: startNfcEmulator");
    await _channel.invokeMethod('startNfcEmulator', {"text": text});
  }

  /*
   * Stop NFC Emulator
   */
  static Future<void> stopNfcEmulator() async {
    print("Function: stopNfcEmulator");
    await _channel.invokeMethod('stopNfcEmulator');
  }
}
