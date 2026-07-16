import 'package:flutter/material.dart';

/// A UI screen for visualizing cache entries and synchronization queue status.
class InspectorScreen extends StatelessWidget {
  /// Creates an [InspectorScreen].
  const InspectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Offline Sync Inspector')));
  }
}
