import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kitepay/settings/widgets/logout_dialog.dart';
import 'package:kitepay/utilies/const/color_constant.dart';
import 'package:kitepay/utilies/url_launch.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  SettingsPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        title: const Text("Settings"),
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
                    title: const Text('Manage Accounts'),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        Navigator.pushNamed(context, "/manage_accounts");
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/manage_accounts");
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: kWhiteColor,
                  ),
                  ListTile(
                    title: const Text('Change Network'),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        Navigator.pushNamed(context, "/manage_networks");
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/manage_networks");
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
                    title: const Text('Kitepay Twitter'),
                    trailing: IconButton(
                      icon: Icon(Icons.call_made_outlined),
                      onPressed: () {
                        LaunchURL.openURL(context, 'https://twitter.com/kytpay');
                      },
                    ),
                    onTap: () {
                      LaunchURL.openURL(context, 'https://twitter.com/kytpay');
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: kWhiteColor,
                  ),
                  ListTile(
                    title: const Text('Kitepay Medium'),
                    trailing: IconButton(
                      icon: Icon(Icons.call_made_outlined),
                      onPressed: () {
                        LaunchURL.openURL(context, 'https://kytpay.medium.com/');
                      },
                    ),
                    onTap: () {
                      LaunchURL.openURL(context, 'https://kytpay.medium.com/');
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
                    title: const Text('Privacy policy'),
                    trailing: IconButton(
                      icon: Icon(Icons.call_made_outlined),
                      onPressed: () {
                        LaunchURL.openURL(context,
                            'https://kitepay.org/privacy-policy.html');
                      },
                    ),
                    onTap: () {
                      LaunchURL.openURL(context,
                          'https://kitepay.org/privacy-policy.html');
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: kWhiteColor,
                  ),
                  ListTile(
                    title: const Text('Terms of Use'),
                    trailing: IconButton(
                      icon: Icon(Icons.call_made_outlined),
                      onPressed: () {
                        LaunchURL.openURL(context,
                            'https://pinnate-salt-274.notion.site/Terms-Conditions-72a785ac93a94cd9b97ba6fb8d60b3fd');
                      },
                    ),
                    onTap: () {
                      LaunchURL.openURL(context,
                          'https://pinnate-salt-274.notion.site/Terms-Conditions-72a785ac93a94cd9b97ba6fb8d60b3fd');
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: kWhiteColor,
                  ),
                  ListTile(
                    title: const Text('Support'),
                    trailing: IconButton(
                      icon: Icon(Icons.call_made_outlined),
                      onPressed: () {
                        LaunchURL.openURL(context,
                            'mailto:kitepayments@gmail.com?subject=Kitepay🪁 customer support');
                      },
                    ),
                    onTap: () {
                      LaunchURL.openURL(context,
                          'mailto:kitepayments@gmail.com?subject=Kitepay🪁 customer support');
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: kWhiteColor,
                  ),
                  ListTile(
                    title: const Text('Open Source Licenses'),
                    trailing: IconButton(
                      icon: Icon(Icons.call_made_outlined),
                      onPressed: () {
                        LaunchURL.openURL(context,
                            'https://pinnate-salt-274.notion.site/Open-Source-Licenses-cdff0e26a25b4738a82f53410014f7a9');
                      },
                    ),
                    onTap: () {
                      LaunchURL.openURL(context,
                          'https://pinnate-salt-274.notion.site/Open-Source-Licenses-cdff0e26a25b4738a82f53410014f7a9');
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
                onTap: () {
                  logOutDialog(context);
                },
                child: ListTile(
                  title: const Text(
                    'Log out',
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

// void openURL(BuildContext context, String url) async {
//   bool canOpen = await canLaunch(url);

//   if (canOpen) {
//     await launch(url);
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Could not open the URL"),
//       ),
//     );
//   }
// }
