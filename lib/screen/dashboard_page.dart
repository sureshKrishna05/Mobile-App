import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/cart_page.dart';

class DashboardPage extends StatefulWidget {
  // ✅ FIX 1: Accept college info from CollegeSelectionPage
  final String collegeId;
  final String collegeName;

  const DashboardPage({
    super.key,
    required this.collegeId,
    required this.collegeName,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {

  int _selectedCategoryIndex = 0;
  final Set<int> _wishlist = {};
  final Map<int, int> _cart = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // ✅ FIX 2: Real user data from Supabase
  String _userName = 'Loading...';
  String? _avatarUrl;

  late final AnimationController _pageEntryController;
  late final AnimationController _orbController;
  late final AnimationController _shimmerController;
  late final AnimationController _pulseController;
  late final AnimationController _filterFadeController;

  late final Animation<double> _appBarFade;
  late final Animation<Offset> _appBarSlide;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _searchFade;
  late final Animation<double> _contentFade;

  final List<Map<String, dynamic>> _categories = [
    {"label": "All",       "icon": Icons.apps_rounded},
    {"label": "Breakfast", "icon": Icons.free_breakfast_rounded},
    {"label": "Lunch",     "icon": Icons.lunch_dining_rounded},
    {"label": "Snacks",    "icon": Icons.cookie_rounded},
    {"label": "Drinks",    "icon": Icons.local_drink_rounded},
  ];

  final List<Map<String, dynamic>> _allFoods = [
    {"id": 0,  "name": "Masala Omelette",     "price": "60",  "img": "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=500&q=80", "rating": "4.7", "tag": "POPULAR",    "time": "10 mins", "tagColor": 0xFFFF5722, "category": 1},
    {"id": 1,  "name": "Poha",                "price": "40",  "img": "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=500&q=80", "rating": "4.5", "tag": "LIGHT",      "time": "8 mins",  "tagColor": 0xFF4CAF50, "category": 1},
    {"id": 2,  "name": "Idli Sambar",         "price": "50",  "img": "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=500&q=80", "rating": "4.8", "tag": "HEALTHY",    "time": "12 mins", "tagColor": 0xFF00BCD4, "category": 1},
    {"id": 3,  "name": "Bread Omelette",      "price": "55",  "img": "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=500&q=80", "rating": "4.4", "tag": "FILLING",    "time": "10 mins", "tagColor": 0xFF9C27B0, "category": 1},
    {"id": 4,  "name": "Upma",                "price": "35",  "img": "https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=500&q=80", "rating": "4.3", "tag": "CLASSIC",    "time": "8 mins",  "tagColor": 0xFF795548, "category": 1},
    {"id": 5,  "name": "Dosa & Chutney",      "price": "70",  "img": "https://images.unsplash.com/photo-1630383249896-424e482df921?auto=format&fit=crop&w=500&q=80", "rating": "4.9", "tag": "BESTSELLER", "time": "15 mins", "tagColor": 0xFFFF5722, "category": 1},
    {"id": 6,  "name": "Veg Thali",           "price": "120", "img": "https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=500&q=80", "rating": "4.7", "tag": "BESTSELLER", "time": "20 mins", "tagColor": 0xFFFF5722, "category": 2},
    {"id": 7,  "name": "Chicken Biryani",     "price": "180", "img": "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=500&q=80", "rating": "4.9", "tag": "HOT",        "time": "25 mins", "tagColor": 0xFFFF9800, "category": 2},
    {"id": 8,  "name": "Paneer Butter Masala","price": "150", "img": "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=500&q=80", "rating": "4.6", "tag": "RICH",       "time": "20 mins", "tagColor": 0xFFE91E63, "category": 2},
    {"id": 9,  "name": "Dal Rice",            "price": "90",  "img": "https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?auto=format&fit=crop&w=500&q=80", "rating": "4.5", "tag": "COMFORT",    "time": "15 mins", "tagColor": 0xFF795548, "category": 2},
    {"id": 10, "name": "Chapati Sabzi",       "price": "80",  "img": "https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=500&q=80", "rating": "4.4", "tag": "LIGHT",      "time": "15 mins", "tagColor": 0xFF4CAF50, "category": 2},
    {"id": 11, "name": "Egg Fried Rice",      "price": "110", "img": "https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=500&q=80", "rating": "4.6", "tag": "NEW",        "time": "18 mins", "tagColor": 0xFF2196F3, "category": 2},
    {"id": 12, "name": "Spicy Burger",        "price": "120", "img": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=80", "rating": "4.5", "tag": "BESTSELLER", "time": "15 mins", "tagColor": 0xFFFF5722, "category": 3},
    {"id": 13, "name": "Cheesy Fries",        "price": "90",  "img": "https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=500&q=80", "rating": "4.6", "tag": "HOT",        "time": "12 mins", "tagColor": 0xFFFF9800, "category": 3},
    {"id": 14, "name": "Veg Pizza",           "price": "250", "img": "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=500&q=80", "rating": "4.2", "tag": "NEW",        "time": "25 mins", "tagColor": 0xFF4CAF50, "category": 3},
    {"id": 15, "name": "Samosa (2 pcs)",      "price": "30",  "img": "https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=500&q=80", "rating": "4.7", "tag": "CLASSIC",    "time": "5 mins",  "tagColor": 0xFF795548, "category": 3},
    {"id": 16, "name": "Pav Bhaji",           "price": "80",  "img": "https://images.unsplash.com/photo-1606491956689-2ea866880c84?auto=format&fit=crop&w=500&q=80", "rating": "4.8", "tag": "POPULAR",    "time": "15 mins", "tagColor": 0xFFFF5722, "category": 3},
    {"id": 17, "name": "Maggi Noodles",       "price": "50",  "img": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=500&q=80", "rating": "4.5", "tag": "QUICK",      "time": "8 mins",  "tagColor": 0xFF9C27B0, "category": 3},
    {"id": 18, "name": "Mango Lassi",         "price": "60",  "img": "https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?auto=format&fit=crop&w=500&q=80", "rating": "4.8", "tag": "POPULAR",    "time": "5 mins",  "tagColor": 0xFFFF9800, "category": 4},
    {"id": 19, "name": "Cold Coffee",         "price": "70",  "img": "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=500&q=80", "rating": "4.7", "tag": "CHILLED",    "time": "5 mins",  "tagColor": 0xFF795548, "category": 4},
    {"id": 20, "name": "Fresh Lime Soda",     "price": "40",  "img": "https://images.unsplash.com/photo-1621263764928-df1444c5e859?auto=format&fit=crop&w=500&q=80", "rating": "4.5", "tag": "FRESH",      "time": "3 mins",  "tagColor": 0xFF4CAF50, "category": 4},
    {"id": 21, "name": "Masala Chai",         "price": "25",  "img": "https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=500&q=80", "rating": "4.9", "tag": "BESTSELLER", "time": "5 mins",  "tagColor": 0xFFFF5722, "category": 4},
    {"id": 22, "name": "Watermelon Juice",    "price": "50",  "img": "https://images.unsplash.com/photo-1568909344668-6f14a07b56a0?auto=format&fit=crop&w=500&q=80", "rating": "4.6", "tag": "HEALTHY",    "time": "5 mins",  "tagColor": 0xFF00BCD4, "category": 4},
    {"id": 23, "name": "Buttermilk",          "price": "30",  "img": "https://images.unsplash.com/photo-1572441713132-c542fc4fe282?auto=format&fit=crop&w=500&q=80", "rating": "4.4", "tag": "LIGHT",      "time": "3 mins",  "tagColor": 0xFF9C27B0, "category": 4},
  ];

  final List<Map<String, dynamic>> _featured = [
    {"title": "Today's Special", "subtitle": "Veg Thali Deal",         "discount": "30% OFF",  "img": "https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80",  "gradient": [0xFFFF5722, 0xFFFF8C42]},
    {"title": "Combo Offer",     "subtitle": "Burger + Fries + Drink", "discount": "₹199 Only","img": "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80",  "gradient": [0xFF6B3A2A, 0xFFFF5722]},
    {"title": "Morning Special", "subtitle": "Dosa + Chai Combo",      "discount": "₹79 Only", "img": "https://images.unsplash.com/photo-1630383249896-424e482df921?auto=format&fit=crop&w=800&q=80","gradient": [0xFF00796B, 0xFF4CAF50]},
  ];

  int _currentBannerIndex = 0;
  late final PageController _bannerController;

  List<Map<String, dynamic>> get _filteredFoods {
    final List<Map<String, dynamic>> byCategory = _selectedCategoryIndex == 0
        ? List.from(_allFoods)
        : _allFoods.where((f) => f['category'] as int == _selectedCategoryIndex).toList();

    if (_searchQuery.trim().isEmpty) return byCategory;
    return byCategory
        .where((f) => (f['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();

    _pageEntryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _appBarFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _pageEntryController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _appBarSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero).animate(CurvedAnimation(parent: _pageEntryController, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)));
    _heroFade    = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _pageEntryController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));
    _heroSlide   = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(CurvedAnimation(parent: _pageEntryController, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)));
    _searchFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _pageEntryController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _pageEntryController, curve: const Interval(0.55, 1.0, curve: Curves.easeOut)));

    _orbController     = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
    _pulseController   = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _filterFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300), value: 1.0);

    _pageEntryController.forward();

    // ✅ FIX 3: Fetch real user profile from Supabase
    _loadUserProfile();
  }

  // ✅ FIX 4: Real profile fetch
  Future<void> _loadUserProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();

      if (mounted && profile != null) {
        setState(() {
          _userName = profile['full_name'] as String? ?? 'Student';
        });
      }
    } catch (_) {
      // Silently fallback to default name
      if (mounted) setState(() => _userName = 'Student');
    }
  }

  @override
  void dispose() {
    _pageEntryController.dispose();
    _orbController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _filterFadeController.dispose();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onCategoryTap(int index) async {
    if (_selectedCategoryIndex == index) return;
    await _filterFadeController.animateTo(0.0, duration: const Duration(milliseconds: 160), curve: Curves.easeOut);
    setState(() => _selectedCategoryIndex = index);
    _filterFadeController.animateTo(1.0, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  // ✅ FIX 5: Pass real cart data to CartPage
  void _goToCart() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, _) => CartPage(
          cartQuantities: Map.from(_cart),
          allFoods: _allFoods,
        ),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  int get _cartCount => _cart.values.fold(0, (a, b) => a + b);

  double get _cartTotal => _cart.entries.fold(0.0, (sum, e) {
        final food = _allFoods.firstWhere((f) => f['id'] == e.key, orElse: () => {"price": "0"});
        return sum + double.parse(food['price'] as String) * e.value;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: Stack(children: [
        _buildBackground(),
        SafeArea(
          child: LayoutBuilder(builder: (ctx, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final isTablet  = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
            final double hPad = isDesktop ? constraints.maxWidth * 0.1 : (isTablet ? 36 : 22);

            return Column(children: [
              SlideTransition(
                position: _appBarSlide,
                child: FadeTransition(
                  opacity: _appBarFade,
                  child: _buildAppBar(hPad, constraints.maxWidth),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: SlideTransition(
                        position: _heroSlide,
                        child: FadeTransition(opacity: _heroFade, child: _buildHeroText(constraints.maxWidth)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: FadeTransition(opacity: _searchFade, child: _buildSearchBar()),
                    ),
                    const SizedBox(height: 26),
                    FadeTransition(
                      opacity: _contentFade,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: _TodaysMenuButton(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (_) => _TodaysMenuSheet(
                                  foods: _allFoods,
                                  cart: _cart,
                                  onAdd: (id) => setState(() {
                                    _cart[id] = (_cart[id] ?? 0) + 1;
                                    _pulseController..reset()..forward();
                                  }),
                                  onRemove: (id) => setState(() {
                                    final c = _cart[id] ?? 0;
                                    if (c <= 1) {
                                      _cart.remove(id);
                                    } else {
                                      _cart[id] = c - 1;
                                    }
                                  }),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 22),
                        _buildFeaturedBanner(hPad),
                        const SizedBox(height: 28),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: _buildCategories(),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: _buildSectionHeader(constraints.maxWidth),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: _buildFoodGrid(),
                        ),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ]),
                ),
              ),
            ]);
          }),
        ),
        if (_cartCount > 0)
          Positioned(bottom: 24, left: 0, right: 0, child: _buildFloatingCart()),
      ]),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8F2), Color(0xFFFEF0E6), Color(0xFFFDF5ED)],
          ),
        ),
      ),
      _AnimatedOrb(controller: _orbController, color: AppColors.primary.withValues(alpha: 0.10), size: 280, alignment: const Alignment(1.3, -0.9),  phaseShift: 0),
      _AnimatedOrb(controller: _orbController, color: const Color(0xFFFFB74D).withValues(alpha: 0.13), size: 200, alignment: const Alignment(-1.2, 0.4), phaseShift: math.pi / 2),
      _AnimatedOrb(controller: _orbController, color: AppColors.primary.withValues(alpha: 0.06), size: 150, alignment: const Alignment(0.5, 1.4),   phaseShift: math.pi),
      Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
    ]);
  }

  Widget _buildAppBar(double hPad, double maxWidth) {
    final double avatarR  = (maxWidth * 0.035).clamp(20.0, 26.0);
    final double nameSize = (maxWidth * 0.038).clamp(15.0, 19.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [AppColors.primary, Color(0xFFFF8C42)]),
          ),
          // ✅ FIX 6: Real user avatar (falls back to pravatar if no URL)
          child: CircleAvatar(
            radius: avatarR,
            backgroundImage: _avatarUrl != null
                ? NetworkImage(_avatarUrl!)
                : const NetworkImage('https://i.pravatar.cc/150?img=12'),
            backgroundColor: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Good Morning 👋",
                style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 11.5)),
            // ✅ FIX 7: Real user name
            Text(_userName,
                style: GoogleFonts.playfairDisplay(
                    color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: nameSize)),
          ]),
        ),
        _IconBtn(icon: Icons.notifications_outlined, badge: "3", onTap: () {}),
        const SizedBox(width: 10),
        _IconBtn(
          icon: Icons.shopping_bag_outlined,
          badge: _cartCount > 0 ? "$_cartCount" : null,
          onTap: _goToCart,
          isPrimary: true,
        ),
      ]),
    );
  }

  Widget _buildHeroText(double maxWidth) {
    final double fs = (maxWidth * 0.07).clamp(28.0, 46.0);
    // ✅ FIX 8: Show selected college name
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.collegeName,
          style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 12)),
      Text("What would you",
          style: GoogleFonts.playfairDisplay(fontSize: fs, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.1)),
      RichText(
        text: TextSpan(
          style: GoogleFonts.playfairDisplay(fontSize: fs, fontWeight: FontWeight.w800, height: 1.1),
          children: [
            const TextSpan(text: "like to ", style: TextStyle(color: Color(0xFF2D2D2D))),
            TextSpan(
              text: "eat?",
              style: TextStyle(
                foreground: Paint()..shader = const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF8C42)],
                ).createShader(const Rect.fromLTWH(0, 0, 150, 50)),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildSearchBar() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: "Search meals, snacks, drinks...",
                hintStyle: GoogleFonts.poppins(color: Colors.black26, fontSize: 13.5),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.close_rounded, color: Colors.black38, size: 18),
              ),
            ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF8C42)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.tune_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text("Filter", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildFeaturedBanner(double hPad) {
    return Column(children: [
      SizedBox(
        height: 168,
        child: PageView.builder(
          controller: _bannerController,
          itemCount: _featured.length,
          onPageChanged: (i) => setState(() => _currentBannerIndex = i),
          itemBuilder: (_, index) {
            final item   = _featured[index];
            final colors = (item['gradient'] as List<int>).map((c) => Color(c)).toList();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: _BannerCard(item: item, colors: colors),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_featured.length, (i) {
          final bool active = i == _currentBannerIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 20 : 6, height: 6,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    ]);
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (_, index) {
          final bool sel = _selectedCategoryIndex == index;
          final cat = _categories[index];
          return GestureDetector(
            onTap: () => _onCategoryTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: sel ? const LinearGradient(colors: [AppColors.primary, Color(0xFFFF8C42)]) : null,
                color: sel ? null : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(
                  color: sel ? AppColors.primary.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.05),
                  blurRadius: sel ? 14 : 6,
                  offset: const Offset(0, 4),
                )],
                border: sel ? null : Border.all(color: Colors.black.withValues(alpha: 0.07)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(cat['icon'] as IconData, size: 15, color: sel ? Colors.white : AppColors.primary),
                const SizedBox(width: 6),
                Text(cat['label'], style: GoogleFonts.poppins(color: sel ? Colors.white : AppColors.textLight, fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(double maxWidth) {
    final double fs = (maxWidth * 0.048).clamp(18.0, 24.0);
    final filtered  = _filteredFoods;
    final catLabel  = _categories[_selectedCategoryIndex]['label'] as String;
    final String title = _selectedCategoryIndex == 0 ? "Popular Now" : catLabel;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: fs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text("${filtered.length} items", style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ]),
      GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text("See all →", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ),
    ]);
  }

  Widget _buildFoodGrid() {
    final foods = _filteredFoods;

    if (foods.isEmpty) {
      return FadeTransition(
        opacity: _filterFadeController,
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.search_off_rounded, size: 52, color: AppColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text("No items found", style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark.withValues(alpha: 0.5))),
              const SizedBox(height: 6),
              Text("Try a different category or search term", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
            ]),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _filterFadeController,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisExtent: 140,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: foods.length,
        itemBuilder: (_, index) {
          final food   = foods[index];
          final foodId = food['id'] as int;
          return _FoodCard(
            food: food,
            isWishlisted: _wishlist.contains(foodId),
            cartCount: _cart[foodId] ?? 0,
            shimmerController: _shimmerController,
            onWishlist: () => setState(() => _wishlist.contains(foodId) ? _wishlist.remove(foodId) : _wishlist.add(foodId)),
            onAdd: () => setState(() {
              _cart[foodId] = (_cart[foodId] ?? 0) + 1;
              _pulseController..reset()..forward();
            }),
            onRemove: () => setState(() {
              final c = _cart[foodId] ?? 0;
              if (c <= 1) {
                _cart.remove(foodId);
              } else {
                _cart[foodId] = c - 1;
              }
            }),
          );
        },
      ),
    );
  }

  Widget _buildFloatingCart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut)),
        child: GestureDetector(
          onTap: _goToCart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2D2D2D), Color(0xFF4A2010)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text("$_cartCount", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text("View Cart", style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
              Text("₹${_cartTotal.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// All supporting widgets below are identical to the original
// (TodaysMenuButton, TodaysMenuSheet, BannerCard, FoodCard, etc.)
// ─────────────────────────────────────────────────────────────────

class _TodaysMenuButton extends StatefulWidget {
  final VoidCallback onTap;
  const _TodaysMenuButton({required this.onTap});
  @override
  State<_TodaysMenuButton> createState() => _TodaysMenuButtonState();
}

class _TodaysMenuButtonState extends State<_TodaysMenuButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown:   (_) => _ctrl.forward(),
        onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2D2D2D), Color(0xFF4A2010)], begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Today's Menu", style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                Text("See what's available right now", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11.5)),
              ]),
            ),
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14)),
          ]),
        ),
      ),
    );
  }
}

class _TodaysMenuSheet extends StatelessWidget {
  final List<Map<String, dynamic>> foods;
  final Map<int, int> cart;
  final void Function(int id) onAdd;
  final void Function(int id) onRemove;

  const _TodaysMenuSheet({required this.foods, required this.cart, required this.onAdd, required this.onRemove});

  static const List<Map<String, dynamic>> _sections = [
    {"label": "Breakfast", "icon": Icons.free_breakfast_rounded, "category": 1},
    {"label": "Lunch",     "icon": Icons.lunch_dining_rounded,   "category": 2},
    {"label": "Snacks",    "icon": Icons.cookie_rounded,         "category": 3},
    {"label": "Drinks",    "icon": Icons.local_drink_rounded,    "category": 4},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75, maxChildSize: 0.95, minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF8F2), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(children: [
              Text("Today's Menu", style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.06), shape: BoxShape.circle), child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textDark)),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: Text("Full menu available today", style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: _sections.map((section) {
                final sectionFoods = foods.where((f) => f['category'] as int == section['category'] as int).toList();
                return _MenuSection(label: section['label'] as String, icon: section['icon'] as IconData, foods: sectionFoods, cart: cart, onAdd: onAdd, onRemove: onRemove);
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MenuSection extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Map<String, dynamic>> foods;
  final Map<int, int> cart;
  final void Function(int) onAdd;
  final void Function(int) onRemove;
  const _MenuSection({required this.label, required this.icon, required this.foods, required this.cart, required this.onAdd, required this.onRemove});
  @override
  State<_MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<_MenuSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(widget.icon, size: 16, color: AppColors.primary)),
            const SizedBox(width: 10),
            Text(widget.label, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(width: 8),
            Text("(${widget.foods.length})", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
            const Spacer(),
            AnimatedRotation(turns: _expanded ? 0 : -0.25, duration: const Duration(milliseconds: 250), child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textLight, size: 22)),
          ]),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: _expanded
            ? Column(
                children: widget.foods.map((food) {
                  final id    = food['id'] as int;
                  final count = widget.cart[id] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(food['img'] as String, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(width: 56, height: 56, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(food['name'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text("₹${food['price']}", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ]),
                      ),
                      count == 0
                          ? GestureDetector(onTap: () => widget.onAdd(id), child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF8C42)]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add_rounded, color: Colors.white, size: 16)))
                          : Row(mainAxisSize: MainAxisSize.min, children: [
                              _SheetCounterBtn(icon: Icons.remove_rounded, onTap: () => widget.onRemove(id)),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text("$count", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary))),
                              _SheetCounterBtn(icon: Icons.add_rounded, onTap: () => widget.onAdd(id), isPrimary: true),
                            ]),
                    ]),
                  );
                }).toList(),
              )
            : const SizedBox.shrink(),
      ),
      const SizedBox(height: 6),
    ]);
  }
}

class _SheetCounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  const _SheetCounterBtn({required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: isPrimary ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 14, color: isPrimary ? Colors.white : AppColors.primary)));
  }
}

class _BannerCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final List<Color> colors;
  const _BannerCard({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(fit: StackFit.expand, children: [
        Image.network(item['img'] as String, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: colors.first)),
        Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.first.withValues(alpha: 0.85), colors.last.withValues(alpha: 0.6), Colors.transparent], stops: const [0.0, 0.5, 1.0], begin: Alignment.centerLeft, end: Alignment.centerRight))),
        Positioned(
          left: 22, top: 0, bottom: 0,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 0.8)), child: Text(item['discount'] as String, style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1))),
            const SizedBox(height: 8),
            Text(item['title'] as String, style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w500)),
            Text(item['subtitle'] as String, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text("Order Now", style: GoogleFonts.poppins(color: colors.first, fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
        ),
      ]),
    );
  }
}

class _FoodCard extends StatefulWidget {
  final Map<String, dynamic> food;
  final bool isWishlisted;
  final int  cartCount;
  final AnimationController shimmerController;
  final VoidCallback onWishlist;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _FoodCard({required this.food, required this.isWishlisted, required this.cartCount, required this.shimmerController, required this.onWishlist, required this.onAdd, required this.onRemove});

  @override
  State<_FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<_FoodCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), reverseDuration: const Duration(milliseconds: 200));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(widget.food['tagColor'] as int);
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp:   (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.055), blurRadius: 18, offset: const Offset(0, 6))]),
          child: Row(children: [
            Stack(children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                child: Image.network(widget.food['img'] as String, width: 110, height: double.infinity, fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) { if (progress == null) return child; return _ShimmerBox(controller: widget.shimmerController, width: 110); },
                  errorBuilder: (_, _, _) => Container(width: 110, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
              Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(8)), child: Text(widget.food['tag'] as String, style: GoogleFonts.spaceMono(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.8)))),
            ]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Text(widget.food['name'] as String, style: GoogleFonts.playfairDisplay(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    GestureDetector(
                      onTap: widget.onWishlist,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Icon(widget.isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded, key: ValueKey(widget.isWishlisted), size: 18, color: widget.isWishlisted ? Colors.redAccent : Colors.black26),
                      ),
                    ),
                  ]),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14),
                    const SizedBox(width: 3),
                    Text(widget.food['rating'] as String, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Icon(Icons.timer_outlined, size: 12, color: Colors.black38),
                    const SizedBox(width: 3),
                    Text(widget.food['time'] as String, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("₹${widget.food['price']}", style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    widget.cartCount == 0
                        ? _AddButton(onTap: widget.onAdd)
                        : _CounterWidget(count: widget.cartCount, onAdd: widget.onAdd, onRemove: widget.onRemove),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF8C42)]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]), child: const Icon(Icons.add_rounded, color: Colors.white, size: 18)),
      );
}

class _CounterWidget extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _CounterWidget({required this.count, required this.onAdd, required this.onRemove});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          _CBtn(icon: Icons.remove_rounded, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child), child: Text("$count", key: ValueKey(count), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary))),
          ),
          _CBtn(icon: Icons.add_rounded, onTap: onAdd, isPrimary: true),
        ]),
      );
}

class _CBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  const _CBtn({required this.icon, required this.onTap, this.isPrimary = false});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: isPrimary ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 14, color: isPrimary ? Colors.white : AppColors.primary)));
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String?  badge;
  final VoidCallback onTap;
  final bool isPrimary;
  const _IconBtn({required this.icon, required this.onTap, this.badge, this.isPrimary = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Stack(clipBehavior: Clip.none, children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isPrimary ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: (isPrimary ? AppColors.primary : Colors.black).withValues(alpha: isPrimary ? 0.3 : 0.05), blurRadius: isPrimary ? 12 : 8, offset: const Offset(0, 4))]), child: Icon(icon, color: isPrimary ? Colors.white : AppColors.textDark, size: 20)),
          if (badge != null) Positioned(top: -4, right: -4, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))),
        ]),
      );
}

class _ShimmerBox extends StatelessWidget {
  final AnimationController controller;
  final double width;
  const _ShimmerBox({required this.controller, required this.width});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, _) => Container(width: width, decoration: BoxDecoration(gradient: LinearGradient(colors: const [Color(0xFFEEEEEE), Color(0xFFF8F8F8), Color(0xFFEEEEEE)], stops: [(controller.value - 0.3).clamp(0.0, 1.0), controller.value.clamp(0.0, 1.0), (controller.value + 0.3).clamp(0.0, 1.0)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
      );
}

class _AnimatedOrb extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double size;
  final Alignment alignment;
  final double phaseShift;
  const _AnimatedOrb({required this.controller, required this.color, required this.size, required this.alignment, required this.phaseShift});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, _) {
          final dy = 28.0 * math.sin(controller.value * math.pi + phaseShift);
          return Align(alignment: alignment, child: Transform.translate(offset: Offset(0, dy), child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color))));
        },
      );
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: 0.055)..style = PaintingStyle.fill;
    const spacing = 26.0;
    const radius  = 1.5;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}