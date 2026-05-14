import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neopop/neopop.dart';
import '../theme/cred_theme.dart';
import '../widgets/store_deals_bag_icon.dart';
import '../widgets/credit_score_dial_icon.dart';
import '../widgets/emv_chip.dart';
import '../widgets/neu_watermark.dart';
import '../widgets/animated_statement_pill.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int _topTabIndex = 0; // 0 = TOTAL DUE, 1 = RECENT SPENDS

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildTopBar()),
          SliverToBoxAdapter(child: _buildHero()),
          SliverToBoxAdapter(child: _buildPromoPill()),
          SliverToBoxAdapter(child: _buildCard()),
          SliverToBoxAdapter(child: _buildStatementPill()),
          SliverToBoxAdapter(child: _buildDoMoreSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _circleIconButton(Icons.percent),
          const Spacer(),
          _topToggle(),
          const Spacer(),
          _circleIconButton(Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CredColors.surface,
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: Icon(icon, color: CredColors.primary, size: 18),
    );
  }

  Widget _topToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CredColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleSegment('TOTAL DUE', 0),
          _toggleSegment('RECENT SPENDS', 1),
        ],
      ),
    );
  }

  Widget _toggleSegment(String label, int index) {
    final active = _topTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _topTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? CredColors.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? CredColors.primary : CredColors.tabInactive,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          Text(
            'YOU HAVE',
            style: TextStyle(
              color: CredColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'no due',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: CredColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down,
                  color: CredColors.primary, size: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoPill() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: CredColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: CredColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            _stackedBrandDots(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'pay bills & unlock rewards.',
                style: TextStyle(
                  color: CredColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: CredColors.secondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _stackedBrandDots() {
    Widget dot(Color c, String letter) => Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c,
            border: Border.all(color: CredColors.surface, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
    return SizedBox(
      width: 56,
      height: 22,
      child: Stack(
        children: [
          Positioned(left: 0, child: dot(const Color(0xFFCC0066), 'Q')),
          Positioned(left: 16, child: dot(const Color(0xFF1B5E20), 'TH')),
          Positioned(left: 32, child: dot(const Color(0xFFFFC107), 'b')),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: AspectRatio(
        aspectRatio: 1.65,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3D2A66),
                Color(0xFF2A1D4A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2A1D4A).withValues(alpha: 0.45),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Big watermark "N"
              const Positioned.fill(
                child: NeuWatermarkWidget(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // top row: bank tag + amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 0.5),
                        ),
                        child: const Text(
                          'HDFC BANK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '₹0.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'NO DUES',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '•• 7692',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chip
                  const EmvChipWidget(),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'POOJA HOODA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      _payMoreButton(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipLine() {
    return Container(
      width: 22,
      height: 1.2,
      color: const Color(0xFF7A5A28).withValues(alpha: 0.7),
    );
  }

  Widget _payMoreButton() {
    return NeoPopButton(
      color: Colors.white,
      onTapUp: () => HapticFeedback.vibrate(),
      onTapDown: () => HapticFeedback.vibrate(),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          'Pay more',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStatementPill() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Center(
        child: AnimatedStatementPill(
          primaryText: 'april statement generated',
          primaryIcon: Icons.info_outline,
          alternateText: 'view details',
          interval: Duration(seconds: 2),
          slideDuration: Duration(milliseconds: 400),
        ),
      ),
    );
  }

  Widget _buildDoMoreSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DO MORE WITH A CARD USING CRED',
                style: TextStyle(
                  color: CredColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CredColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CredColors.divider, width: 0.5),
                ),
                child: Text(
                  '05',
                  style: TextStyle(
                    color: CredColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _doMoreTile(
                  iconWidget: const StoreDealsBagIcon(size: 32),
                  title: 'STORE DEALS',
                  subtitle: 'unlock member-\nexclusive deals',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _doMoreTile(
                  iconWidget: const CreditScoreDialIcon(size: 32),
                  title: 'CREDIT SCORE',
                  subtitle: 'stay updated on\nyour credit standing',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doMoreTile({
    required Widget iconWidget,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CredColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CredColors.surfaceLight,
              border: Border.all(color: CredColors.divider, width: 0.5),
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: CredColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: CredColors.secondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
