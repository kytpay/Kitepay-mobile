import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/dialogs/custom_dialogs.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import '../provider/states.dart';

/*
 * Getting Started Page
 */
class ImportWallet extends ConsumerStatefulWidget {
  const ImportWallet({Key? key}) : super(key: key);

  @override
  ImportWalletState createState() => ImportWalletState();
}

class ImportWalletState extends ConsumerState<ImportWallet> {
  late String mnemonic;
  String? accountName;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    //final accountsManager = ref.read(accountsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Import wallet')),
      floatingActionButton: Container(
        color: kWhiteColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(kPrimanyColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide(color: kPrimanyColor)))),
            child: ListTile(
              title: const Text(
                'Import wallet',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: kWhiteColor, fontWeight: FontWeight.w600),
              ),
            ),
            onPressed: () => importWallet(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                      "Name it as you wish, and you can always change it later"),
                ),
                TextFormField(
                  initialValue: accountName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintText: "Enter an account name",
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Icon(Icons.person),
                    ),
                  ),
                  autofocus: true,
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
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Secret Recovery Phrase',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    autofocus: true,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Empty seedphrase';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (String value) async {
                      mnemonic = value;
                    },
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.only(bottom: 30),
                //   child: NetworkSelector(
                //     onSelected: (NetworkUrl? url) {
                //       if (url != null) {
                //         networkURL = url;
                //       }
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void importWallet() async {
    FocusScope.of(context).unfocus();

    final accountsProv = ref.read(accountsProvider.notifier);

    // Import the account
    if (accountName != null) {
      //Progress bar
      onLoadingDialog(
        context,
        GradientCircularProgressIndicator(
          gradient: kGradientProgressbar,
          radius: 150,
        ),
      );
      accountsProv
          .importWallet(ref.watch(networkClient.notifier).state, mnemonic, accountName!.trim())
          .then((account) async {
        ref.read(selectedAccountProvider.notifier).state = account;
        var loginBox = await Hive.openBox('auth');
        loginBox.put('loggedIn', 'true');
        // Go to Home page
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a user name!"),
        ),
      );
    }
  }
}
