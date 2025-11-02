class PredictionResponse {
  final String status;
  final String modelType;
  final String accuracyNote;
  final int inputFeaturesUsed;
  final TopRecommendation topRecommendation;
  final List<AlternativeRecommendation> alternativeRecommendations;

  PredictionResponse({
    required this.status,
    required this.modelType,
    required this.accuracyNote,
    required this.inputFeaturesUsed,
    required this.topRecommendation,
    required this.alternativeRecommendations,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;

    return PredictionResponse(
      status: json['status'] ?? 'unknown',
      modelType: json['model_type'] ?? 'unknown',
      accuracyNote: json['accuracy_note'] ?? '',
      inputFeaturesUsed: json['input_features_used'] ?? 0,
      topRecommendation: TopRecommendation.fromJson(
        summary['top_recommendation'] as Map<String, dynamic>,
      ),
      alternativeRecommendations:
          (summary['alternative_recommendations'] as List?)
              ?.map(
                (i) => AlternativeRecommendation.fromJson(
                  i as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}

class TopRecommendation {
  final String crop;
  final String family;
  final double overallConfidence;
  final String suitability;

  TopRecommendation({
    required this.crop,
    required this.family,
    required this.overallConfidence,
    required this.suitability,
  });

  factory TopRecommendation.fromJson(Map<String, dynamic> json) {
    return TopRecommendation(
      crop: json['crop'] ?? 'Unknown',
      family: json['family'] ?? 'Unknown',
      overallConfidence:
          (json['overall_confidence'] as num?)?.toDouble() ?? 0.0,
      suitability: json['suitability'] ?? 'Unknown',
    );
  }
}

class AlternativeRecommendation {
  final String crop;
  final String family;
  final double overallConfidence;
  final String suitability;

  AlternativeRecommendation({
    required this.crop,
    required this.family,
    required this.overallConfidence,
    required this.suitability,
  });

  factory AlternativeRecommendation.fromJson(Map<String, dynamic> json) {
    return AlternativeRecommendation(
      crop: json['crop'] ?? 'Unknown',
      family: json['family'] ?? 'Unknown',
      overallConfidence:
          (json['overall_confidence'] as num?)?.toDouble() ?? 0.0,
      suitability: json['suitability'] ?? 'Unknown',
    );
  }
}
