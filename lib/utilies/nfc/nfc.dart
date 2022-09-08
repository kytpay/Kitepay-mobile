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
  static var nfcAvailable = NfcManager.instance.isAvailable();

  static Future<void> setup(WidgetRef ref) async {
    print("Function: setupNfc");
    // nfcAvailable = await NfcManager.instance.isAvailable();
    homeRef = ref;
  }

  /*
   * Enable NFC
   */
  static Future<void> enableNfc() async {
    print("Function: enableNfc");
    // await _channel.invokeMethod("enableNfc");

    if (await nfcAvailable) {
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
    if (await nfcAvailable) {
      await NfcManager.instance.stopSession();
    }
  }

  /*
   * Start NFC Emulator
   */
  static Future<void> startNfcEmulator(String text) async {
    print("Function: startNfcEmulator");
    if (await nfcAvailable) {
      await _channel.invokeMethod('startNfcEmulator', {"text": text});
    }
  }

  /*
   * Stop NFC Emulator
   */
  static Future<void> stopNfcEmulator() async {
    print("Function: stopNfcEmulator");
    if (await nfcAvailable) {
      await _channel.invokeMethod('stopNfcEmulator');
    }
  }
}
