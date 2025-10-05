import 'dart:convert';

class AiAdvice {
  final String title;
  final String summary;
  final List<String> actionableSteps;
  final List<String> thingsToAvoid;

  AiAdvice({
    required this.title,
    required this.summary,
    required this.actionableSteps,
    required this.thingsToAvoid,
  });

  factory AiAdvice.fromJson(String source) {
    final Map<String, dynamic> data = json.decode(source);

    final stepsList = data['actionable_steps'] as List?;
    final avoidList = data['things_to_avoid'] as List?;

    return AiAdvice(
      title: data['title'] ?? 'AI Advice',
      summary: data['summary'] ?? 'No summary provided.',
      actionableSteps: stepsList?.map((item) => item.toString()).toList() ?? [],
      thingsToAvoid: avoidList?.map((item) => item.toString()).toList() ?? [],
    );
  }
}
