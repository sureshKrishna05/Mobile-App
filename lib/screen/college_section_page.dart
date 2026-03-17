import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/dashboard_page.dart';

class CollegeSelectionPage extends StatelessWidget {
  const CollegeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 UPDATED: Working Unsplash URLs to prevent HTTP 404 errors
    final List<Map<String, String>> colleges = [
      {
        "name": "Engineering Campus", 
        "image": "https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=500&q=60", 
        "location": "North Block"
      },
      {
        "name": "Medical College", 
        "image": "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=500&q=60", 
        "location": "West Wing"
      },
      {
        "name": "Arts & Science", 
        "image": "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=500&q=60", 
        "location": "Central Hub"
      },
      {
        "name": "Business School", 
        "image": "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=500&q=60", 
        "location": "South Campus"
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
                // Determine layout breakpoints
                final bool isDesktop = constraints.maxWidth > 800;
                final bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth <= 800;
                
                // Fluid padding
                final double horizontalPadding = isDesktop ? constraints.maxWidth * 0.1 : (isTablet ? 40 : 25);
                
                // Fluid typography
                final double titleSize = (constraints.maxWidth * 0.08).clamp(28.0, 40.0);
                final double subtitleSize = (constraints.maxWidth * 0.04).clamp(16.0, 18.0);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text("Select Campus",
                          style: GoogleFonts.poppins(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                      const SizedBox(height: 5),
                      Text("Where are you ordering from today?",
                          style: TextStyle(color: AppColors.textLight, fontSize: subtitleSize)),
                      const SizedBox(height: 30),
                      
                      // Grid of Colleges
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250, 
                            // 🟢 FIX: Changed from 0.85 to 0.75 to make cards taller 
                            // and prevent "RenderFlex overflowed" errors.
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: colleges.length,
                          itemBuilder: (context, index) {
                            return _buildCollegeCard(context, colleges[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeCard(BuildContext context, Map<String, String> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  data['image']!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // 🟢 ADDED: Error Builder to safely handle broken links in the future
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                // 🟢 FIX: Reduced padding from 12 to 10 to give text more space
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data['name']!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            data['location']!,
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}