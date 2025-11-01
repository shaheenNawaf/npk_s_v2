import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SoilGuideModal extends StatelessWidget {
  const SoilGuideModal({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Visual Soil Guide",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Use this simple 'Ribbon Test' to estimate your soil's texture.",
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
              const Divider(height: 32),

              _buildGuideSection(
                context,
                icon: Icons.water_drop,
                imageLocation: 'assets/step_1.png',
                title: "Step 1: Wet the Soil",
                content:
                    "Take a small, representative sample of your soil (about a tablespoon). Slowly add water drop by drop and knead it until it has a moist, putty-like consistency.",
              ),

              _buildGuideSection(
                context,
                icon: Icons.waving_hand,
                imageLocation: 'assets/step_5.png',
                title: "Step 2: Form a Ribbon",
                content:
                    "Squeeze the moist soil between your thumb and forefinger to form a 'ribbon.' Pay attention to how long the ribbon can get before it breaks.",
              ),

              _buildGuideSection(
                context,
                icon: Icons.science,
                imageLocation: 'assets/step_6.png',
                title: "Step 3: Interpret the Results",
                content:
                    "Use the feel and ribbon length to determine the texture group:",
                children: [
                  _buildResultTile(
                    "Gritty Feel, No Ribbon:",
                    "The soil is likely Coarse-textured (Sandy).",
                  ),
                  _buildResultTile(
                    "Smooth Feel, Short Ribbon (under 1 inch):",
                    "The soil is likely Medium-textured (Loamy or Silty).",
                  ),
                  _buildResultTile(
                    "Sticky Feel, Long Ribbon (over 2 inches):",
                    "The soil is likely Fine-textured (Clay).",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required String imageLocation,
    List<Widget> children = const [],
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Image.asset(imageLocation, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(color: Colors.grey.shade700),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildResultTile(String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.only(top: 8, left: 8),
      dense: true,
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 14)),
    );
  }
}
