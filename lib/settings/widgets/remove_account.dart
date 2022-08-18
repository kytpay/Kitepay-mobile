import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/provider/states.dart';

Future<void> removeAccountDialog(BuildContext context, Account account) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, _) {
          return AlertDialog(
            title: const Text('Warning! This account will be removed'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      "\nMake sure you backup you Mnemonic words, so later you can re-derive your account using it"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  removeAccount(ref, context, account);
                },
              ),
            ],
          );
        },
      );
    },
  );
}

/*
 * Remove an account by passing it's instance
 */
Future<void> removeAccount(
    WidgetRef ref, BuildContext context, Account account) async {
  final accountsProv = ref.read(accountsProvider.notifier);
  accountsProv.removeAccount(ref.watch(networkClient.notifier).state, account);
  if (ref.watch(accountsProvider).values.length == 0) {
    ref.read(selectedAccountProvider.notifier).state = null;
    //logOut(ref, context, null);
    await accountsProv.logOut(context, null);
    print('VAR1');
  } else {
    ref.read(selectedAccountProvider.notifier).state =
        accountsProv.state.values.first;
    //accountsProv.refreshAccounts(ref.watch(networkClient.notifier).state);
    print('VAR2');
    Navigator.of(context).popUntil(ModalRoute.withName('/manage_accounts'));
  }
}
