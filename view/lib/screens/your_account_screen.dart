import 'package:flutter/material.dart';

class YourAccountScreen extends StatelessWidget {
  const YourAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Account'),
      ),
      body: const Center(
        child: Text('Your Account Screen - Under construction', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
