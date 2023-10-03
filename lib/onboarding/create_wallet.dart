import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/dialogs/custom_dialogs.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/provider/states.dart';


/*
 * Getting Started Page
 */
class CreateWallet extends ConsumerStatefulWidget {
  const CreateWallet({Key? key}) : super(key: key);

  @override
  CreateWalletState createState() => CreateWalletState();
}

class CreateWalletState extends ConsumerState<CreateWallet>
    with TickerProviderStateMixin {
  String? accountName;

  CreateWalletState();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Create wallet')),
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
                'Create a new wallet',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: kWhiteColor, fontWeight: FontWeight.w600),
              ),
            ),
            onPressed: () => createWallet(),
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
                // Padding(
                //   padding: const EdgeInsets.only(top: 10, bottom: 30),
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

  void createWallet() async {
    final accountsProv = ref.read(accountsProvider.notifier);

    if (accountName != null) {
      try {
        //Progress bar
        onLoadingDialog(
          context,
          GradientCircularProgressIndicator(
            gradient: kGradientProgressbar,
            radius: 150,
          ),
        );

        await accountsProv
            .createWallet(
                ref.watch(networkClient.notifier).state,accountName!.trim())
            .then((account) async {
          ref.read(selectedAccountProvider.notifier).state = account;
          var loginBox = await Hive.openBox('auth');
          loginBox.put('loggedIn', 'true');
          // Go to Home page
          Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
        });
      } catch (err) {
        Navigator.pop(context);
        print(err.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Can't create account"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a user name!"),
        ),
      );
    }
  }
}
