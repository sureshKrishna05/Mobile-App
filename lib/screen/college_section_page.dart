import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/dashboard_page.dart';

class CollegeSelectionPage extends StatefulWidget {
  const CollegeSelectionPage({super.key});

  @override
  State<CollegeSelectionPage> createState() => _CollegeSelectionPageState();
}

class _CollegeSelectionPageState extends State<CollegeSelectionPage>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────
  late final AnimationController _bgOrb1Controller;
  late final AnimationController _bgOrb2Controller;
  late final AnimationController _headerController;
  late final AnimationController _gridController;
  late final AnimationController _shimmerController;

  // ── Animations ───────────────────────────────────────────────
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  final List<Map<String, String>> colleges = [
    {
      "name": "Engineering Campus",
      "image":
          "https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=500&q=80",
      "location": "North Block",
      "tag": "STEM",
      "color": "0xFFFF5722",
    },
    {
      "name": "Medical College",
      "image":
          "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=500&q=80",
      "location": "West Wing",
      "tag": "Health",
      "color": "0xFFE91E63",
    },
    {
      "name": "Arts & Science",
      "image":
          "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=500&q=80",
      "location": "Central Hub",
      "tag": "Liberal",
      "color": "0xFF9C27B0",
    },
    {
      "name": "Business School",
      "image":
          "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=500&q=80",
      "location": "South Campus",
      "tag": "MBA",
      "color": "0xFF2196F3",
    },
  ];

  @override
  void initState() {
    super.initState();

    // Floating orb animations (infinite looping)
    _bgOrb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _bgOrb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Header entrance
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    // Grid stagger
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Sequence: header first, then grid
    _headerController.forward().then((_) => _gridController.forward());
  }

  @override
  void dispose() {
    _bgOrb1Controller.dispose();
    _bgOrb2Controller.dispose();
    _headerController.dispose();
    _gridController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Base Gradient Background ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF8F2),
                  Color(0xFFFDF5EE),
                  Color(0xFFFFF0E6),
                ],
              ),
            ),
          ),

          // ── Animated Floating Orbs ────────────────────────────
          _FloatingOrb(
            controller: _bgOrb1Controller,
            color: AppColors.primary.withValues(alpha: 0.12),
            size: 300,
            alignment: const Alignment(-1.1, -0.8),
            translateY: 30,
          ),
          _FloatingOrb(
            controller: _bgOrb2Controller,
            color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
            size: 220,
            alignment: const Alignment(1.2, 0.5),
            translateY: -25,
          ),
          _FloatingOrb(
            controller: _bgOrb1Controller,
            color: AppColors.primary.withValues(alpha: 0.07),
            size: 160,
            alignment: const Alignment(0.0, 1.3),
            translateY: 20,
          ),

          // ── Dot Grid Texture ─────────────────────────────────
          const _DotGridPainter(),

          // ── Content ───────────────────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktop = constraints.maxWidth > 800;
                final bool isTablet =
                    constraints.maxWidth >= 600 && constraints.maxWidth <= 800;
                final double hPad =
                    isDesktop ? constraints.maxWidth * 0.1 : (isTablet ? 40 : 22);
                final double titleSize =
                    (constraints.maxWidth * 0.075).clamp(26.0, 42.0);

                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // ── Animated Header ───────────────────────
                      SlideTransition(
                        position: _headerSlide,
                        child: FadeTransition(
                          opacity: _headerFade,
                          child: _buildHeader(titleSize),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Animated Grid ─────────────────────────
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                          ),
                          itemCount: colleges.length,
                          itemBuilder: (context, index) {
                            return _StaggeredCardEntrance(
                              index: index,
                              controller: _gridController,
                              child: _PremiumCollegeCard(
                                data: colleges[index],
                                shimmerController: _shimmerController,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double titleSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pill badge
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "SMART CANTEEN",
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Title with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2D2D2D), Color(0xFF6B3A2A)],
          ).createShader(bounds),
          child: Text(
            "Select\nYour Campus",
            style: GoogleFonts.playfairDisplay(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: Colors.white, // masked by shader
              height: 1.1,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(Icons.restaurant_rounded,
                size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              "Where are you ordering from today?",
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Staggered entrance wrapper
// ─────────────────────────────────────────────────────────────────
class _StaggeredCardEntrance extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _StaggeredCardEntrance({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double start = (index * 0.15).clamp(0.0, 0.7);
    final double end = (start + 0.5).clamp(0.0, 1.0);

    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Premium College Card
// ─────────────────────────────────────────────────────────────────
class _PremiumCollegeCard extends StatefulWidget {
  final Map<String, String> data;
  final AnimationController shimmerController;

  const _PremiumCollegeCard({
    required this.data,
    required this.shimmerController,
  });

  @override
  State<_PremiumCollegeCard> createState() => _PremiumCollegeCardState();
}

class _PremiumCollegeCardState extends State<_PremiumCollegeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Color get _accentColor =>
      Color(int.parse(widget.data['color']!));

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => const DashboardPage(),
              transitionsBuilder: (_, anim, __, child) {
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        onTapCancel: () => _pressController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: _hovered ? 0.22 : 0.08),
                  blurRadius: _hovered ? 28 : 16,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image Section ──────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Network image
                        Image.network(
                          widget.data['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey, size: 32),
                            ),
                          ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return _ShimmerBox(
                                controller: widget.shimmerController);
                          },
                        ),

                        // Gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  _accentColor.withValues(alpha: 0.55),
                                ],
                                stops: const [0.45, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Tag badge (top-right)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _GlassBadge(
                            label: widget.data['tag']!,
                            color: _accentColor,
                          ),
                        ),

                        // Location chip (bottom-left)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                widget.data['location']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Info Section ───────────────────────────────
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.data['name']!,
                            style: GoogleFonts.playfairDisplay(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textDark,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // CTA row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order here",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: _accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: _hovered
                                      ? _accentColor
                                      : _accentColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: _hovered
                                      ? Colors.white
                                      : _accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Glassmorphism Badge
// ─────────────────────────────────────────────────────────────────
class _GlassBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _GlassBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Shimmer Loading Placeholder
// ─────────────────────────────────────────────────────────────────
class _ShimmerBox extends StatelessWidget {
  final AnimationController controller;

  const _ShimmerBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: [
                (controller.value - 0.3).clamp(0.0, 1.0),
                controller.value.clamp(0.0, 1.0),
                (controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Floating Orb
// ─────────────────────────────────────────────────────────────────
class _FloatingOrb extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double size;
  final Alignment alignment;
  final double translateY;

  const _FloatingOrb({
    required this.controller,
    required this.color,
    required this.size,
    required this.alignment,
    required this.translateY,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final dy = translateY * math.sin(controller.value * math.pi);
        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Subtle Dot Grid Background Texture
// ─────────────────────────────────────────────────────────────────
class _DotGridPainter extends StatelessWidget {
  const _DotGridPainter();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _DotGridCustomPainter()),
    );
  }
}

class _DotGridCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const radius = 1.6;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}