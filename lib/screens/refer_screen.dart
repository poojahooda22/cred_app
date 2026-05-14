import 'package:flutter/material.dart';
import '../theme/cred_theme.dart';

class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'refer & earn',
        style: TextStyle(color: CredColors.secondary, fontSize: 16),
      ),
    );
  }
}
