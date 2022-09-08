import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LaunchURL {
  static void openURL(BuildContext context, String url) async {
    if (!await launchUrlString(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open the URL"),
        ),
      );
    }
  }
}
