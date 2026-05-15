import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neopop/neopop.dart';
import 'package:rive/rive.dart' hide Animation;
import '../theme/cred_theme.dart';
import '../widgets/marquee_text.dart';
import '../widgets/isometric_bag_icon.dart';
import '../widgets/animated_explore_chip.dart';
import '../widgets/rewards_logo_dispenser.dart';
import '../widgets/fluid_simulation_widget.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  static int _liveCount = 5060684;
  late int _countFrom;
  late int _countTo;


  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();

    final bump = 25 + Random().nextInt(125);
    _countFrom = _liveCount;
    _liveCount += bump;
    _countTo = _liveCount;

  }

  @override
  void dispose() {
    _animController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar()),
              SliverToBoxAdapter(child: _buildLiveNowCard()),
              SliverToBoxAdapter(child: _buildMoneyMatters()),
              SliverToBoxAdapter(child: _buildForYouSection()),
              SliverToBoxAdapter(child: _buildExploreCred()),
              SliverToBoxAdapter(child: _buildRewardsCard()),
              SliverToBoxAdapter(child: _buildFluidSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          // Profile avatar
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(ProfileScreen.route()),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CredColors.divider, width: 1),
                color: CredColors.surfaceLight,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/profile.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Marquee pill
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50).withOpacity(0.15),
                      const Color(0xFF4CAF50).withOpacity(0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.8),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Tilted heart icon container
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, right: 5.0),
                      child: IsometricBagIcon(size: 24),
                    ),
                    const SizedBox(width: 10),
                    // Animated text ticker
                    const Expanded(
                      child: MarqueeWidget(
                        text: "week's best deals. Shop now.",
                        style: TextStyle(
                          color: Colors.white, // Changed to white for dark background
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Notification bell
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CredColors.divider, width: 0.5),
            ),
            child: const Icon(Icons.notifications_outlined, color: CredColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveNowCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CredColors.divider, width: 0.5),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CredColors.surfaceLight,
              CredColors.surface,
              Color(0xFF2D251E), // Opaque blend of accent and surface to prevent black edges
              CredColors.cardDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            // "LIVE NOW" badge
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // UPI logo top-right
            Positioned(
              top: 12,
              right: 16,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    'UPI',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            // Rive coin animation
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              height: 190,
              child: RiveWidgetBuilder(
                fileLoader: FileLoader.fromAsset(
                  'assets/rive/coin_drop.riv',
                  riveFactory: Factory.flutter,
                ),
                stateMachineSelector: const StateMachineNamed('State Machine 1'),
                builder: (context, state) {
                  if (state is RiveLoaded) {
                    return RiveWidget(
                      controller: state.controller,
                      fit: Fit.contain,
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            // Big number + subheading + claim button (equal gaps)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: _countFrom, end: _countTo),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Text(
                      _formatIndian(value),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Members earn ₹100 cashback on CRED UPI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeoPopTiltedButton(
                    isFloating: true,
                    onTapUp: () => HapticFeedback.vibrate(),
                    onTapDown: () => HapticFeedback.vibrate(),
                    decoration: const NeoPopTiltedButtonDecoration(
                      color: Colors.white,
                      plunkColor: Color(0xFFB0B0B0),
                      shadowColor: Color(0xFF0E0E0E),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      child: Text(
                        'Claim yours',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoneyMatters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONEY MATTERS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: CredColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMoneyChip(Icons.account_balance_wallet_outlined, 'cash', '\u20B91,00,000', const Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              _buildMoneyChip(Icons.account_balance_outlined, 'bank accounts', 'view balance', null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyChip(IconData icon, String label, String value, Color? valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: CredColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CredColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: CredColors.secondary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CredColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? CredColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForYouSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FOR YOU',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: CredColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildForYouItem(Icons.people_outline, 'pay\ncontacts', null),
              _buildForYouItem(Icons.receipt_long_outlined, 'bills &\nrecharges', 'CLAIM \u20B925'),
              _buildForYouItem(Icons.school_outlined, 'education\nfees', 'INSTANT'),
              _buildForYouItem(Icons.card_giftcard_outlined, 'rewards\n', null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForYouItem(IconData icon, String label, String? badge) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF222226), Color(0xFF131316)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.06),
                    offset: const Offset(-3, -3),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(icon, color: CredColors.primary, size: 26),
            ),
            if (badge != null)
              Positioned(
                bottom: -4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: CredColors.secondary,
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildExploreCred() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXPLORE CRED',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: CredColors.secondary,
                ),
              ),
              Row(
                children: [
                  Text(
                    'view all',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CredColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: CredColors.secondary, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const AnimatedExploreChip(
                  icon: Icons.savings_outlined,
                  label: 'fixed deposit',
                  alternateLabel: 'unlock',
                ),
                const SizedBox(width: 10),
                _buildExploreChip(Icons.favorite_outline, 'refer'),
                const SizedBox(width: 10),
                _buildExploreChip(Icons.shopping_bag_outlined, 'shop'),
                const SizedBox(width: 10),
                _buildExploreChip(Icons.trending_up, 'mutual funds'),
                const SizedBox(width: 10),
                _buildExploreChip(Icons.bolt_outlined, 'electricity'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Second row
          Row(
            children: [
              _buildExploreChipWithBadge(Icons.speed_outlined, 'credit score', '740'),
              const SizedBox(width: 10),
              _buildExploreChip(Icons.directions_car_outlined, 'garage'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: CredColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: CredColors.secondary, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: CredColors.secondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreChipWithBadge(IconData icon, String label, String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: CredColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: CredColors.secondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF141416),
              Color(0xFF141416),
              Color(0xFF0A2333), // Deep blueish bottom as in reference
            ],
          ),
        ),
        child: Row(
          children: [
            // Dispenser (35%)
            const Expanded(
              flex: 30,
              child: RewardLogoDispenser(size: 70),
            ),
            const SizedBox(width: 20),
            // Text + button (65%)
            Expanded(
              flex: 65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '5M+ rewards claimed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'claim yours on CRED payback',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeoPopButton(
                    color: const Color(0xFFF7C343),
                    onTapUp: () => HapticFeedback.vibrate(),
                    onTapDown: () => HapticFeedback.vibrate(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Text(
                        'Claim now',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFluidSection() {
    // Extend to phone bottom — include nav bar + bottom padding
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = kBottomNavigationBarHeight;
    final totalHeight = 420 + navBarHeight + bottomPadding;
    return FluidSimulationWidget(height: totalHeight);
  }

  String _formatIndian(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    String rest = s.substring(0, s.length - 3);
    String formatted = '';
    while (rest.length > 2) {
      formatted = ',${rest.substring(rest.length - 2)}$formatted';
      rest = rest.substring(0, rest.length - 2);
    }
    return '$rest$formatted,$last3';
  }
}

