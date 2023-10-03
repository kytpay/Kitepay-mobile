import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/settings/widgets/remove_account.dart';
import 'package:kitepay/settings/edit_account.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/provider/states.dart';

class ManageAccountsPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var editAccounts = useState<bool>(false);
    String editButtonText = 'Edit';
    var accountsProv = ref.watch(accountsProvider);
    var accounts = accountsProv.values.toList();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        title: const Text("Accounts"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              child: Text(
                editButtonText,
                style: TextStyle(color: kWhiteColor),
              ),
              onPressed: () {
                // setState(() {
                //toggle between true and false
                editAccounts.value ^= true;
                editAccounts.value
                    ? editButtonText = 'Done'
                    : editButtonText = 'Edit';
                print(editAccounts.toString());
                //});
              },
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              'Add / Import Wallet',
              textAlign: TextAlign.center,
              style: TextStyle(color: kWhiteColor),
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/onboarding_page');
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Consumer(
          builder: (context, ref, child) {
            //   final accounts = ref.watch(accountsProvider).values.toList();
            return ListView.builder(
              itemCount: accounts.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: ((context, index) {
                //  children: accountsProv.values.toList().map((account) {
                return Row(
                  children: [
                    editAccounts.value
                        ? Expanded(
                            child: IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                size: 30,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                removeAccountDialog(context, accounts[index]);
                              },
                            ),
                          )
                        : Container(),
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
                        decoration: BoxDecoration(
                            color: kBackgroundDarkColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            accounts[index].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            accounts[index].address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditAccountPage(accounts[index])));
                            },
                          ),
                          enableFeedback: true,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditAccountPage(accounts[index])));
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class ManageAccountsPageState extends State<ManageAccountsPage> {
  bool editAccounts = false;
  String editButtonText = 'Edit';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        title: const Text("Accounts"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              child: Text(
                editButtonText,
                style: TextStyle(color: kWhiteColor),
              ),
              onPressed: () {
                setState(() {
                  //toggle between true and false
                  editAccounts ^= true;
                  editAccounts
                      ? editButtonText = 'Done'
                      : editButtonText = 'Edit';
                  print(editAccounts.toString());
                });
              },
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              'Add / Import Wallet',
              textAlign: TextAlign.center,
              style: TextStyle(color: kWhiteColor),
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/onboarding_page');
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Consumer(
          builder: (context, ref, child) {
            final accounts = ref.watch(accountsProvider).values.toList();
            return ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: accounts.map((account) {
                return Row(
                  children: [
                    editAccounts
                        ? Expanded(
                            child: IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                size: 30,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                removeAccountDialog(context, account);
                              },
                            ),
                          )
                        : Container(),
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
                        decoration: BoxDecoration(
                            color: kBackgroundDarkColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            account.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            account.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditAccountPage(account)));
                            },
                          ),
                          enableFeedback: true,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditAccountPage(account)));
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
