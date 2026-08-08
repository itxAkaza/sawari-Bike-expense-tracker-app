import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('nav_alerts'.tr)),
      body: Center(child: Text('Alerts Content', style: Theme.of(context).textTheme.bodyLarge)),
    );
  }
}