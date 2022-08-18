import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/network/network_client.dart';
import 'package:kitepay/settings/settings.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:solana/dto.dart' show Commitment;

import '../../network/base_account.dart';
import '../../provider/states.dart';
import '../../network/wallet_account.dart';

Future<void> transactionIsBeingConfirmedDialog(
  context,
  Future<String> signFuture,
  Transaction transaction,
  WalletAccount account,
) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Color.fromARGB(215, 29, 54, 62),
        content: SingleChildScrollView(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return FutureBuilder(
                future: signFuture,
                builder: (context, res) {
                  if (res.hasData) {
                    var sign = res.data as String;
                    if (signStatusSuccess(ref,
                      account,
                      sign,
                    )) {
                      return HookConsumer(
                        builder: (ctx, ref, _) {
                          // Refresh the account when the transaction has been confirmed
                          ref
                              .read(accountsProvider.notifier)
                              .refreshAccount(ref
                              .watch(networkClient.notifier)
                              .state,account.address);

                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Icon(
                                  Icons.task_alt_outlined,
                                  color: Colors.green,
                                  size: 100,
                                ),
                              ),
                              Text(
                                "Successfully sent ${transaction.amount} ${transaction.token.info.symbol} to ${transaction.destination}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kWhiteColor,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 10),
                              viewTransaction(account, context, sign)
                            ],
                          );
                        },
                      );
                    } else {
                      return Column(
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
                            "Couldn't complete the transaction!",
                            style: TextStyle(
                                color: kWhiteColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        child: Center(
                          child: Column(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: GradientCircularProgressIndicator(
                                  gradient: kGradientProgressbar,
                                  radius: 150,
                                ),
                              ),
                              Text("Sending...",
                                  style: TextStyle(
                                      color: kWhiteColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Close',
              style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

Widget viewTransaction(
    WalletAccount account, BuildContext context, String sign) {
  return Consumer(
    builder: (BuildContext context, WidgetRef ref, Widget? child) {
      return GestureDetector(
        onTap: () {
          String network = '';
          switch (ref.watch(selectedNetwork.notifier).state) {
            case 'Devnet':
              {
                network = 'devnet';
              }

              break;
            case 'Testnet':
              {
                network = 'testnet';
              }

              break;
            default:
              {
                network = '';
              }
          }
          ;
          openURL(
              context, 'https://solscan.io/tx/' + sign + '?cluster=' + network);
        },
        child: Text(
          'View Transaction',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: kBackgroundDark10Color, fontWeight: FontWeight.bold),
        ),
      );
    },
  );
}

bool signStatusSuccess(WidgetRef ref,WalletAccount account, String sign) {
  
  NetworkClient client = ref.watch(networkClient);
   
  bool status = false;
  try {
    client.waitForSignatureStatus(sign,
        status: Commitment.confirmed, timeout: Duration(minutes: 2));
    status = true;
  } catch (err) {
    print(err.toString());
    status = false;
  }
  return status;
}
