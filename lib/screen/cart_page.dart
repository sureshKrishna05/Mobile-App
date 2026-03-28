import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_color.dart';
import 'payment_page.dart';

// ✅ FIX 1: CartItem model to hold real item data passed from Dashboard
class CartItem {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}

class CartPage extends StatefulWidget {
  // ✅ FIX 2: Receives real cart data from DashboardPage
  final Map<int, int> cartQuantities;          // foodId → qty
  final List<Map<String, dynamic>> allFoods;  // full food list to look up names/prices

  const CartPage({
    super.key,
    required this.cartQuantities,
    required this.allFoods,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  // ✅ FIX 3: Build real CartItems from passed-in data
  late List<CartItem> _cartItems;

  late AnimationController _rocketController;
  late Animation<double> _rocketAnimation;
  bool _isFlying = false;

  @override
  void initState() {
    super.initState();
    _buildCartItems();

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rocketAnimation = CurvedAnimation(
        parent: _rocketController, curve: Curves.easeInOutCubic);
  }

  void _buildCartItems() {
    _cartItems = widget.cartQuantities.entries
        .map((entry) {
          final food = widget.allFoods.firstWhere(
            (f) => f['id'] == entry.key,
            orElse: () => {},
          );
          if (food.isEmpty) return null;
          return CartItem(
            id: entry.key,
            name: food['name'] as String,
            price: double.tryParse(food['price'].toString()) ?? 0.0,
            imageUrl: food['img'] as String? ?? '',
            quantity: entry.value,
          );
        })
        .whereType<CartItem>()
        .toList();
  }

  @override
  void dispose() {
    _rocketController.dispose();
    super.dispose();
  }

  void _updateQty(CartItem item, int delta) {
    setState(() {
      final newQty = item.quantity + delta;
      if (newQty < 1) {
        _cartItems.remove(item);
      } else {
        item.quantity = newQty;
      }
    });
  }

  double get total =>
      _cartItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  void _startCheckout() async {
    setState(() => _isFlying = true);
    await _rocketController.forward();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          amountToPay: total,
          // ✅ FIX 4: Pass cart items forward to payment for order creation
          cartItems: _cartItems,
        ),
      ),
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
                      child: _cartItems.isEmpty
                          ? _buildEmptyState()
                          : _buildScrollArea(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isFlying) _buildRocketAnimation(),
        ],
      ),
    );
  }

  Widget _buildRocketAnimation() {
    return AnimatedBuilder(
      animation: _rocketAnimation,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final t = _rocketAnimation.value;
        double x = (1 - t) * (1 - t) * (size.width / 2) +
            2 * (1 - t) * t * (size.width * 0.9) +
            t * t * (size.width / 2);
        double y = (1 - t) * (1 - t) * (size.height - 120) +
            2 * (1 - t) * t * (size.height / 2) +
            t * t * (-50);

        return Stack(
          children: [
            ...List.generate(15, (index) {
              double trailT = t - (index * 0.02);
              if (trailT < 0) return const SizedBox.shrink();
              double tx = (1 - trailT) * (1 - trailT) * (size.width / 2) +
                  2 * (1 - trailT) * trailT * (size.width * 0.9) +
                  trailT * trailT * (size.width / 2);
              double ty = (1 - trailT) * (1 - trailT) * (size.height - 120) +
                  2 * (1 - trailT) * trailT * (size.height / 2) +
                  trailT * trailT * (-50);
              return Positioned(
                left: tx,
                top: ty,
                child: Opacity(
                  opacity: (1 - (index / 15)).clamp(0, 1),
                  child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle)),
                ),
              );
            }),
            Positioned(
              left: x - 20,
              top: y - 20,
              child: Transform.rotate(
                angle: -math.pi / 4 - (t * 0.5),
                child: const Icon(Icons.send_rounded,
                    color: AppColors.primary, size: 45),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAestheticBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
                top: -50,
                left: -60,
                child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.08)))),
            Positioned(
                bottom: 100,
                right: -40,
                child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withValues(alpha: 0.1)))),
            Positioned(
                top: 300,
                right: 40,
                child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                AppColors.primary.withValues(alpha: 0.1),
                            width: 2)))),
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
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textDark, size: 18)),
          const Text("Your Cart",
              style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          const Spacer(),
          // ✅ FIX 5: Show live item count
          Text(
            "${_cartItems.fold(0, (s, i) => s + i.quantity)} items",
            style: const TextStyle(
                color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollArea() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        // ✅ FIX 6: Render ALL real cart items, not just one hardcoded one
        ..._cartItems.map((item) => _buildItemFrame(item)),
        const SizedBox(height: 20),
        _buildSummaryFrame(context),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _buildItemFrame(CartItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.imageUrl,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 60,
                    width: 60,
                    color: AppColors.secondary,
                    child: const Icon(Icons.fastfood,
                        color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("₹${item.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
              _buildCounter(item),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _cartItems.remove(item)),
          child: const Padding(
            padding: EdgeInsets.only(bottom: 4, right: 6),
            child: Text("Remove",
                style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    decoration: TextDecoration.underline)),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(CartItem item) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _counterAction(Icons.remove, () => _updateQty(item, -1)),
        Text("${item.quantity}",
            style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        _counterAction(Icons.add, () => _updateQty(item, 1)),
      ]),
    );
  }

  Widget _counterAction(IconData icon, VoidCallback action) {
    return InkWell(
        onTap: action,
        child: Padding(
            padding: const EdgeInsets.all(6),
            child:
                Icon(icon, size: 16, color: AppColors.textDark)));
  }

  Widget _buildSummaryFrame(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Summary",
              style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
          const SizedBox(height: 16),
          _summaryRow("Subtotal", "₹${total.toStringAsFixed(0)}"),
          _summaryRow("GST (5%)",
              "₹${(total * 0.05).toStringAsFixed(0)}"),
          _summaryRow("Delivery", "FREE"),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
              Text(
                  "₹${(total * 1.05).toStringAsFixed(0)}",
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                (_isFlying || _cartItems.isEmpty) ? null : _startCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    _isFlying
                        ? "Sending..."
                        : "Proceed to Checkout",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 80, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text("Your cart is empty",
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "\"Good food is the foundation of genuine happiness.\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back,
                  color: AppColors.primary, size: 18),
              label: const Text("Go Back Shopping",
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}