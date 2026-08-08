import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("buid");
    return Scaffold(
      appBar: AppBar(title: Text('nav_home'.tr)),
      body: Center(child: Text('Home Content', style: Theme.of(context).textTheme.bodyLarge)),
    );
  }
}