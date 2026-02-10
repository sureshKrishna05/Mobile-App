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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Same Gradient Background as Login/Signup
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
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeroText(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 30),
                        _buildCategories(),
                        const SizedBox(height: 25),
                        _buildSectionTitle("Popular Now"),
                        const SizedBox(height: 15),
                        _buildPopularList(),
                        const SizedBox(height: 100), // Spacing for bottom nav if needed
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Optional: Floating Action Button or Bottom Bar could go here
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'), // Dummy profile
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
                          fontSize: 16)),
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

  Widget _buildHeroText() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
            fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
        children: const [
          TextSpan(text: "What would you\nlike to "),
          TextSpan(text: "eat today?", style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        Text("See all",
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPopularList() {
    // Dummy Data
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
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        return _buildFoodCard(foods[index]);
      },
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'],
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
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
                    const Text(
                      "20 mins",
                      style: TextStyle(color: AppColors.textLight, fontSize: 12),
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}