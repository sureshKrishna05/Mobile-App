import 'package:flutter/material.dart';
import 'dart:math' as math; // Added for rocket rotation logic
import '../theme/app_color.dart';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  int quantity = 1;
  final double unitPrice = 15.99;

  late AnimationController _rocketController;
  late Animation<double> _rocketAnimation;
  bool _isFlying = false;

  @override
  void initState() {
    super.initState();
    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Slightly longer for the curve
    );
    _rocketAnimation = CurvedAnimation(parent: _rocketController, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _rocketController.dispose();
    super.dispose();
  }

  void _updateQty(int delta) {
    setState(() {
      if (quantity + delta >= 1) quantity += delta;
    });
  }

  double get total => quantity * unitPrice;

  void _startCheckout() async {
    setState(() => _isFlying = true);
    await _rocketController.forward();
    
    if (!mounted) return;

    // ONLY CHANGE MADE: Passing 'total' to PaymentPage
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => PaymentPage(amountToPay: total))
    ).then((_) {
      _rocketController.reset();
      setState(() => _isFlying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgRadialEnd,
      body: Stack(
        children: [
          _buildAestheticBackground(),

          SafeArea(
            child: Center( 
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380), 
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: quantity > 0 ? _buildScrollArea() : _buildEmptyState(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CURVED PAPER ROCKET ANIMATION
          if (_isFlying)
            AnimatedBuilder(
              animation: _rocketAnimation,
              builder: (context, child) {
                final size = MediaQuery.of(context).size;
                final t = _rocketAnimation.value;

                // Bezier Curve Logic for a "Rounding" effect
                // Start: Bottom Center | Control: Middle Right | End: Top Center
                double x = (1 - t) * (1 - t) * (size.width / 2) + 
                           2 * (1 - t) * t * (size.width * 0.9) + 
                           t * t * (size.width / 2);
                
                double y = (1 - t) * (1 - t) * (size.height - 120) + 
                           2 * (1 - t) * t * (size.height / 2) + 
                           t * t * (-50);

                return Stack(
                  children: [
                    // Dotted Trail Path
                    ...List.generate(15, (index) {
                      double trailT = t - (index * 0.02);
                      if (trailT < 0) return const SizedBox.shrink();
                      
                      double tx = (1 - trailT) * (1 - trailT) * (size.width / 2) + 2 * (1 - trailT) * trailT * (size.width * 0.9) + trailT * trailT * (size.width / 2);
                      double ty = (1 - trailT) * (1 - trailT) * (size.height - 120) + 2 * (1 - trailT) * trailT * (size.height / 2) + trailT * trailT * (-50);

                      return Positioned(
                        left: tx,
                        top: ty,
                        child: Opacity(
                          opacity: (1 - (index / 15)).clamp(0, 1),
                          child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        ),
                      );
                    }),

                    // The Paper Rocket
                    Positioned(
                      left: x - 20,
                      top: y - 20,
                      child: Transform.rotate(
                        // Rotates based on the arc's progress
                        angle: -math.pi / 4 - (t * 0.5), 
                        child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 45),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Background, Header, ScrollArea, and ItemFrame logic remain identical to your original ---

  Widget _buildAestheticBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(top: -50, left: -60, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.08)))),
            Positioned(bottom: 100, right: -40, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary.withValues(alpha: 0.1)))),
            Positioned(top: 300, right: 40, child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2)))),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 18)),
          const Text("Your Cart", style: TextStyle(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildScrollArea() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [_buildItemFrame(), const SizedBox(height: 20), _buildSummaryFrame(context), const SizedBox(height: 30)]),
    );
  }

  Widget _buildItemFrame() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5))),
          child: Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network('https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=120', height: 60, width: 60, fit: BoxFit.cover)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Pepperoni Pizza", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("\$${unitPrice.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
              ])),
              _buildCounter(),
            ],
          ),
        ),
        GestureDetector(onTap: () => setState(() => quantity = 0), child: const Padding(padding: EdgeInsets.only(top: 8, right: 6), child: Text("Clear Cart", style: TextStyle(color: AppColors.textLight, fontSize: 12, decoration: TextDecoration.underline)))),
      ],
    );
  }

  Widget _buildCounter() {
    return Container(decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [_counterAction(Icons.remove, () => _updateQty(-1)), Text("$quantity", style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14)), _counterAction(Icons.add, () => _updateQty(1))]));
  }

  Widget _counterAction(IconData icon, VoidCallback action) {
    return InkWell(onTap: action, child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 16, color: AppColors.textDark)));
  }

  Widget _buildSummaryFrame(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Summary", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 16),
          _summaryRow("Subtotal", "\$${total.toStringAsFixed(2)}"),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 0.5)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Total", style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w900)),
            Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isFlying ? null : _startCheckout,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_isFlying ? "Sending..." : "Proceed to Checkout", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, color: Colors.white, size: 16)]),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 14)), Text(value, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14))]);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://img.freepik.com/free-vector/empty-shopping-cart-concept-illustration_114360-16091.jpg', height: 180, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.secondary)),
            const SizedBox(height: 16),
            const Text("Your cart is empty", style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("“Good food is the foundation of genuine happiness.”", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight, fontSize: 14, fontStyle: FontStyle.italic)),
            const SizedBox(height: 32),
            TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 18), label: const Text("Go Back Shopping", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}