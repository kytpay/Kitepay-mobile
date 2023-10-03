import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/widgets/wrapper_image.dart';
import 'package:kitepay/payments/manuallypay_page.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/utilies/const/color_constant.dart';

class BalancePage extends HookConsumerWidget {
  final Account account;

  BalancePage(this.account);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String usdBalance = account.usdBalance.toStringAsFixed(2);
    // Retrieve all the tokens owned by the account
    List<Token> tokens = getAllPayableTokens(account);
    var name = account.name;
    var client = ref.watch(networkClient).url.network;
    print("Balance page: $name, $client, $tokens");

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: kGreyLightColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              Icon(
                FontAwesomeIcons.checkCircle,
                size: 150,
                color: Colors.greenAccent,
              ),
              SizedBox(height: 40),
              Text("Account Balance",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Text("\$$usdBalance",
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.w700)),
              SizedBox(height: 10),
              Divider(
                height: 1,
                thickness: 1,
              ),
              SizedBox(height: 10),
              ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: tokens.map(
                  (token) {
                    return tokenItem(token, usdBalance);
                  },
                ).toList(),
              )
              //  SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              'DONE',
              textAlign: TextAlign.center,
              style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Column tokenItem(Token token, String usdBalance) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: WrapperImage(
                    token.info.logoUrl,
                    defaultIcon: FontAwesomeIcons.coins,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                        token.info.symbol.length > 10
                            ? token.info.symbol.substring(0, 8)
                            : token.info.symbol,
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  Flexible(
                      fit: FlexFit.loose,
                      child: Text(token.balance.toString())),
                ],
              ),
              Spacer(),
              token.info.symbol == 'SOL'
                  ? Text(usdBalance,
                      style: TextStyle(fontWeight: FontWeight.w800))
                  : Container()
            ],
          ),
        ),
        SizedBox(height: 2),
      ],
    );
  }
}

enum TransactionStatus {
  pending,
  received,
}
