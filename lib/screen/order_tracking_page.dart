import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartcanteen/theme/app_color.dart';

// ─────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────
class OrderItem {
  final String name;
  final int quantity;
  final double priceAtTime;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.priceAtTime,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: (map['menu_items']?['name'] as String?) ?? 'Item',
      quantity: (map['quantity'] as int?) ?? 1,
      priceAtTime: double.tryParse(map['price_at_time'].toString()) ?? 0.0,
    );
  }
}

class TrackedOrder {
  final String id;
  final String status;
  final double totalAmount;
  final String createdAt;
  final String canteenName;
  final List<OrderItem> items;

  const TrackedOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.canteenName,
    required this.items,
  });
}

// ─────────────────────────────────────────────────────────────────
// Status helpers
// ─────────────────────────────────────────────────────────────────
const _statusOrder = [
  'paid',
  'accepted',
  'preparing',
  'ready',
  'completed',
];

int _statusIndex(String status) => _statusOrder.indexOf(status);

String _statusLabel(String status) {
  switch (status) {
    case 'paid':      return 'Order Placed';
    case 'accepted':  return 'Order Accepted';
    case 'preparing': return 'Being Prepared';
    case 'ready':     return 'Ready for Pickup';
    case 'completed': return 'Collected ✓';
    case 'cancelled': return 'Cancelled';
    default:          return 'Processing';
  }
}

String _statusSubtitle(String status) {
  switch (status) {
    case 'paid':      return 'Waiting for canteen to accept your order';
    case 'accepted':  return 'The canteen has confirmed your order';
    case 'preparing': return 'Your food is being freshly prepared';
    case 'ready':     return 'Come pick up your order at the counter!';
    case 'completed': return 'Thank you! Enjoy your meal 😊';
    case 'cancelled': return 'Your order was cancelled';
    default:          return '';
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'paid':      return const Color(0xFFFF9800);
    case 'accepted':  return const Color(0xFF2196F3);
    case 'preparing': return const Color(0xFFFF5722);
    case 'ready':     return const Color(0xFF4CAF50);
    case 'completed': return const Color(0xFF4CAF50);
    case 'cancelled': return Colors.red;
    default:          return Colors.grey;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'paid':      return Icons.receipt_long_rounded;
    case 'accepted':  return Icons.check_circle_outline_rounded;
    case 'preparing': return Icons.soup_kitchen_rounded;
    case 'ready':     return Icons.storefront_rounded;
    case 'completed': return Icons.done_all_rounded;
    case 'cancelled': return Icons.cancel_outlined;
    default:          return Icons.hourglass_empty_rounded;
  }
}

// ─────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────
class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with TickerProviderStateMixin {
  TrackedOrder? _order;
  bool _isLoading = true;
  String? _error;

  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _orbController;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _pulse;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _orbController = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);

    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.0, 0.5,
                    curve: Curves.easeOutCubic)));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryController,
                curve:
                    const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fetchOrder();
    _subscribeToOrder();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _orbController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrder() async {
    try {
      final data = await Supabase.instance.client
          .from('orders')
          .select('''
            id, status, total_amount, created_at,
            canteens ( name ),
            order_items (
              quantity, price_at_time,
              menu_items ( name )
            )
          ''')
          .eq('id', widget.orderId)
          .single();

      final items = (data['order_items'] as List)
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList();

      final order = TrackedOrder(
        id: data['id'] as String,
        status: data['status'] as String,
        totalAmount:
            double.tryParse(data['total_amount'].toString()) ?? 0.0,
        createdAt: data['created_at'] as String,
        canteenName:
            (data['canteens']?['name'] as String?) ?? 'Canteen',
        items: items,
      );

      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
        _entryController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load order. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _subscribeToOrder() {
    _subscription = Supabase.instance.client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', widget.orderId)
        .listen((data) {
          if (data.isNotEmpty && mounted) {
            final newStatus = data.first['status'] as String;
            if (_order != null && newStatus != _order!.status) {
              setState(() {
                _order = TrackedOrder(
                  id: _order!.id,
                  status: newStatus,
                  totalAmount: _order!.totalAmount,
                  createdAt: _order!.createdAt,
                  canteenName: _order!.canteenName,
                  items: _order!.items,
                );
              });
            }
          }
        });
  }

  String _formatTime(String ts) {
    final dt = DateTime.tryParse(ts)?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatOrderId(String id) =>
      'SC-${id.substring(0, 8).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: Stack(children: [
        _buildBackground(),
        SafeArea(
          child: _isLoading
              ? _buildLoading()
              : _error != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ]),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8F2),
              Color(0xFFFEF0E6),
              Color(0xFFFDF5ED)
            ],
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _orbController,
        builder: (_, _) {
          return Align(
            alignment: const Alignment(1.3, -0.9),
            child: Transform.translate(
              offset: Offset(0,
                  25 * (_orbController.value * 2 - 1).clamp(-1.0, 1.0)),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.09)),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _orbController,
        builder: (_, _) {
          return Align(
            alignment: const Alignment(-1.2, 0.7),
            child: Transform.translate(
              offset: Offset(0,
                  -20 * (_orbController.value * 2 - 1).clamp(-1.0, 1.0)),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFB74D).withValues(alpha: 0.12)),
              ),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline_rounded,
              size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(_error!,
              style: GoogleFonts.poppins(
                  color: AppColors.textDark, fontSize: 15),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() { _isLoading = true; _error = null; });
              _fetchOrder();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
          ),
        ]),
      ),
    );
  }

  Widget _buildContent() {
    final order = _order!;
    final isCancelled = order.status == 'cancelled';
    final isCompleted = order.status == 'completed';
    final isDone = isCancelled || isCompleted;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header ──────────────────────────────────────────────
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: _buildHeader(order),
            ),
          ),
          const SizedBox(height: 28),

          // ── Live Status Badge ────────────────────────────────────
          FadeTransition(
            opacity: _cardFade,
            child: SlideTransition(
              position: _cardSlide,
              child: _buildStatusHero(order, isDone),
            ),
          ),
          const SizedBox(height: 24),

          // ── Stepper ─────────────────────────────────────────────
          if (!isCancelled) ...[
            FadeTransition(
              opacity: _cardFade,
              child: _buildStepper(order),
            ),
            const SizedBox(height: 24),
          ],

          // ── Order Items ─────────────────────────────────────────
          FadeTransition(
            opacity: _cardFade,
            child: _buildItemsCard(order),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _buildHeader(TrackedOrder order) {
    return Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Track Order',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          Text(_formatOrderId(order.id),
              style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: AppColors.textLight,
                  letterSpacing: 1)),
        ]),
      ),
      // Live indicator
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => Transform.scale(
              scale: _pulse.value,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text('LIVE',
              style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.5)),
        ]),
      ),
    ]);
  }

  Widget _buildStatusHero(TrackedOrder order, bool isDone) {
    final color = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(children: [
        // Animated icon
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) => Transform.scale(
            scale: isDone ? 1.0 : _pulse.value,
            child: child,
          ),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(
                  color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(_statusIcon(order.status),
                size: 36, color: color),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _statusLabel(order.status),
          style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _statusSubtitle(order.status),
          style: GoogleFonts.poppins(
              fontSize: 13, color: AppColors.textLight, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.storefront_rounded,
                size: 14, color: Color(0xFFFF9800)),
            const SizedBox(width: 6),
            Text(order.canteenName,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFE65100),
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            const Icon(Icons.access_time_rounded,
                size: 14, color: Color(0xFFFF9800)),
            const SizedBox(width: 4),
            Text(_formatTime(order.createdAt),
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFE65100),
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStepper(TrackedOrder order) {
    final steps = ['paid', 'accepted', 'preparing', 'ready', 'completed'];
    final currentIdx = _statusIndex(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Progress',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isPast = i < currentIdx;
            final isCurrent = i == currentIdx;
            final isFuture = i > currentIdx;

            final color = isFuture
                ? Colors.grey.shade300
                : isCurrent
                    ? _statusColor(step)
                    : const Color(0xFF4CAF50);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dot + line column
                SizedBox(
                  width: 32,
                  child: Column(children: [
                    // Dot
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: isCurrent ? 28 : 22,
                      height: isCurrent ? 28 : 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2)
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isPast
                            ? const Icon(Icons.check_rounded,
                                size: 13, color: Colors.white)
                            : isCurrent
                                ? AnimatedBuilder(
                                    animation: _pulse,
                                    builder: (_, _) => Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                    ),
                                  )
                                : Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        shape: BoxShape.circle),
                                  ),
                      ),
                    ),
                    // Line
                    if (i < steps.length - 1)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 2,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isPast
                                ? [
                                    const Color(0xFF4CAF50),
                                    isCurrent
                                        ? color
                                        : const Color(0xFF4CAF50)
                                  ]
                                : isCurrent
                                    ? [color, Colors.grey.shade200]
                                    : [
                                        Colors.grey.shade200,
                                        Colors.grey.shade200
                                      ],
                          ),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(width: 14),
                // Label
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: i < steps.length - 1 ? 24 : 0,
                        top: 2),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        _statusLabel(step),
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isFuture
                              ? Colors.grey.shade400
                              : AppColors.textDark,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 2),
                        Text(
                          _statusSubtitle(step),
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textLight,
                              height: 1.4),
                        ),
                      ],
                    ]),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsCard(TrackedOrder order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Text('Your Order',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
        ]),
        const SizedBox(height: 16),
        ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    Text(
                      '${item.name} × ${item.quantity}',
                      style: GoogleFonts.poppins(
                          fontSize: 13.5, color: AppColors.textDark),
                    ),
                  ]),
                  Text(
                    '₹${(item.priceAtTime * item.quantity).toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                ],
              ),
            )),
        const Divider(thickness: 0.5, height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total Paid',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFFF8C42)])
                .createShader(b),
            child: Text(
              '₹${order.totalAmount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
          ),
        ]),
      ]),
    );
  }
}