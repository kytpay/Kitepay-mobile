import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/provider/states.dart';

Future<void> logOutDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, _) {
          return AlertDialog(
            title: const Text('Warning! your all accounts will be removed'),
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
                  'Log out',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  logOut(ref, context, "Logged out!");
                },
              ),
            ],
          );
        },
      );
    },
  );
}
Future<void> logOut(WidgetRef ref,BuildContext context, String? message) async {
  try {
    final accountsProv = ref.read(accountsProvider.notifier);
     print('VAR3');
   await accountsProv.logOut(context, message);
  } catch (error) {
    print(error.toString());
  }
}
