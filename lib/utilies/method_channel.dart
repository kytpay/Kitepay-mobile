import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/material_key.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/payments/utilities/uri_pay.dart';
import 'const/string_constant.dart';
import 'package:kitepay/provider/states.dart';

class NfcMethodChannel {
  late MethodChannel methodChannel;
  late WidgetRef _ref;

  //static final NfcMethodChannel _instance;

  void configureChannel(WidgetRef ref) {
    print("Function: configureChannel");
    methodChannel = MethodChannel(EMULATOR_CHANNEL);
    methodChannel.setMethodCallHandler(this.methodHandler); // set method handler
    _ref = ref;
  }

  Future<void> methodHandler(MethodCall call) async {

    switch (call.method) {
      case "onNfcRead": // this method name needs to be the same from invokeMethod in Android
        String message = call.arguments["message"];
        print(message);
        uriPay(AppNavigation.materialKey.currentContext!, _ref.read(selectedAccountProvider) as WalletAccount, message);
       // DataService.instance.addIdea(idea); // you can handle the data here. In this example, we will simply update the view via a data service
        break;
      default:
        print('no method handler for method ${call.method}');
    }
  }
}