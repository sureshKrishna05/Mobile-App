import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/cart_page.dart'; // for CartItem

class PaymentPage extends StatefulWidget {
  final double amountToPay;
  // ✅ FIX 1: Receives real cart items to create the order in Supabase
  final List<CartItem> cartItems;

  const PaymentPage({
    super.key,
    required this.amountToPay,
    required this.cartItems,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  String _selectedMethod = 'upi';
  bool _saveDetails = true;
  bool _isProcessing = false;
  bool _isPaid = false;
  String? _orderNumber;

  final TextEditingController _upiController = TextEditingController();

  final double _gst = 0.05;
  final double _delivery = 0.00;

  double get _tax => widget.amountToPay * _gst;
  double get _total => widget.amountToPay + _tax + _delivery;

  late final AnimationController _entryController;
  late final AnimationController _processController;
  late final AnimationController _successController;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _summaryFade;
  late final Animation<Offset> _summarySlide;
  late final Animation<double> _methodsFade;
  late final Animation<Offset> _methodsSlide;
  late final Animation<double> _footerFade;
  late final Animation<double> _successScale;
  late final Animation<double> _successFade;
  late final Animation<double> _processSpin;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.0, 0.4,
                    curve: Curves.easeOutCubic)));
    _summaryFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));
    _summarySlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.2, 0.6,
                    curve: Curves.easeOutCubic)));
    _methodsFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut)));
    _methodsSlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.4, 0.8,
                    curve: Curves.easeOutCubic)));
    _footerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _processController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _processSpin = Tween<double>(begin: 0, end: 1)
        .animate(_processController);

    _successController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
            parent: _successController, curve: Curves.elasticOut));
    _successFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _successController, curve: Curves.easeOut));

    _entryController.forward();
  }

  @override
  void dispose() {
    _upiController.dispose();
    _entryController.dispose();
    _processController.dispose();
    _successController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'upi',
      'title': 'UPI',
      'subtitle': 'Any UPI ID',
      'icon': Icons.account_balance_wallet_rounded,
      'color': 0xFF4CAF50
    },
    {
      'id': 'phonepe',
      'title': 'PhonePe',
      'subtitle': 'Pay via PhonePe UPI',
      'icon': Icons.phone_android_rounded,
      'color': 0xFF6739B7
    },
    {
      'id': 'paytm',
      'title': 'Paytm',
      'subtitle': 'Pay via Paytm Wallet/UPI',
      'icon': Icons.payments_rounded,
      'color': 0xFF00BAF2
    },
    {
      'id': 'netbanking',
      'title': 'Net Banking',
      'subtitle': 'All major banks supported',
      'icon': Icons.account_balance_rounded,
      'color': 0xFF3F51B5
    },
  ];

  // ✅ FIX 2: Create real order in Supabase on payment success
  Future<void> _onPayNow() async {
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      // Simulate payment processing delay
      await Future.delayed(const Duration(milliseconds: 2200));

      if (userId != null) {
        // ✅ FIX 3: Insert order row
        final orderResponse = await supabase
            .from('orders')
            .insert({
              'student_id': userId,
              'total_amount': _total,
              'status': 'paid',
              'payment_status': 'paid',
            })
            .select('id')
            .single();

        final orderId = orderResponse['id'] as String;

        // ✅ FIX 4: Insert order_items rows (one per cart item)
        final orderItems = widget.cartItems.map((item) => {
              'order_id': orderId,
              'quantity': item.quantity,
              'price_at_time': item.price,
              // Note: menu_item_id would need a real UUID from DB.
              // For now we store what we have. Wire this up once
              // menu_items are fetched from Supabase with real UUIDs.
            }).toList();

        await supabase.from('order_items').insert(orderItems);

        _orderNumber = 'SC${orderId.substring(0, 8).toUpperCase()}';
      } else {
        // Not logged in (e.g., guest) — still show success UI
        _orderNumber =
            'SC${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      }

      if (!mounted) return;
      _processController.stop();
      setState(() {
        _isProcessing = false;
        _isPaid = true;
      });
      _successController.forward();
      HapticFeedback.heavyImpact();
    } catch (e) {
      if (!mounted) return;
      _processController.stop();
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPaid) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: Stack(children: [
        _buildBackground(),
        SafeArea(
          child: Column(children: [
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                  opacity: _headerFade, child: _buildHeader()),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: _summarySlide,
                      child: FadeTransition(
                          opacity: _summaryFade,
                          child: _buildSummaryCard()),
                    ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _methodsSlide,
                      child: FadeTransition(
                          opacity: _methodsFade,
                          child: _buildPaymentMethods()),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                        opacity: _methodsFade,
                        child: _buildSaveToggle()),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: FadeTransition(
              opacity: _footerFade, child: _buildFooter()),
        ),
        if (_isProcessing) _buildProcessingOverlay(),
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
      Positioned(
        top: -60,
        right: -60,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08)),
        ),
      ),
      Positioned(
        bottom: 80,
        left: -40,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFB74D).withValues(alpha: 0.10)),
        ),
      ),
    ]);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
      child: Row(children: [
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
            Text('Checkout',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            Text('Review & confirm your order',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textLight)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_rounded,
                size: 12, color: Color(0xFF4CAF50)),
            const SizedBox(width: 4),
            Text('Secure',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8))
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
          Text('Order Summary',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
        ]),
        const SizedBox(height: 18),

        // ✅ FIX 5: Show real cart items in summary
        ...widget.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SummaryRow(
                label: '${item.name} × ${item.quantity}',
                value: '₹${(item.price * item.quantity).toStringAsFixed(0)}',
              ),
            )),

        _SummaryRow(
            label: 'GST (5%)',
            value: '₹${_tax.toStringAsFixed(0)}'),
        _SummaryRow(
            label: 'Delivery',
            value: 'FREE',
            valueColor: const Color(0xFF4CAF50)),
        const SizedBox(height: 14),
        Row(children: List.generate(
            40,
            (i) => Expanded(
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: 1.5,
                      color: i.isEven ? Colors.black12 : Colors.transparent),
                ))),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFFF8C42)])
                .createShader(b),
            child: Text('₹${_total.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.access_time_rounded,
                size: 14, color: Color(0xFFFF9800)),
            const SizedBox(width: 6),
            Text('Ready in 15 – 30 mins',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFE65100),
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Payment Method',
          style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark)),
      const SizedBox(height: 14),
      ..._methods.asMap().entries.map((entry) {
        final index = entry.key;
        final method = entry.value;
        final bool sel = _selectedMethod == method['id'];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + index * 80),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(
                  offset: Offset(0, (1 - v) * 20), child: child)),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedMethod = method['id'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: sel
                    ? Color(method['color'] as int)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: sel
                        ? Color(method['color'] as int)
                            .withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: sel ? 18 : 8,
                    offset: const Offset(0, 6),
                  )
                ],
                border: sel
                    ? null
                    : Border.all(
                        color: Colors.black.withValues(alpha: .06)),
              ),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sel
                        ? Colors.white.withValues(alpha: 0.2)
                        : Color(method['color'] as int)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(method['icon'] as IconData,
                      size: 22,
                      color: sel
                          ? Colors.white
                          : Color(method['color'] as int)),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(method['title'] as String,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textDark)),
                      Text(method['subtitle'] as String,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: sel
                                  ? Colors.white70
                                  : AppColors.textLight)),
                    ])),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? Colors.white : Colors.transparent,
                    border: Border.all(
                        color:
                            sel ? Colors.transparent : Colors.black26,
                        width: 2),
                  ),
                  child: sel
                      ? Center(
                          child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Color(method['color'] as int))))
                      : null,
                ),
              ]),
            ),
          ),
        );
      }),
      const SizedBox(height: 12),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SizeTransition(
              sizeFactor: anim, axisAlignment: -1, child: child),
        ),
        child: KeyedSubtree(
            key: ValueKey(_selectedMethod),
            child: _buildUPIInput()),
      ),
    ]);
  }

  Widget _buildUPIInput() {
    return _InputCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Color(0xFF4CAF50), size: 18),
          ),
          const SizedBox(width: 10),
          Text('Enter UPI / Payment Details',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _upiController,
          style:
              GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'yourname@upi',
            hintStyle:
                GoogleFonts.poppins(color: Colors.black26, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.alternate_email_rounded,
                color: Color(0xFF4CAF50), size: 18),
          ),
        ),
      ]),
    );
  }

  Widget _buildSaveToggle() {
    return GestureDetector(
      onTap: () => setState(() => _saveDetails = !_saveDetails),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(children: [
          const Icon(Icons.shield_rounded,
              size: 20, color: Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Save payment details',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              Text('Securely stored for next time',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
            ]),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 44,
            height: 24,
            decoration: BoxDecoration(
              color: _saveDetails ? AppColors.primary : Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: _saveDetails
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
      ),
      child: Row(children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
          Text('Total',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textLight)),
          Text('₹${_total.toStringAsFixed(0)}',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark)),
        ]),
        const SizedBox(width: 20),
        Expanded(
          child: _PayButton(
            label: 'Pay ₹${_total.toStringAsFixed(0)}',
            onTap: _onPayNow,
          ),
        ),
      ]),
    );
  }

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30)
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedBuilder(
                animation: _processSpin,
                builder: (_, __) => Transform.rotate(
                  angle: _processSpin.value * 2 * 3.14159,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary
                      ]),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: const Icon(Icons.lock_rounded,
                            color: AppColors.primary, size: 26),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Processing Payment',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 6),
              Text('Please wait a moment...',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textLight)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8F2), Color(0xFFFEF0E6)],
            ),
          ),
        ),
        ...List.generate(20, (i) {
          final colors = [
            AppColors.primary,
            const Color(0xFFFF8C42),
            const Color(0xFF4CAF50),
            const Color(0xFF2196F3)
          ];
          return Positioned(
            top: (i * 87.3) % 600,
            left: (i * 53.7) % 400,
            child: FadeTransition(
              opacity: _successFade,
              child: Container(
                width: 8 + (i % 4) * 4.0,
                height: 8 + (i % 4) * 4.0,
                decoration: BoxDecoration(
                  shape: i.isEven
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  color: colors[i % colors.length]
                      .withValues(alpha: 0.5),
                  borderRadius:
                      i.isEven ? null : BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              ScaleTransition(
                scale: _successScale,
                child: FadeTransition(
                  opacity: _successFade,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF4CAF50)
                                .withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 12))
                      ],
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 58),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _successFade,
                child: Column(children: [
                  Text('Payment Successful!',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text(
                      'Your order has been placed.\nWe\'ll have it ready in 15–30 mins.',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textLight,
                          height: 1.6),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.currency_rupee_rounded,
                          color: AppColors.primary, size: 20),
                      Text(_total.toStringAsFixed(0),
                          style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary)),
                      const SizedBox(width: 8),
                      Text('paid',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textLight)),
                    ]),
                  ),
                  const SizedBox(height: 36),
                  // ✅ FIX 6: Show real order number from Supabase
                  Text('Order #${_orderNumber ?? '---'}',
                      style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          color: AppColors.textLight,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            AppColors.primary,
                            Color(0xFFFF8C42)
                          ]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8))
                          ],
                        ),
                        child: Center(
                            child: Text('Back to Home',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16))),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Supporting widgets — unchanged
// ─────────────────────────────────────────────────────────────────
class _PayButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PayButton({required this.label, required this.onTap});

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF8C42)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(widget.label,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
          ]),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textLight)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textDark)),
      ]),
    );
  }
}

class _InputCard extends StatelessWidget {
  final Widget child;
  const _InputCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}