import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/settings/widgets/remove_account.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/network/wallet_account.dart';

class EditAccountPage extends StatefulWidget {
  final bool editAccounts = false;
  final Account account;

  EditAccountPage(this.account);


  @override
  State<EditAccountPage> createState() => EditAccountPageState(account);
}

class EditAccountPageState extends State<EditAccountPage> {
  Account account;
  EditAccountPageState(this.account);

  @override
  Widget build(BuildContext context) {
    String accountName = account.name;
    accountNameCallBack(String newName) {
      setState(() {
        accountName = newName;
      });
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        title: const Text("Edit Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
              decoration: BoxDecoration(
                  color: kBackgroundDarkColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Account Name'),
                    subtitle: Text(
                      "$accountName",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        editNameBottomSheet(
                            context, account, accountNameCallBack);
                      },
                    ),
                    onTap: () {
                      editNameBottomSheet(
                          context, account, accountNameCallBack);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: kWhiteColor,
                  ),
                  ListTile(
                    title: const Text('Address'),
                    subtitle: Text(
                      account.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        copyToKeyboard(context, account.address, true);
                      },
                    ),
                    onTap: () {
                      copyToKeyboard(context, account.address, true);
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
              decoration: BoxDecoration(
                  color: kBackgroundDarkColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Private Key'),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        privateKeyButtomSheet(context, account);
                      },
                    ),
                    onTap: () {
                      privateKeyButtomSheet(context, account);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: kWhiteColor,
                  ),
                  ListTile(
                    title: const Text('Secret Recovery Phrase'),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        recoveryPhraseButtomSheet(context, account);
                      },
                    ),
                    onTap: () {
                      recoveryPhraseButtomSheet(context, account);
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
              decoration: BoxDecoration(
                  color: kBackgroundDarkColor,
                  borderRadius: BorderRadius.circular(10)),
              child: GestureDetector(
                onTap: () => removeAccountDialog(context, account),
                child: ListTile(
                  title: const Text(
                    'Remove Account',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void editNameBottomSheet(BuildContext context, Account account, Function accountNameCallBack) {
  String accountName = account.name;
  var errorVisibility = false;
  String error = "Account name already exists";

  showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    isScrollControlled: true,
    context: context,
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
                          'Change Account Name',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        initialValue: accountName,
                        style: TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          contentPadding: EdgeInsets.all(8),
                          hintText: "Enter an account name",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Empty account name';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (String value) async {
                          accountName = value;
                        },
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
                                error,
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  border:
                                      Border.all(color: kBackgroundDark10Color),
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
                                onTap: () {
                                  if (accountName.isNotEmpty) {
                                    renameAccount(
                                        account, ref, accountName.trim());
                                    accountNameCallBack(accountName);
                                    Navigator.pop(context);
                                  } else {
                                    setModalState(() {
                                      error = "Please enter a user name!";
                                      errorVisibility = true;
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: const Text(
                                    'Change',
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

void recoveryPhraseButtomSheet(BuildContext context, Account account) {
  WalletAccount walletAccount = account as WalletAccount;
  String seedphrase = walletAccount.mnemonic;
  var errorVisibility = false;

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
                          'Secret Recovery Phrase',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        readOnly: true,
                        autofocus: true,
                        maxLines: 4,
                        initialValue: seedphrase,
                        style: TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          contentPadding: EdgeInsets.all(8),
                          // hintText: "Enter an account name",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Empty';
                          } else {
                            return null;
                          }
                        },
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
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  border:
                                      Border.all(color: kBackgroundDark10Color),
                                  borderRadius: BorderRadius.circular(10)),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: const Text(
                                    'Done',
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
                                onTap: () {
                                  copyToKeyboard(context, seedphrase, false);
                                  setModalState(
                                    () {
                                      errorVisibility = true;
                                    },
                                  );
                                  // Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: const Text(
                                    'Copy',
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

Future<void> privateKeyButtomSheet(BuildContext context, Account account) async {
  var errorVisibility = false;
  WalletAccount walletAccount = account as WalletAccount;
  String privateKey = await WalletAccount.getPrivateKey(walletAccount);
  //walletAccount.mnemonic;
  //walletAccount.wallet.extract().;

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
                          'Private Key',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        readOnly: true,
                        autofocus: true,
                        maxLines: 5,
                        initialValue: privateKey,
                        style: TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          contentPadding: EdgeInsets.all(8),
                          hintText: "Enter an account name",
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

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  border:
                                      Border.all(color: kBackgroundDark10Color),
                                  borderRadius: BorderRadius.circular(10)),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: const Text(
                                    'Done',
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
                                onTap: () {
                                  copyToKeyboard(context, privateKey, false);
                                  setModalState(
                                    () {
                                      errorVisibility = true;
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: const Text(
                                    'Copy',
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

void copyToKeyboard(BuildContext context, String value, bool enableSnackBar) {
  Clipboard.setData(
    ClipboardData(text: value),
  ).then(
    (_) {
      if (enableSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Copied"),
          ),
        );
      }
    },
  );
}

/*
 * Apply changes to an account
 */
void renameAccount(Account account, WidgetRef ref, String accountName) {
  final accountsProv = ref.read(accountsProvider.notifier);
  accountsProv.renameAccount(account, accountName);
}
