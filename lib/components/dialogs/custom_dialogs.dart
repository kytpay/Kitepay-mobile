import 'package:flutter/material.dart';
import 'package:kitepay/utilies/const/color_constant.dart';

void onLoadingDialog(BuildContext context, Widget widget,
    {Color color = Colors.transparent}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: color,
        content: SingleChildScrollView(child: widget),
      );
    },
  );
}

void customAlertDialog(BuildContext context, Widget widget,
    {Color color = const Color.fromARGB(200, 29, 54, 62)}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: color,
        content: SingleChildScrollView(
          child: widget,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Close',
              style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              // Close the dialog
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
