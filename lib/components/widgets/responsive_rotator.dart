import 'package:flutter/material.dart';

class ResponsiveRotator extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveRotator({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (screenSize.width > 700) {
      return Row(
        children: children,
      );
    } else {
      return Column(
        children: children,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
    }
  }
}
