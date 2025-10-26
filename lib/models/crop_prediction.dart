// lib/models/crop_prediction.dart

class PredictionResponse {
  final List<CropPrediction> predictions;

  PredictionResponse({required this.predictions});

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    var list = json['predictions'] as List?;
    List<CropPrediction> predictionsList =
        list?.map((i) => CropPrediction.fromJson(i)).toList() ?? [];
    return PredictionResponse(predictions: predictionsList);
  }
}

class CropPrediction {
  final String cropFamily;
  final double familyConfidence;
  final List<TopCrop> topCrops;

  CropPrediction({
    required this.cropFamily,
    required this.familyConfidence,
    required this.topCrops,
  });

  factory CropPrediction.fromJson(Map<String, dynamic> json) {
    var list = json['top_crops'] as List?;
    List<TopCrop> topCropsList =
        list?.map((i) => TopCrop.fromJson(i)).toList() ?? [];
    return CropPrediction(
      cropFamily: json['crop_family'],
      familyConfidence: (json['family_confidence'] as num).toDouble(),
      topCrops: topCropsList,
    );
  }
}

class TopCrop {
  final String specificCrop;
  final double confidence;

  TopCrop({required this.specificCrop, required this.confidence});

  factory TopCrop.fromJson(Map<String, dynamic> json) {
    return TopCrop(
      specificCrop: json['specific_crop'],
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
