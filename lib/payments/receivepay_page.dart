import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/widgets/wrapper_image.dart';
import 'package:kitepay/payments/manuallypay_page.dart';
import 'package:kitepay/payments/utilities/pay_validator.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/utilies/nfc.dart';
import 'package:kitepay/utilies/solanapay.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kitepay/profile/profile_page.dart';

import '../settings/edit_account.dart';

class ReceivePayPage extends HookConsumerWidget {
  final Account account;

  ReceivePayPage(this.account);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Token> tokens = getReceivableTokens();

    final amount = useState<String>("");
    final message = useState<String?>(null);
    final selectedToken = useState(tokens.first);

    var name = account.name;
    var client = ref.read(networkClient).url.network;
    var coins = getAllPayableTokens(account);
    print("Receive page: $name, $client, $coins");

    TransactionSolanaPay createTransferRequest() {
      return TransactionSolanaPay(
          recipient: account.address.trim(),
          amount: double.parse(amount.value),
          message: message.value != null ? message.value!.trim() : null,
          splToken: selectedToken.value.info.symbol != "SOL"
              ? selectedToken.value.mint
              : null);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Receive'),
      ),
      floatingActionButton: Container(
        color: kWhiteColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            child: ListTile(
              title: Text(
                'Generate Code',
                textAlign: TextAlign.center,
                style: TextStyle(color: kWhiteColor),
              ),
            ),
            onPressed: () {
              if (PayValidator.validAmount(context, amount)) {
                payReceiveButtomSheet(context, createTransferRequest());
              }
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: DropdownButton<String>(
                    icon: Icon(Icons.arrow_forward_ios),
                    underline: Container(),
                    value: selectedToken.value.info.symbol,
                    items: tokens.map((Token token) {
                      return dropDownItems(token);
                    }).toList(),
                    onChanged: (String? tokenSymbol) {
                      if (tokenSymbol != null) {
                        //Change the selected token
                        selectedToken.value = tokens.firstWhere(
                          (token) => token.info.symbol == tokenSymbol,
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 5),
                Divider(
                  height: 1,
                  thickness: 1,
                ),
                SizedBox(height: 20),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Amount',
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
                TextFormField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    contentPadding: EdgeInsets.all(8),
                    hintText: 'Enter amount',
                  ),
                  autofocus: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Amount can't be null";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (String value) async {
                    amount.value = value;
                  },
                ),
                SizedBox(height: 10),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Message',
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
                TextFormField(
                  style: TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    contentPadding: EdgeInsets.all(8),
                    hintText: 'Add a message (optional)',
                  ),
                  onChanged: (String value) {
                    message.value = value;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> dropDownItems(Token token) {
    return DropdownMenuItem<String>(
      value: token.info.symbol,
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(token.info.symbol.length > 5
                  ? token.info.symbol.substring(0, 5)
                  : token.info.symbol),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> payReceiveButtomSheet(
    BuildContext context, TransactionSolanaPay transaction) async {
  var errorVisibility = false;
  var transactionUri = transaction.toUri();

  String transactionDeepLink = transaction.toDeepLink();

  // init NearbyMessagesApi
  // FlutterNearbyMessagesApi nearbyMessagesApi = FlutterNearbyMessagesApi();

  // await nearbyMessagesApi.setAPIKey('AIzaSyCOTfX3ENbfNA-Rq22kqK-HVKaVGNDTnG4');

  // await nearbyMessagesApi.publish(transactionUri);

  //nfc emulator
  NFC.startNfcEmulator(transactionUri);

  GlobalKey repaintGlobalKey = GlobalKey();

  showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
        return Wrap(
          children: [
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Receive SOL & SPL tokens',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RepaintBoundary(
                        key: repaintGlobalKey,
                        child: QrImage(
                          data: transactionUri,
                          version: QrVersions.auto,
                          size: 200,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Visibility(
                          visible: errorVisibility,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Copied',
                                style: TextStyle(color: Colors.greenAccent),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          copyToKeyboard(context, transactionDeepLink, false);
                          setModalState(
                            () {
                              errorVisibility = true;
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              color: kBackgroundDark10Color,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: const Text(
                                'Copy Link',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          shareQR(context, repaintGlobalKey, transaction);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              color: kWhiteColor,
                              border: Border.all(color: kBackgroundDark10Color),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: const Text(
                                'Share QR',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kBackgroundDark10Color,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),

                      //padding for keyboard insert
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                      ),
                      SizedBox(
                        height: 40,
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        );
      });
    },
  ).whenComplete(() => NFC.stopNfcEmulator());
}

// Future<String> DynamicLink(String transactionlink) async {
//   final dynamicLinkParams = DynamicLinkParameters(
//     link: Uri.parse(transactionlink),
//     longDynamicLink: Uri.parse(transactionlink),
//     uriPrefix: "https://kitepay.page.link",
//     androidParameters: const AndroidParameters(packageName: "org.kitepay"),
//     iosParameters: const IOSParameters(bundleId: "org.kitepay"),
//   );
//   final dynamicLink =
//       await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
//   print(dynamicLink.toString());
//   // final shortDynamicLink =
//   //     await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams, shortLinkType: ShortDynamicLinkType.unguessable);

//   // print(shortDynamicLink);
//   return dynamicLink.toString();
// }

List<Token> getReceivableTokens() {
  List<Token> tokens = [];
  tokens.insert(0, SOL(0.0));
  tokens.insert(1, USDC(0.0));
  tokens.insert(2, USDT(0.0));
  tokens.insert(3, DAI(0.0));
  tokens.insert(4, BUSD(0.0));

  return tokens;
}
