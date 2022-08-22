import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/components/material_key.dart';
import 'package:kitepay/home/home_screen.dart';
import 'package:kitepay/network/base_account.dart';
import 'package:kitepay/network/wallet_account.dart';
import 'package:kitepay/payments/utilities/uri_pay.dart';
import 'package:kitepay/profile/profile_page.dart';
import 'package:kitepay/provider/states.dart';
import 'package:kitepay/transtactions/transactions_page.dart';
import 'package:kitepay/utilies/nfc/NdefRecordInfo.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/utilies/nfc/nfc.dart';
import 'package:kitepay/utilies/url_launch.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nfc_manager/nfc_manager.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('HomePage');
    final selectedAccount = ref.watch(selectedAccountProvider);
    final accounts = ref.watch(accountsProvider).values.toList();
    final textTheme = Theme.of(context).textTheme;

    final Widget page;

    final currentPage = useState(0);
    if (selectedAccount == null) {
      // If the account is loaded and no account is found then open the Account Selection page in order to create or import an account

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/onboarding_page');
      });
    }
    switch (currentPage.value) {
      case 0:
        page = HomeScreen(selectedAccount!);
        break;

      case 1:
        page = AccountTransactions(
          key: Key(selectedAccount!.address),
          account: selectedAccount,
        );
        break;

      case 2:
        page = ProfilePage(
          key: Key(selectedAccount!.name),
          account: selectedAccount,
        );
        break;

      default:
        page = HomeScreen(selectedAccount!);
    }

    //Initialize NFC

    NFC.setup(ref);
    NFC.enableNfc();
    //NfcMethodChannel().configureChannel(ref);
    //NFC.enableNfc();

    // NFC.enableNfc(ref);

    // List of items in our dropdown menu
    var dropDownItems = ["Get support", "Send feedback"];

    //final nearbyCheckBox = useState(false);

    // init NearbyMessagesApi
    // FlutterNearbyMessagesApi nearbyMessagesApi = FlutterNearbyMessagesApi();

    // This callback gets the message when an a nearby device sends one
    // nearbyMessagesApi.onFound = (message) {
    //   print('~~~onFound : $message');
    //   uriPay(context, selectedAccount as WalletAccount, message);
    // };

    // This callback gets the message when a nearby device leaves
    // nearbyMessagesApi.onLost = (message) {
    //   print('~~~onLost : $message');
    // };

    // // Listen status when publish and subscribe
    // // enum GNSOperationStatus { inactive, starting, active }
    // nearbyMessagesApi.statusHandler = (status) {
    //   print('~~~statusHandler : $status');
    // };

    // // Use your messages to nearby permission alert
    // nearbyMessagesApi.setPermissionAlert(
    //     'Your title', 'Your message', 'Deny', 'Grant');

    // nearbyMessagesApi.permissionHandler = (status) {
    //   print(status);
    // };

    // nearbyMessagesApi.bluetoothPowerErrorHandler = (args) {
    //   print('~~~ bluetoothPowerErrorHandler');
    // };

    // nearbyMessagesApi.bluetoothPermissionErrorHandler = (args) {
    //   print('~~~ bluetoothPermissionErrorHandler');
    // };

    // nearbyMessagesApi.microphonePermissionErrorHandler = (args) {
    //   print('~~~ microphonePermissionErrorHandler');
    // };

    return Scaffold(
      key: AppNavigation.homeScaffoldKey,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.account_circle_sharp, size: kToolbarHeight - 10),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       nearbyCheckBox.value ^= true;
          //       print(nearbyCheckBox.value);
          //       if (nearbyCheckBox.value == true) {
          //         nearbyMessagesApi.backgroundSubscribe();
          //       } else if (nearbyCheckBox.value == false) {
          //         // backgroundUnsubscribe
          //         nearbyMessagesApi.backgroundUnsubscribe();
          //       } else {}
          //     },
          //     icon: Icon(Icons.nfc, size: kToolbarHeight - 25)),
          // Checkbox(
          //     value: nearbyCheckBox.value,
          //     onChanged: (value) {
          //       print(value);
          //       if (value == "true") {
          //         nearbyMessagesApi.backgroundSubscribe();

          //         // This callback gets the message when an a nearby device sends one
          //         nearbyMessagesApi.onFound = (message) {
          //           print('~~~onFound : $message');
          //           uriPay(context, selectedAccount as WalletAccount, message);
          //         };

          //         nearbyCheckBox.value ^= true;
          //         print(value);
          //       } else if (value == "false") {
          //         // backgroundUnsubscribe
          //         nearbyMessagesApi.backgroundUnsubscribe();
          //         nearbyCheckBox.value ^= true;
          //       } else {}
          //     }),
          // NeumorphicCheckbox(
          //     value: nearbyCheckBox.value,
          // onChanged: (value) {
          //   print(value);
          //   if (value == "true") {
          //     nearbyMessagesApi.backgroundSubscribe();

          //     // This callback gets the message when an a nearby device sends one
          //     nearbyMessagesApi.onFound = (message) {
          //       print('~~~onFound : $message');
          //       uriPay(context,
          //           selectedAccount as WalletAccount, message);
          //     };

          //     nearbyCheckBox.value = false;
          //   } else if (value == "false") {
          //     // backgroundUnsubscribe
          //     nearbyMessagesApi.backgroundUnsubscribe();
          //     nearbyCheckBox.value = true;
          //   } else {}
          // }),
          DropdownButton(
            icon: Icon(Icons.help_outline, size: kToolbarHeight - 23),
            iconEnabledColor: kWhiteColor,
            iconDisabledColor: kWhiteColor,
            underline: Container(),
            onChanged: (String? value) {
              if (value == "Get support") {
                LaunchURL.openURL(context,
                    'mailto:kitepayments@gmail.com?subject=Kitepay🪁 customer support');
              } else if (value == "Send feedback") {
                LaunchURL.openURL(context,
                    'mailto:kitepayments@gmail.com?subject=Kitepay🪁 customer feedback');
              } else {}
            },
            items: dropDownItems.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(items),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, size: kToolbarHeight - 25),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: page,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(gradient: kGradient),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Profile',
                  style: textTheme.headline5,
                ),
              ),
            ),
            Stack(children: <Widget>[
              Container(
                height: 30.0,
                //    color: Colors.black,
              ),
              Container(
                //   color: Colors.black,
                child: SizedBox(
                  child: FractionalTranslation(
                    translation: Offset(0.0, -0.2),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: kWhiteColor,
                              backgroundImage:
                                  AssetImage("assets/png/user.png"),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedAccount.name,
                              style: textTheme.headline5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
              title: Text(
                "Manage Accounts",
                style: textTheme.titleMedium,
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(context, '/manage_accounts'),
            ),
            Container(
              //color: Colors.black,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: kGreyLightColor,
                    child: (ListTile(
                      leading: Icon(Icons.person),
                      title: Text(accounts[index].name),
                      style: ListTileStyle.list,
                      trailing:
                          selectedAccount.address == accounts[index].address
                              ? Icon(Icons.done)
                              : null,
                      onTap: () {
                        ref.read(selectedAccountProvider.notifier).state =
                            accounts[index];
                      },
                    )),
                  );
                },
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () => Navigator.pushNamed(context, '/settings')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int page) {
          currentPage.value = page;
        },
        elevation: 0,
        showUnselectedLabels: true,
        currentIndex: currentPage.value,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            tooltip: 'Home',
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            tooltip: 'History',
            icon: Icon(Icons.swap_horiz),
            label: 'History',
          ),
          BottomNavigationBarItem(
            tooltip: 'Profile',
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static Future<void> nfcInit(BuildContext context, Account account) async {
    if (await NfcManager.instance.isAvailable()) {
      // Start Session
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          Ndef? ndef = Ndef.from(tag);
          if (ndef != null) {
            var ndefMessage = ndef.cachedMessage;

            if (ndefMessage != null) {
              print(ndefMessage);

              var record = ndefMessage.records[0];
              var recordText = NdefRecordInfo.fromNdef(record).subtitle;
              print(recordText);

              uriPay(context, account as WalletAccount, recordText);
            }
          }
        },
      );
    }
  }
  // NFCAvailability availability;
  // try {
  //   availability = await FlutterNfcKit.nfcAvailability;
  // } on PlatformException {
  //   availability = NFCAvailability.not_supported;
  // }
  // if (availability == NFCAvailability.available) {
  //   var tag = await FlutterNfcKit.poll(timeout: Duration(minutes: 10));

  //   //print(jsonEncode(tag));
  //   // if (tag.type == NFCTagType.iso7816) {
  //   //   var result = await FlutterNfcKit.transceive("00B0950000",
  //   //       timeout: Duration(
  //   //           seconds:
  //   //               5)); // timeout is still Android-only, persist until next change
  //   //   print(result);
  //   // }

  //   // read NDEF records if available
  //   if (tag.ndefAvailable ?? false) {
  //     /// decoded NDEF records (see [ndef.NDEFRecord] for details)
  //     /// `UriRecord: id=(empty) typeNameFormat=TypeNameFormat.nfcWellKnown type=U uri=https://github.com/nfcim/ndef`
  //     for (var record in await FlutterNfcKit.readNDEFRecords(cached: false)) {
  //       print(record.toString());
  //       if (record is ndef.TextRecord) {
  //         var recordText = record.text;
  //         if (recordText != null && recordText.length > 0) print(recordText);
  //         uriPay(context, account as WalletAccount, recordText!);
  //       }
  //     }

  //     // var ndefRecords = await FlutterNfcKit.readNDEFRecords();
  //     // var ndefRecord = ndefRecords[0];
  //     // if (ndefRecord is ndef.TextRecord) {
  //     //   print(ndefRecord.text ?? "Empty");
  //     // }
  //     // var ndefString = '';

  //     // for (int i = 0; i < ndefRecords.length; i++) {
  //     //   ndefString += '${i + 1}: ${ndefRecords[i]}\n';
  //     // }

  //     // print("NDEF $ndefString");
  //     // jsonEncode(ndefString);
  //   }
  // }
  //  }

  // Future<void> setupNearby(FlutterNearbyMessagesApi nearbyMessagesApi) async {
  //   await nearbyMessagesApi
  //       .setAPIKey('AIzaSyCOTfX3ENbfNA-Rq22kqK-HVKaVGNDTnG4');

  //   // This callback gets the message when a nearby device leaves
  //   nearbyMessagesApi.onLost = (message) {
  //     print('~~~onLost : $message');
  //   };

  //   // Listen status when publish and subscribe
  //   // enum GNSOperationStatus { inactive, starting, active }
  //   nearbyMessagesApi.statusHandler = (status) {
  //     print('~~~statusHandler : $status');
  //   };

  //   // Use your messages to nearby permission alert
  //   nearbyMessagesApi.setPermissionAlert(
  //       'Your title', 'Your message', 'Deny', 'Grant');

  //   nearbyMessagesApi.permissionHandler = (status) {
  //     print(status);
  //   };

  //   nearbyMessagesApi.bluetoothPowerErrorHandler = (args) {
  //     print('~~~ bluetoothPowerErrorHandler');
  //   };

  //   nearbyMessagesApi.bluetoothPermissionErrorHandler = (args) {
  //     print('~~~ bluetoothPermissionErrorHandler');
  //   };

  //   nearbyMessagesApi.microphonePermissionErrorHandler = (args) {
  //     print('~~~ microphonePermissionErrorHandler');
  //   };
  // }
}
