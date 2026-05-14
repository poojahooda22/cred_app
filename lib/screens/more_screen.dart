import 'package:flutter/material.dart';
import '../theme/cred_theme.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'more',
        style: TextStyle(color: CredColors.secondary, fontSize: 16),
      ),
    );
  }
}