import 'package:flutter/material.dart';
import '../theme/cred_theme.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'rewards',
        style: TextStyle(color: CredColors.secondary, fontSize: 16),
      ),
    );
  }
}