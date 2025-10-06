import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String range;
  final num rangeMin;
  final num rangeMax;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.range,
    required this.rangeMax,
    required this.rangeMin,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    Color valueColor;
    Icon? statusIcon;

    final double? numericValue = double.tryParse(value);

    if (numericValue != null) {
      if (numericValue >= rangeMin && numericValue <= rangeMax) {
        cardColor = const Color.fromARGB(255, 191, 230, 194);
        valueColor = Colors.green.shade800;
        statusIcon = Icon(
          Icons.check_circle,
          color: Colors.green.shade700,
          size: 10,
        );
      } else {
        cardColor = const Color.fromARGB(255, 191, 230, 194);
        valueColor = Colors.amber.shade900;
        statusIcon = Icon(
          Icons.warning,
          color: Colors.amber.shade800,
          size: 10,
        );
      }
    } else {
      cardColor = const Color.fromARGB(255, 191, 230, 194);
      valueColor = Colors.black87;
      statusIcon = null;
    }

    return Container(
      padding: const EdgeInsets.all(9.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12),
              ),
              if (statusIcon != null) ...[const SizedBox(width: 2), statusIcon],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            mainAxisAlignment: MainAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                unit,
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            range,
            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 8),
          ),
        ],
      ),
    );
  }
}
