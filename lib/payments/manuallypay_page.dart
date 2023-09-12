import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/dialogs/custom_dialogs.dart';
import 'package:kitepay/payments/widgets/transaction_sent.dart';
import 'package:kitepay/components/widgets/TokenIcon.dart';
import 'package:kitepay/payments/utilities/pay_validator.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/utilies/network_connectivity.dart';

// ignore: must_be_immutable
class ManuallyPayPage extends HookConsumerWidget {
  final WalletAccount account;
  String initialDestination;
  String initialSendAmount;
  String initialMessage;
  String defaultTokenSymbol;
  List<String> references;

  ManuallyPayPage(
    this.account, {
    this.initialDestination = "",
    this.initialSendAmount = "",
    this.initialMessage = "",
    this.defaultTokenSymbol = "SOL",
    this.references = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retrieve all the tokens owned by the account
    List<Token> tokens = getAllPayableTokens(account);
    final address = useState<String>(initialDestination);
    final amount = useState<String>(initialSendAmount);
    final message = useState<String>(initialMessage);

    var name = account.name;
    var client = ref.read(networkClient).url.network;
    print("Payment page: $name, $client, $tokens");
    // Leave SOL as the default selection
    final selectedToken = useState(
      tokens.firstWhere(
        (token) => token.info.symbol == defaultTokenSymbol,
      ),
    );
    bool hasSufficientFund(Transaction transaction) {
      bool hasSufficientFund = false;

      if (transaction.token is SOL) {
        // Check if the SOL balance is enough
        if (account.balance >= transaction.amount) {
          hasSufficientFund = true;
        }
      } else {
        // Find the owned token and make sure the balance is enough
        Token? token = account.tokens[transaction.token.mint];
        if (token != null && token.balance >= transaction.amount) {
          hasSufficientFund = true;
        }
      }

      return hasSufficientFund;
    }

    Transaction createTransaction() {
      // Create transaction
      Transaction transaction = Transaction(
          account.address,
          address.value,
          double.parse(amount.value),
          false,
          selectedToken.value.mint,
          selectedToken.value,
          references);

      return transaction;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: kWhiteColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                    'Pay',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kWhiteColor),
                  ),
                ),
                onPressed: () {
                  if (PayValidator.validAddress(context, address)) {
                    if (PayValidator.validAmount(context, amount)) {
                      var tx = createTransaction();
                      paymentButtomSheet(context, tx, hasSufficientFund(tx));
                    }
                  }
                },
              ),
            ),
          ),
          Container(
            color: kWhiteColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                    'Create Tiplink',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kWhiteColor),
                  ),
                ),
                onPressed: () {
                  if (PayValidator.validAddress(context, address)) {
                    if (PayValidator.validAmount(context, amount)) {
                      var tx = createTransaction();
                      tiplinkButtomSheet(context, tx, hasSufficientFund(tx));
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    selectedItemBuilder: (BuildContext context) {
                      return tokens.map<Widget>((Token token) {
                        return selectedDropDownItem(token);
                      }).toList();
                    },
                    items: tokens.map((Token token) {
                      return dropDownItems(token);
                    }).toList(),
                    onChanged: (String? tokenSymbol) {
                      if (tokenSymbol != null) {
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
                        'To',
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
                TextFormField(
                  initialValue: address.value,
                  style: TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    contentPadding: EdgeInsets.all(8),
                    hintText: 'Enter Address',
                    // suffixIcon: IconButton(
                    //     icon: Icon(Icons.qr_code_scanner), onPressed: null),
                  ),
                  autofocus: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Address can't be null";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (String value) {
                    address.value = value;
                  },
                ),
                SizedBox(height: 10),
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
                  initialValue: amount.value,
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
                Visibility(
                  visible: message.value.isNotEmpty,
                  child: Column(
                    children: [
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
                        initialValue: message.value,
                        style: TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          contentPadding: EdgeInsets.all(8),
                          hintText: 'Message',
                        ),
                        onChanged: (String value) {
                          message.value = value;
                        },
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Average Transaction fee: \$0.00025 \n(stats as of 2/01/22)',
                      style: TextStyle(fontSize: 12, color: kGreyColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> paymentButtomSheet(BuildContext context, Transaction transaction,
      bool hasSufficientFund) async {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (cxt) {
        return StatefulBuilder(
            builder: (BuildContext cxt, StateSetter setModalState) {
          return Wrap(
            children: [
              Consumer(
                builder: (BuildContext cxt, WidgetRef ref, Widget? child) {
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
                            'Confirm Transaction',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Consumer(
                          builder: (BuildContext context, WidgetRef ref,
                              Widget? child) {
                            return Column(
                              children: [
                                transactionItems(
                                    'Network', ref.watch(selectedNetwork)),
                                transactionItems("From", transaction.origin),
                                transactionItems('To', transaction.destination),
                                transactionItems(
                                    'Token', transaction.token.info.symbol),
                                transactionItems(
                                    'Amount', transaction.amount.toString()),
                                transactionItems('Network Fee', '\$0.0003'),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    border: Border.all(
                                        color: kBackgroundDark10Color),
                                    borderRadius: BorderRadius.circular(10)),
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: const Text(
                                      'Cancel',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: kBackgroundDark10Color),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: kBackgroundDark10Color,
                                    borderRadius: BorderRadius.circular(10)),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    if (await NetworkConnectivity.isConnected(
                                        snackbar: true)) {
                                      if (hasSufficientFund) {
                                        sendTransaction(
                                            context, ref, account, transaction);
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
                                                "Insufficient funds for the transaction!",
                                                style: TextStyle(
                                                    color: kWhiteColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: const Text(
                                      'Confirm',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Future<void> tiplinkButtomSheet(BuildContext context, Transaction transaction,
      bool hasSufficientFund) async {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (cxt) {
        return StatefulBuilder(
            builder: (BuildContext cxt, StateSetter setModalState) {
          return Wrap(
            children: [
              Consumer(
                builder: (BuildContext cxt, WidgetRef ref, Widget? child) {
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
                            'Confirm Transaction',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Consumer(
                          builder: (BuildContext context, WidgetRef ref,
                              Widget? child) {
                            return Column(
                              children: [
                                transactionItems(
                                    'Network', ref.watch(selectedNetwork)),
                                transactionItems("From", transaction.origin),
                                transactionItems(
                                    'Token', transaction.token.info.symbol),
                                transactionItems(
                                    'Amount', transaction.amount.toString()),
                                transactionItems('Network Fee', '\$0.0003'),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    border: Border.all(
                                        color: kBackgroundDark10Color),
                                    borderRadius: BorderRadius.circular(10)),
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: const Text(
                                      'Cancel',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: kBackgroundDark10Color),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: kBackgroundDark10Color,
                                    borderRadius: BorderRadius.circular(10)),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    if (await NetworkConnectivity.isConnected(
                                        snackbar: true)) {
                                      if (hasSufficientFund) {
                                        sendTransaction(
                                            context, ref, account, transaction);
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
                                                "Insufficient funds for the transaction!",
                                                style: TextStyle(
                                                    color: kWhiteColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: const Text(
                                      'Confirm',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget transactionItems(String attribute, String value) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(attribute,
                  style: TextStyle(
                      color: Colors.black45,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ),
          ),
          //  Spacer(),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ),
          )
        ],
      ),
    );
  }

  DropdownMenuItem<String> dropDownItems(Token token) {
    return DropdownMenuItem<String>(
      value: token.info.symbol,
      child: Column(
        children: [
          Flexible(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: TokenIcon(
                      token.info.logoUrl,
                      defaultIcon: FontAwesomeIcons.coins,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                          token.info.symbol.length > 10
                              ? token.info.symbol.substring(0, 8)
                              : token.info.symbol,
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Flexible(
                        child: Text(
                      token.balance.toString().length > 5
                          ? token.balance.toString().substring(0, 5)
                          : token.balance.toString(),
                    )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget selectedDropDownItem(Token token) {
    return Center(
      child: Wrap(
        children: [
          Container(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: TokenIcon(
                      token.info.logoUrl,
                      defaultIcon: FontAwesomeIcons.coins,
                    ),
                  ),
                ),
                Text(
                  token.info.symbol.length > 10
                      ? token.info.symbol.substring(0, 8)
                      : token.info.symbol,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//send transaction
void sendTransaction(BuildContext context, WidgetRef ref, WalletAccount account,
    Transaction transaction) {
  try {
    // Send the transaction and pass the callback (future) to the next dialog
    // final sign = account.sendTransaction(transaction);

    final sign = ref.watch(networkClient).sendTransaction(account, transaction);

    transactionIsBeingConfirmedDialog(
      context,
      sign,
      transaction,
      account,
    );
  } catch (err) {
    print(err.toString());
    // Display the "Transaction went wrong" dialog
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
            "Couldn't complete the transaction!",
            style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

List<Token> getAllPayableTokens(Account account) {
  List<Token> accountTokens = List.from(account.tokens.values);
  accountTokens = accountTokens.where((token) => token is! NFT).toList();
  // print(accountTokens.toString());
  //adding sol ot the spltokenlist
  accountTokens.insert(0, SOL(account.balance));
  // print(accountTokens.toString());

  return accountTokens;
}
