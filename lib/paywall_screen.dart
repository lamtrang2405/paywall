import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ──────────────────────────────────────────────
// Design tokens
// ──────────────────────────────────────────────
class _Palette {
  static const Color bg = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF18181C);
  static const Color accent = Color(0xFFE84393);
  static const Color accentAlt = Color(0xFFA855F7);
  static const Color accentGold = Color(0xFFFBBF24);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFF2D2D33);
}

// ──────────────────────────────────────────────
// Paywall Screen
// ──────────────────────────────────────────────
class PaywallScreen extends StatefulWidget {
  final String yearlyPrice;
  final String yearlyPerWeek;
  final String weeklyPrice;
  final String yearlySavings;

  const PaywallScreen({
    super.key,
    this.yearlyPrice = r'$49.99',
    this.yearlyPerWeek = r'$0.96/week',
    this.weeklyPrice = r'$6.99',
    this.yearlySavings = 'Save 86%',
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  int _selectedPlan = 1; // 0 = weekly, 1 = yearly
  bool _showAllOptions = true;

  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  late final AnimationController _shakeController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Periodic shake: wait 3s, shake for 1.5s, repeat
    _startShakeCycle();

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -12.0, end: 10.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 6.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  void _startShakeCycle() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _shakeController.forward(from: 0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var path in _HeroArtGridState._images) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 700;
    final horizontalPadding = size.width * 0.06;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: _Palette.bg,
      body: Stack(
        children: [
          // ── Background gradient orbs ──
          _AnimatedOrbBackground(animation: _pulseAnimation),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.01),
                        // Hero art grid
                        _HeroArtGrid(
                          shimmerController: _shimmerController,
                          height: size.height * (isShort ? 0.3 : 0.28),
                        ),
                        SizedBox(height: size.height * 0.035),
                        // Headline
                        _buildHeadline(size.width),
                        const SizedBox(height: 12),
                        _buildSubheadline(size.width),
                        const SizedBox(height: 12),
                        // Feature pills
                        _buildFeaturePills(),
                        SizedBox(height: size.height * 0.03),
                        // Plan cards
                        if (_showAllOptions) ...[
                          _PlanCard(
                            isSelected: _selectedPlan == 1,
                            label: 'YEARLY',
                            price: widget.yearlyPrice,
                            perWeek: widget.yearlyPerWeek,
                            badge: 'BEST VALUE',
                            savings: widget.yearlySavings,
                            onTap: () => setState(() => _selectedPlan = 1),
                          ),
                          const SizedBox(height: 12),
                          _PlanCard(
                            isSelected: _selectedPlan == 0,
                            label: 'WEEKLY',
                            price: widget.weeklyPrice,
                            perWeek: widget.weeklyPrice,
                            onTap: () => setState(() => _selectedPlan = 0),
                          ),
                        ] else ...[
                          _PlanCard(
                            isSelected: true,
                            label: 'YEARLY',
                            price: widget.yearlyPrice,
                            perWeek: widget.yearlyPerWeek,
                            badge: 'BEST VALUE',
                            savings: widget.yearlySavings,
                            onTap: () {},
                          ),
                        ],
                        SizedBox(height: size.height * 0.025),
                        // CTA
                        _CtaButton(
                          shimmerController: _shimmerController,
                          shakeAnimation: _shakeAnimation,
                        ),
                        SizedBox(height: size.height * 0.035),
                        // New Footer
                        _buildUnifiedFooter(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ──
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _Palette.surface.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: _Palette.textSecondary,
                size: 20,
              ),
            ),
          ),
          // Restore
          GestureDetector(
            onTap: () {},
            child: Text(
              'Restore',
              style: TextStyle(
                color: _Palette.textSecondary.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Headline ──
  Widget _buildHeadline(double screenWidth) {
    // Dynamic font size from 24 to 32
    final double fontSize = (screenWidth * 0.075).clamp(24.0, 32.0);
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [_Palette.accent, _Palette.accentAlt],
      ).createShader(bounds),
      child: Text(
        'UNLOCK YOUR\nDEEPEST DESIRES',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.15,
          letterSpacing: 1.5,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Subheadline ──
  Widget _buildSubheadline(double screenWidth) {
    final double fontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    return Text(
      'Unlimited intimate audio stories & ASMR experiences',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: _Palette.textSecondary.withOpacity(0.85),
        height: 1.5,
      ),
    );
  }

  // ── Feature pills ──
  Widget _buildFeaturePills() {
    final features = ['🎧 500+ Stories', '🔥 New Daily', '📥 Offline'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: features
          .map(
            (f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _Palette.surface.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _Palette.accent.withOpacity(0.25)),
              ),
              child: Text(
                f,
                style: const TextStyle(
                  color: _Palette.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ── New Unified Footer ──
  Widget _buildUnifiedFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _footerLink('Terms of Use', 'https://lucidfm.com/'),
        _footerDivider(),
        _footerLink('Privacy Policy', 'https://lucidfm.com/'),
      ],
    );
  }

  Widget _footerLink(String text, String url) {
    return GestureDetector(
      onTap: () => _launchLegalUrl(url),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: _Palette.textSecondary.withOpacity(0.8),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _launchLegalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _footerDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '|',
        style: TextStyle(
          color: _Palette.textSecondary.withOpacity(0.3),
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Animated orb background
// ──────────────────────────────────────────────
class _AnimatedOrbBackground extends StatelessWidget {
  final Animation<double> animation;
  const _AnimatedOrbBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value;
        return Stack(
          children: [
            Positioned(
              top: -60 + (v * 20),
              right: -40,
              child: _orb(220, _Palette.accent.withOpacity(0.12)),
            ),
            Positioned(
              top: 120,
              left: -80 + (v * 15),
              child: _orb(180, _Palette.accentAlt.withOpacity(0.10)),
            ),
            Positioned(
              bottom: 100,
              right: -50,
              child: _orb(160, _Palette.accent.withOpacity(0.08)),
            ),
          ],
        );
      },
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Hero art grid — mosaic of real images with Ken Burns
// ──────────────────────────────────────────────
class _HeroArtGrid extends StatefulWidget {
  final AnimationController shimmerController;
  final double height;
  const _HeroArtGrid({required this.shimmerController, required this.height});

  @override
  State<_HeroArtGrid> createState() => _HeroArtGridState();
}

class _HeroArtGridState extends State<_HeroArtGrid>
    with TickerProviderStateMixin {
  static const _images = [
    'assets/images/art_1.jpg',
    'assets/images/art_2.jpg',
    'assets/images/art_3.jpg',
    'assets/images/art_4.jpg',
    'assets/images/art_5.jpg',
  ];

  late final List<AnimationController> _kenBurnsControllers;
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    // Each tile gets its own slow Ken Burns animation, staggered
    // Floating animation for tags
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnimation = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );

    _kenBurnsControllers = List.generate(5, (i) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 6000 + (i * 800)),
      );
      // Stagger start
      Future.delayed(Duration(milliseconds: i * 600), () {
        if (mounted) controller.repeat(reverse: true);
      });
      return controller;
    });
  }

  @override
  void dispose() {
    for (final c in _kenBurnsControllers) {
      c.dispose();
    }
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double gridHeight = widget.height;
    // Scale tags based on height
    final double tagScale = (gridHeight / 260.0).clamp(0.8, 1.2);

    return SizedBox(
      height: gridHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Row(
              children: [
                // Left large tile
                Expanded(flex: 3, child: _imageTile(0, Alignment.center, 1.15)),
                const SizedBox(width: 4),
                // Middle column — 2 tiles
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: _imageTile(1, Alignment.topCenter, 1.12)),
                      const SizedBox(height: 4),
                      Expanded(child: _imageTile(2, Alignment.center, 1.18)),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Right column — 2 tiles
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: _imageTile(3, Alignment.centerLeft, 1.14),
                      ),
                      const SizedBox(height: 4),
                      Expanded(child: _imageTile(4, Alignment.topCenter, 1.16)),
                    ],
                  ),
                ),
              ],
            ),
            // Bottom gradient fade to bg
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, _Palette.bg],
                    ),
                  ),
                ),
              ),
            ),
            // Top subtle vignette
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 40,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _Palette.bg.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── FLOATING TAGS ──
            Positioned(
              top: gridHeight * 0.1,
              left: 20,
              child: _floatingTag(
                'Romance',
                isGradient: true,
                scale: 0.85 * tagScale,
              ),
            ),
            Positioned(
              top: gridHeight * 0.17,
              right: 25,
              child: _floatingTag(
                'Fantasy',
                isGradient: false,
                scale: 0.8 * tagScale,
              ),
            ),
            Positioned(
              top: gridHeight * 0.38,
              left: 130,
              child: _floatingTag(
                '🔥 M4F',
                isGradient: true,
                scale: 1.0 * tagScale,
              ),
            ),
            Positioned(
              bottom: gridHeight * 0.42,
              left: 35,
              child: _floatingTag(
                'Praise',
                isGradient: false,
                scale: 0.9 * tagScale,
              ),
            ),
            Positioned(
              bottom: gridHeight * 0.28,
              right: 35,
              child: _floatingTag(
                'F4M',
                isGradient: false,
                scale: 0.9 * tagScale,
              ),
            ),
            Positioned(
              bottom: gridHeight * 0.15,
              left: 150,
              child: _floatingTag(
                'Comfort',
                isGradient: false,
                scale: 0.8 * tagScale,
              ),
            ),
            Positioned(
              top: gridHeight * 0.28,
              left: 80,
              child: _floatingTag(
                'Gentle',
                isGradient: false,
                scale: 0.75 * tagScale,
              ),
            ),
            Positioned(
              bottom: gridHeight * 0.48,
              right: 15,
              child: _floatingTag(
                'Roleplay',
                isGradient: false,
                scale: 0.75 * tagScale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _floatingTag(
    String text, {
    required bool isGradient,
    double scale = 1.0,
  }) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        final offset = math.sin(_floatAnimation.value * math.pi) * 8;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isGradient
                    ? const LinearGradient(
                        colors: [_Palette.accent, _Palette.accentAlt],
                      )
                    : null,
                color: isGradient ? null : Colors.black.withOpacity(0.55),
                border: Border.all(
                  color: Colors.white.withOpacity(isGradient ? 0.35 : 0.15),
                  width: 1,
                ),
                boxShadow: [
                  if (isGradient)
                    BoxShadow(
                      color: _Palette.accent.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _imageTile(int index, Alignment alignment, double maxScale) {
    final controller = _kenBurnsControllers[index];
    // Alternate zoom direction for visual variety
    final beginScale = index.isEven ? 1.0 : 1.05;
    final endScale = maxScale;
    // Subtle pan offsets
    final panOffsets = [
      const Offset(0, -8),
      const Offset(5, 0),
      const Offset(-4, 6),
      const Offset(6, -5),
      const Offset(-3, 4),
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(controller.value);
        final scale = beginScale + (endScale - beginScale) * t;
        final pan = panOffsets[index] * t;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with Ken Burns transform
              Transform(
                alignment: alignment,
                transform: Matrix4.identity()
                  ..translate(pan.dx, pan.dy)
                  ..scale(scale),
                child: Image.asset(
                  _images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    // Fallback gradient if image missing
                    final gradients = [
                      [const Color(0xFF6D28D9), const Color(0xFFDB2777)],
                      [const Color(0xFFBE185D), const Color(0xFFF97316)],
                      [const Color(0xFF1E3A5F), const Color(0xFF7C3AED)],
                      [const Color(0xFFEC4899), const Color(0xFF8B5CF6)],
                      [const Color(0xFF0EA5E9), const Color(0xFFA855F7)],
                    ];
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradients[index % gradients.length],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_rounded,
                          color: Colors.white.withOpacity(0.3),
                          size: index == 0 ? 42 : 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // ── VFX OVERLAY ──
              _VfxOverlay(animation: controller),

              // Subtle dark gradient for better text legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// Plan card
// ──────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final bool isSelected;
  final String label;
  final String price;
  final String perWeek;
  final String? badge;
  final String? savings;
  final VoidCallback onTap;

  const _PlanCard({
    required this.isSelected,
    required this.label,
    required this.price,
    required this.perWeek,
    this.badge,
    this.savings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? _Palette.accent.withOpacity(0.08)
              : _Palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _Palette.accent : _Palette.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            _RadioDot(isSelected: isSelected),
            const SizedBox(width: 16),
            // Label + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? _Palette.textPrimary
                              : _Palette.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_Palette.accent, _Palette.accentAlt],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'billed $price',
                    style: TextStyle(
                      color: _Palette.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Per week + savings
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (savings != null)
                  Text(
                    savings!,
                    style: const TextStyle(
                      color: _Palette.accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  perWeek,
                  style: TextStyle(
                    color: isSelected
                        ? _Palette.textPrimary
                        : _Palette.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Custom radio dot
// ──────────────────────────────────────────────
class _RadioDot extends StatelessWidget {
  final bool isSelected;
  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? _Palette.accent : _Palette.border,
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 12 : 0,
          height: isSelected ? 12 : 0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_Palette.accent, _Palette.accentAlt],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CTA Button with shimmer
// ──────────────────────────────────────────────
class _CtaButton extends StatelessWidget {
  final AnimationController shimmerController;
  final Animation<double> shakeAnimation;
  const _CtaButton({
    required this.shimmerController,
    required this.shakeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([shimmerController, shakeAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(shakeAnimation.value, 0),
          child: GestureDetector(
            onTap: () {
              // Handle purchase
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    _Palette.accent,
                    Color(0xFFBE185D),
                    _Palette.accentAlt,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _Palette.accent.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Web-safe Shimmer Overlay (No ShaderMask)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: shimmerController,
                      builder: (context, _) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment(
                                -3.0 + (shimmerController.value * 6.0),
                                -1.0,
                              ),
                              end: Alignment(
                                -1.0 + (shimmerController.value * 6.0),
                                1.0,
                              ),
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.18),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const [0.3, 0.5, 0.7],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Label
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Start Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.translate(
                          offset: Offset(
                            2.0 *
                                math.sin(shimmerController.value * math.pi * 2),
                            0,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
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
      },
    );
  }
}

// ──────────────────────────────────────────────
// Cinematic VFX Overlay
// ──────────────────────────────────────────────
class _VfxOverlay extends StatelessWidget {
  final Animation<double> animation;
  const _VfxOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value;
        return Stack(
          children: [
            // Procedural Grain Layer
            Positioned.fill(
              child: CustomPaint(painter: _GrainPainter(seed: v)),
            ),
            // Chromatic Aberration Pulse (Cyan/Magenta offsets)
            if (v > 0.85 || v < 0.15) ...[
              Positioned.fill(
                left: 1.5,
                child: Container(
                  color: const Color(0xFF00FFFF).withOpacity(0.04),
                ),
              ),
              Positioned.fill(
                right: 1.5,
                child: Container(
                  color: const Color(0xFFFF00FF).withOpacity(0.04),
                ),
              ),
            ],
            // Light Leak
            Positioned(
              left: -100 + (v * 200),
              top: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.accent.withOpacity(0.08 * v),
                      _Palette.accentAlt.withOpacity(0.02 * (1 - v)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// Procedural Grain Painter
// ──────────────────────────────────────────────
class _GrainPainter extends CustomPainter {
  final double seed;
  _GrainPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03);
    final random = math.Random((seed * 1000).toInt());

    // Draw 1000 tiny dots for grain
    for (int i = 0; i < 1500; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => oldDelegate.seed != seed;
}
