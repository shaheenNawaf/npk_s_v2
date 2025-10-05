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
          size: 16,
        );
      } else {
        cardColor = const Color.fromARGB(255, 191, 230, 194);
        valueColor = Colors.amber.shade900;
        statusIcon = Icon(
          Icons.warning,
          color: Colors.amber.shade800,
          size: 16,
        );
      }
    } else {
      cardColor = const Color.fromARGB(255, 191, 230, 194);
      valueColor = Colors.black87;
      statusIcon = null;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
              ),
              if (statusIcon != null) ...[const SizedBox(width: 4), statusIcon],
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
          Text(
            range,
            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
