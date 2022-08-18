import 'package:flutter/material.dart';
import 'package:kitepay/components/dialogs/custom_dialogs.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/payments/manuallypay_page.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/utilies/solanapay.dart';

Future<void> uriPay(
    BuildContext context, WalletAccount account, String uri) async {
  try {
    TransactionSolanaPay txData = TransactionSolanaPay.parseUri(uri);
    print('URI: $uri, TXdata $txData');
    String defaultTokenSymbol = "SOL";

    if (txData.splToken != null) {
      try {
        Token selectedToken = account.getTokenByMint(txData.splToken!);
        defaultTokenSymbol = selectedToken.info.symbol;
      } catch (_) {
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
                "Transaction contains token that you don't own or we can't identify it",
                style:
                    TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManuallyPayPage(
          account,
          initialDestination: txData.recipient,
          initialSendAmount: txData.amount.toString(),
          initialMessage: txData.message ?? '',
          defaultTokenSymbol: defaultTokenSymbol,
          references: txData.references,
        ),
      ),
    );
  } on FormatException {
    // Invalid URI
    print('URI: $uri');
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
            "Invalid Code",
            style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  } catch (err) {
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
            "Invalid Code",
            style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
