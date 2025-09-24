import 'package:flutter/material.dart';

class GeminiResultCard extends StatelessWidget {
  final String title;
  final String content;

  const GeminiResultCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            SelectableText(content),
          ],
        ),
      ),
    );
  }
}
