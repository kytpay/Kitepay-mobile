import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kitepay/components/material_key.dart';
import 'package:kitepay/utilies/const/color_constant.dart';

class NetworkConnectivity {
  static Future<bool> isConnected({bool snackbar = false}) async {
    if (await InternetConnectionChecker().hasConnection) {
      return true;
    } else {
      if (snackbar) {
        offlineSnackbar();
      }
      print("Network not connected");
      return false;
    }
  }

  static void offlineSnackbar() {
    var context = AppNavigation.materialKey.currentContext!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: kWhiteColor,
              size: 35,
            ),
            SizedBox(
              width: 10,
            ),
            Text('No internet connection')
          ],
        ),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.none,
      ),
    );
  }
}
