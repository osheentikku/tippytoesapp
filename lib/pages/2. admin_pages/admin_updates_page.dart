import 'package:flutter/material.dart';

class AdminUpdatesPage extends StatefulWidget {
  const AdminUpdatesPage({super.key});

  @override
  State<AdminUpdatesPage> createState() => _AdminUpdatesPageState();
}

class _AdminUpdatesPageState extends State<AdminUpdatesPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Updates Page")),
    );  }
}