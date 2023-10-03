import 'package:flutter/material.dart';
import 'package:kitepay/components/dialogs/custom_dialogs.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/payments/scanqr_page.dart';
import 'package:kitepay/payments/utilities/uri_pay.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

Future<void> qrPay(BuildContext context, WalletAccount account) async {
  Barcode? result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => ScanQrPage(),
    ),
  );
  if (result != null) {
    String? solanaPayUri = result.code;

    if (solanaPayUri != null) {
      uriPay(context, account, solanaPayUri);
    } else {
      customAlertDialog(
        context,
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(15),
              child: Icon(
                Icons.error_outline_outlined,
                color: Colors.red,
                size: 100,
              ),
            ),
            Text(
              "Invalid code",
              style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }
}
