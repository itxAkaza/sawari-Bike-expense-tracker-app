import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('nav_history'.tr)),
      body: Center(child: Text('History Content', style: Theme.of(context).textTheme.bodyLarge)),
    );
  }
}