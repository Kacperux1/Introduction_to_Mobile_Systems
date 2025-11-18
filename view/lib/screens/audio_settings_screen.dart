import 'package:flutter/material.dart';

class AudioSettingsScreen extends StatelessWidget {
  const AudioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Settings'),
      ),
      body: const Center(
        child: Text('Audio Settings Screen - Under construction', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
