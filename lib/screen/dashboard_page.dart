import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/theme/app_color.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Dummy data for categories
  final List<String> categories = ["All", "Breakfast", "Lunch", "Snacks", "Drinks"];
  int selectedCategoryIndex = 0;

  // Moved data to state so it isn't recreated on every build
  final List<Map<String, dynamic>> foods = [
    {
      "name": "Spicy Burger",
      "price": "120",
      "img": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=60",
      "rating": "4.5"
    },
    {
      "name": "Veg Pizza",
      "price": "250",
      "img": "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=500&q=60",
      "rating": "4.2"
    },
    {
      "name": "Fresh Salad",
      "price": "90",
      "img": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=500&q=60",
      "rating": "4.8"
    },
    {
      "name": "Cheesy Fries",
      "price": "150",
      "img": "https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=500&q=60",
      "rating": "4.6"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, -0.3),
                radius: 1.2,
                colors: [AppColors.bgRadialStart, AppColors.bgRadialEnd],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Breakpoints for responsive padding
                final isDesktop = constraints.maxWidth >= 900;
                final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
                
                final double horizontalPadding = isDesktop ? size.width * 0.1 : (isTablet ? 40 : 25);

                return Column(
                  children: [
                    _buildAppBar(horizontalPadding, constraints.maxWidth),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildHeroText(constraints.maxWidth),
                            const SizedBox(height: 20),
                            _buildSearchBar(),
                            const SizedBox(height: 30),
                            _buildCategories(),
                            const SizedBox(height: 25),
                            _buildSectionTitle("Popular Now", constraints.maxWidth),
                            const SizedBox(height: 15),
                            _buildPopularGrid(), // Replaced list with responsive grid
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(double padding, double maxWidth) {
    // Fluid sizing for avatar and text
    final double avatarRadius = (maxWidth * 0.03).clamp(22.0, 28.0);
    final double nameSize = (maxWidth * 0.04).clamp(16.0, 20.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=12'),
                backgroundColor: AppColors.secondary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Good Morning,",
                      style: GoogleFonts.poppins(
                          color: AppColors.textLight, fontSize: 12)),
                  Text("Suresh Krishna",
                      style: GoogleFonts.poppins(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: nameSize)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark),
          )
        ],
      ),
    );
  }

  Widget _buildHeroText(double maxWidth) {
    // Scales fluidly between 28 and 45 based on screen size
    final double fontSize = (maxWidth * 0.06).clamp(28.0, 45.0);

    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
            fontSize: fontSize, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.2),
        children: const [
          TextSpan(text: "What would you\nlike to "),
          TextSpan(text: "eat today?", style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ConstrainedBox(
      // Caps the search bar width on large screens to prevent it from looking stretched
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search for food...",
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedCategoryIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : [],
                border: isSelected ? null : Border.all(color: Colors.black12),
              ),
              child: Text(
                categories[index],
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : AppColors.textLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, double maxWidth) {
    final double titleSize = (maxWidth * 0.045).clamp(18.0, 24.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: titleSize, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        Text("See all",
            style: GoogleFonts.poppins(
                fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPopularGrid() {
    // Responsive Grid that automatically determines column count based on available width
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // maxCrossAxisExtent ensures a card never exceeds 400px wide. 
      // This means 1 col on Mobile, 2 on Tablet, 3+ on Desktop.
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 130, // Fixed height for each card
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        return _buildFoodCard(foods[index]);
      },
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              food['img'],
              width: 90,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  food['name'],
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      food['rating'],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Text(
                        "20 mins",
                        style: TextStyle(color: AppColors.textLight, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "₹${food['price']}",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          
          // Add Button
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {},
                constraints: const BoxConstraints(), // Removes default extra padding
                padding: const EdgeInsets.all(12),
              ),
            ),
          )
        ],
      ),
    );
  }
}