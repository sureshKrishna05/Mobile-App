import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/order_tracking_page.dart';

// ─────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────
class HistoryOrder {
  final String id;
  final String status;
  final double totalAmount;
  final String createdAt;
  final String canteenName;
  final int itemCount;

  const HistoryOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.canteenName,
    required this.itemCount,
  });

  factory HistoryOrder.fromMap(Map<String, dynamic> map) {
    final items = map['order_items'] as List? ?? [];
    return HistoryOrder(
      id: map['id'] as String,
      status: map['status'] as String,
      totalAmount: double.tryParse(map['total_amount'].toString()) ?? 0.0,
      createdAt: map['created_at'] as String,
      canteenName:
          (map['canteens']?['name'] as String?) ?? 'Canteen',
      itemCount: items.length,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with TickerProviderStateMixin {
  List<HistoryOrder> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'all'; // all | active | completed | cancelled

  late final AnimationController _entryController;
  late final AnimationController _orbController;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _orbController = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);

    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.0, 0.5,
                    curve: Curves.easeOutCubic)));

    _fetchOrders();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      final data = await Supabase.instance.client
          .from('orders')
          .select('''
            id, status, total_amount, created_at,
            canteens ( name ),
            order_items ( id )
          ''')
          .eq('student_id', userId)
          .order('created_at', ascending: false);

      final orders = (data as List)
          .map((o) => HistoryOrder.fromMap(o as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
        _entryController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load orders.';
          _isLoading = false;
        });
      }
    }
  }

  List<HistoryOrder> get _filtered {
    switch (_filter) {
      case 'active':
        return _orders
            .where((o) => ['paid', 'accepted', 'preparing', 'ready']
                .contains(o.status))
            .toList();
      case 'completed':
        return _orders.where((o) => o.status == 'completed').toList();
      case 'cancelled':
        return _orders.where((o) => o.status == 'cancelled').toList();
      default:
        return _orders;
    }
  }

  String _formatDate(String ts) {
    final dt = DateTime.tryParse(ts)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatOrderId(String id) =>
      'SC-${id.substring(0, 8).toUpperCase()}';

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':      return const Color(0xFFFF9800);
      case 'accepted':  return const Color(0xFF2196F3);
      case 'preparing': return AppColors.primary;
      case 'ready':     return const Color(0xFF4CAF50);
      case 'completed': return const Color(0xFF4CAF50);
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'paid':      return 'Placed';
      case 'accepted':  return 'Accepted';
      case 'preparing': return 'Preparing';
      case 'ready':     return 'Ready';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default:          return status;
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

  bool _isActive(String status) =>
      ['paid', 'accepted', 'preparing', 'ready'].contains(status);

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
        builder: (_, _) => Align(
          alignment: const Alignment(1.3, -0.8),
          child: Transform.translate(
            offset:
                Offset(0, 25 * (_orbController.value * 2 - 1)),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08)),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _orbController,
        builder: (_, _) => Align(
          alignment: const Alignment(-1.2, 0.6),
          child: Transform.translate(
            offset:
                Offset(0, -20 * (_orbController.value * 2 - 1)),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB74D).withValues(alpha: 0.11)),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildLoading() {
    return const Center(
        child:
            CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              _fetchOrders();
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
    final filtered = _filtered;

    return Column(children: [
      // ── Header ────────────────────────────────────────────────
      SlideTransition(
        position: _headerSlide,
        child: FadeTransition(
          opacity: _headerFade,
          child: _buildHeader(),
        ),
      ),

      // ── Filter chips ─────────────────────────────────────────
      _buildFilterChips(),
      const SizedBox(height: 8),

      // ── List ─────────────────────────────────────────────────
      Expanded(
        child: filtered.isEmpty
            ? _buildEmpty()
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  setState(() => _isLoading = true);
                  await _fetchOrders();
                },
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final order = filtered[i];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(
                          milliseconds: 350 + i * 60),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, (1 - v) * 24),
                          child: child,
                        ),
                      ),
                      child: _buildOrderCard(order),
                    );
                  },
                ),
              ),
      ),
    ]);
  }

  Widget _buildHeader() {
    final completed =
        _orders.where((o) => o.status == 'completed').length;
    final totalSpent = _orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (s, o) => s + o.totalAmount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
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
          Text('Order History',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
        ]),
        if (_orders.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _buildStatChip(
                label: 'Total Orders',
                value: '${_orders.length}',
                icon: Icons.receipt_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatChip(
                label: 'Total Spent',
                value: '₹${totalSpent.toStringAsFixed(0)}',
                icon: Icons.currency_rupee_rounded,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatChip(
                label: 'Completed',
                value: '$completed',
                icon: Icons.done_all_rounded,
                color: const Color(0xFF2196F3),
              ),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 9,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('all', 'All'),
      ('active', 'Active'),
      ('completed', 'Completed'),
      ('cancelled', 'Cancelled'),
    ];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i];
          final sel = _filter == f.$1;
          return GestureDetector(
            onTap: () => setState(() => _filter = f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: sel
                    ? const LinearGradient(colors: [
                        AppColors.primary,
                        Color(0xFFFF8C42)
                      ])
                    : null,
                color: sel ? null : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: sel ? 12 : 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Text(f.$2,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color:
                        sel ? Colors.white : AppColors.textLight,
                  )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_outlined,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No orders yet',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color:
                      AppColors.textDark.withValues(alpha: 0.6))),
          const SizedBox(height: 8),
          Text(
            _filter == 'all'
                ? 'Your order history will appear here once you place an order.'
                : 'No $_filter orders found.',
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textLight,
                height: 1.5),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }

  Widget _buildOrderCard(HistoryOrder order) {
    final statusColor = _statusColor(order.status);
    final active = _isActive(order.status);

    return GestureDetector(
      onTap: () {
        if (order.status != 'cancelled') {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, _) =>
                  OrderTrackingPage(orderId: order.id),
              transitionsBuilder: (_, anim, _, child) =>
                  SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
              transitionDuration:
                  const Duration(milliseconds: 350),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: active
                  ? statusColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: active ? 18 : 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(children: [
          // ── Top row ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(children: [
              // Status icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_statusIcon(order.status),
                    size: 22, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(order.canteenName,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(
                    '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} · ${_formatDate(order.createdAt)}',
                    style: GoogleFonts.poppins(
                        fontSize: 11.5, color: AppColors.textLight),
                  ),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₹${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor),
                  ),
                ),
              ]),
            ]),
          ),

          // ── Bottom bar ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? statusColor.withValues(alpha: 0.05)
                  : const Color(0xFFF7F7F7),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatOrderId(order.id),
                  style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: AppColors.textLight,
                      letterSpacing: 0.5),
                ),
                if (order.status == 'cancelled')
                  Text('Cancelled',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.w600))
                else if (order.status == 'completed')
                  Row(children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 13, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 4),
                    Text('Order completed',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600)),
                  ])
                else
                  Row(children: [
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.primary),
                    Text('Track order',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}