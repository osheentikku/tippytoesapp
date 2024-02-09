import 'package:flutter/material.dart';

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  const ResponsivePadding({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: MediaQuery.of(context).size.width > 650
            ? EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 3.8)
            : const EdgeInsets.all(0),
        child: child,
      ),
    );
  }
}
