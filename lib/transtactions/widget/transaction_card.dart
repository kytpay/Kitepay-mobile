import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitepay/components/widgets/clickable_card.dart';
import 'package:kitepay/payments/widgets/transaction_sent.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:solana/solana.dart';

import '../../network/base_account.dart';

class TransactionCard extends StatelessWidget {
  final TransactionDetails transaction;
  final WalletAccount account;

  const TransactionCard(this.transaction, this.account, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateFormat hourMinutFormatter = DateFormat.Hm();
    DateFormat dayFormatter = DateFormat.yMMMMd();
    bool toMe = transaction.receivedOrNot;
    bool isSPL = transaction.programId == TokenProgram.programId ? true : false;
    String shortAddress = toMe ? transaction.origin : transaction.destination;

    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(transaction.blockTime * 1000);
    String transactionHourMin = hourMinutFormatter.format(date);
    String transactionDate = dayFormatter.format(date);

    transaction.programId;

    String transactionAmount = transaction.amount.toString().contains("-")
        ? transaction.amount.toStringAsFixed(9)
        : transaction.amount.toString();

    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ClickableCard(
            onTap: () {
              //  paymentInfo(context, transaction);
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      toMe
                          ? Icons.call_received_outlined
                          : Icons.call_made_outlined,
                      color: kPrimanyColor,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('${toMe ? 'Received' : 'Paid'}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            //  Spacer(),
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: isSPL
                                    ? Text('$transactionAmount SPL',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400))
                                    : Text('$transactionAmount SOL',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$shortAddress',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$transactionDate at $transactionHourMin',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: viewTransaction(
                              account, context, transaction.signature),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
