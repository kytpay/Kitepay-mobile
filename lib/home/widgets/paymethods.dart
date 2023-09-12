import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/balance/balance_page.dart';
import 'package:kitepay/home/home_page.dart';
import 'package:kitepay/payments/manuallypay_page.dart';
import 'package:kitepay/payments/receivepay_page.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/payments/utilities/qr_pay.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/network/wallet_account.dart';

class PayMethods extends ConsumerWidget {
  final Account account;

  const PayMethods(this.account, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Container(
                    decoration: payButtonBoxDecoration(),
                    child: IconButton(
                      color: kWhiteColor,
                      icon: Icon(
                        Icons.keyboard_double_arrow_up_rounded,
                        size: 40,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ManuallyPayPage(account as WalletAccount),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text("Pay to Address",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Container(
                    decoration: payButtonBoxDecoration(),
                    child: IconButton(
                      color: kWhiteColor,
                      icon: Icon(
                        Icons.qr_code_scanner,
                        size: 40,
                      ),
                      onPressed: () {
                        qrPay(context, account as WalletAccount);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Pay to QR",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Container(
                    decoration: payButtonBoxDecoration(),
                    child: IconButton(
                      color: kWhiteColor,
                      icon: Icon(
                        Icons.person,
                        size: 40,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReceivePayPage(account),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Receive Pay",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Container(
                    decoration: payButtonBoxDecoration(),
                    child: IconButton(
                      color: kWhiteColor,
                      icon: Icon(
                        Icons.account_balance,
                        size: 40,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BalancePage(account),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Check Balance",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
