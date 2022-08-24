import 'package:flutter/material.dart';

class PayValidator {
  static bool validAmount(BuildContext context, ValueNotifier<String> amount) {
    bool valid = false;
    String value = amount.value.trim();

    if (value.length > 0) {
      valid = true;
      try {
        double.parse(value);
      } catch (err) {
        valid = false;
        print(err.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter a valid amount. Ex: 4.01"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Amount can't be empty"),
        ),
      );
    }

    return valid;
  }

  static bool validAddress(
      BuildContext context, ValueNotifier<String> address) {
    bool valid = false;
    String value = address.value.trim();

    if (value.length > 0) {
      print(value.length);
      if (value.length < 43 || value.length > 44) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid address"),
          ),
        );
      } else {
        valid = true;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Address can't be empty"),
        ),
      );
    }

    return valid;
  }
}
