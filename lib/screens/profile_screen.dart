import 'package:flutter/material.dart';
import '../theme/cred_theme.dart';
import '../widgets/cred_arrow.dart';
import '../widgets/shimmer_overlay.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static Route<void> route() {
    return PageRouteBuilder(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const ProfileScreen(),
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(slide),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CredColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _Header(),
            const SizedBox(height: 24),
            const _ProfileRow(),
            const SizedBox(height: 20),
            const _CredGarageBanner(),
            const SizedBox(height: 28),
            _StatsCard(),
            const SizedBox(height: 28),
            const _SectionLabel('YOUR REWARDS & BENEFITS'),
            const SizedBox(height: 12),
            _RewardsCard(),
            const SizedBox(height: 28),
            const _SectionLabel('TRANSACTIONS & SUPPORT'),
            const SizedBox(height: 12),
            _TransactionsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const CredArrow(length: 32, headSize: 6, strokeWidth: 1.5, color: CredColors.primary, isBack: true),
        ),
        const SizedBox(width: 12),
        Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CredColors.divider, width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chat_bubble_outline, color: CredColors.primary, size: 14),
              SizedBox(width: 8),
              Text(
                'support',
                style: TextStyle(
                  color: CredColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: CredColors.divider, width: 0.5),
            color: CredColors.surfaceLight,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/images/profile.png', fit: BoxFit.cover),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pooja Hooda',
                style: TextStyle(
                  color: CredColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'member since Dec, 2025',
                style: TextStyle(
                  color: CredColors.secondary.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: CredColors.divider, width: 0.6),
          ),
          child: const Icon(Icons.edit_outlined, color: CredColors.primary, size: 16),
        ),
      ],
    );
  }
}

class _CredGarageBanner extends StatelessWidget {
  const _CredGarageBanner();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return ClipRRect(
      borderRadius: radius,
      child: ShimmerOverlay(
        shimmerColor: const Color.fromRGBO(255, 248, 229, 0.55),
        shimmerWidth: 14,
        gapWidth: 6,
        duration: const Duration(milliseconds: 2400),
        delay: const Duration(milliseconds: 1400),
        child: Container(
          height: 84,
          decoration: BoxDecoration(
            color: CredColors.surface,
            borderRadius: radius,
            border: Border.all(color: CredColors.divider, width: 0.5),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _DiagonalStripesPainter()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CredColors.surfaceLight,
                        border: Border.all(color: CredColors.divider, width: 0.5),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_outlined,
                        color: CredColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'get to know your vehicles, inside out',
                            style: TextStyle(
                              color: CredColors.secondary.withOpacity(0.95),
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Text(
                                'CRED garage',
                                style: TextStyle(
                                  color: CredColors.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 10),
                              CredArrow(length: 22, headSize: 5, strokeWidth: 1.5, color: CredColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    final startX = size.width - 70;
    for (int i = 0; i < 3; i++) {
      final off = i * 22.0;
      final p1 = Offset(startX + off, -20);
      final p2 = Offset(startX + off + size.height + 40, size.height + 20);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CredColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _StatRow(
            icon: Icons.speed_outlined,
            label: 'credit score',
            value: '740',
          ),
          _Divider(),
          _StatRow(
            icon: Icons.currency_rupee,
            label: 'lifetime cashback',
            value: '₹35',
          ),
          _Divider(),
          _StatRow(
            icon: Icons.account_balance_outlined,
            label: 'bank balance',
            value: 'check',
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: CredColors.secondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: CredColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: CredColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          const CredArrow(length: 18, headSize: 4.5, strokeWidth: 1.2, color: CredColors.secondary),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: CredColors.divider,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CredColors.secondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _RewardsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CredColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _RewardRow(title: 'cashback balance', subtitle: '₹0'),
          _Divider(),
          _RewardRow(title: 'coins', subtitle: '24,781'),
          _Divider(),
          _RewardRow(
            title: 'win assured ₹200',
            subtitle: 'refer and earn',
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String title;
  final String subtitle;
  const _RewardRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CredColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CredColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const CredArrow(length: 18, headSize: 4.5, strokeWidth: 1.2, color: CredColors.secondary),
        ],
      ),
    );
  }
}

class _TransactionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CredColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'all transactions',
                style: TextStyle(
                  color: CredColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const CredArrow(length: 18, headSize: 4.5, strokeWidth: 1.2, color: CredColors.secondary),
          ],
        ),
      ),
    );
  }
}
