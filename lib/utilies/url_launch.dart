import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchURL {
 static void openURL(BuildContext context, String url) async {
    bool canOpen = await canLaunchUrl(Uri.parse(url));

    if (canOpen) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open the URL"),
        ),
      );
    }
  }
}
