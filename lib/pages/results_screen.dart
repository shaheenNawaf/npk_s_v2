import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//Other Imports char
import '../models/soil_data.dart';
import '../models/crop_prediction.dart';
import '../models/ai_advice.dart';
import '../services/gemini_service.dart';
import '../services/prediction_service.dart';
import 'widgets/app_bar.dart';

class ResultsScreen extends StatefulWidget {
  final SoilData soilData;

  const ResultsScreen({super.key, required this.soilData});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final GeminiService _geminiService;
  late final PredictionService _predictionService;

  bool _isPredicting = false;
  bool _isGettingAdvice = false;
  PredictionResponse? _predictionResponse;
  AiAdvice? _aiAdvice;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Correctly initializes Gemini Service with the API key
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      throw AssertionError(
        'GEMINI_API_KEY is not set. Please create config.json and run with --dart-define-from-file=config.json',
      );
    }
    _geminiService = GeminiService(apiKey);

    _predictionService = PredictionService();
  }

  Future<void> _predictBestCrop() async {
    setState(() {
      _isPredicting = true;
      _errorMessage = null;
      _predictionResponse = null;
    });
    try {
      final result = await _predictionService.predictCrop(widget.soilData);
      setState(() => _predictionResponse = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isPredicting = false);
    }
  }

  Future<void> _getGeneralAiAdvice() async {
    setState(() {
      _isGettingAdvice = true;
      _errorMessage = null;
      _aiAdvice = null;
    });
    final result = await _geminiService.getSoilCareAdvice(widget.soilData);
    setState(() {
      _aiAdvice = result;
      _isGettingAdvice = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAnyActionLoading = _isPredicting || _isGettingAdvice;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSectionTitle("Soil Analysis Complete"),
            // const SizedBox(height: 16),
            // GridView.count(
            //   crossAxisCount: 3,
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   mainAxisSpacing: 12,
            //   crossAxisSpacing: 12,
            //   childAspectRatio: 1.2,
            //   children: [
            //     StatCard(
            //       title: "Potassium",
            //       value: widget.soilData.kMgKg?.toStringAsFixed(0) ?? 'N/A',
            //       unit: "mg/kg",
            //       range: "Optimal: 100-200",
            //       rangeMin: 100,
            //       rangeMax: 200,
            //     ),
            //     StatCard(
            //       title: "Phosphorus",
            //       value: widget.soilData.pMgKg?.toStringAsFixed(0) ?? 'N/A',
            //       unit: "mg/kg",
            //       range: "Optimal: 30-50",
            //       rangeMin: 30,
            //       rangeMax: 50,
            //     ),
            //     StatCard(
            //       title: "Nitrogen",
            //       value: widget.soilData.nMgKg?.toStringAsFixed(0) ?? 'N/A',
            //       unit: "mg/kg",
            //       range: "Optimal: 25-50",
            //       rangeMin: 25,
            //       rangeMax: 50,
            //     ),
            //     StatCard(
            //       title: "Moisture",
            //       value: widget.soilData.hum?.toStringAsFixed(0) ?? 'N/A',
            //       unit: "%",
            //       range: "Optimal: 40-60",
            //       rangeMin: 40,
            //       rangeMax: 60,
            //     ),
            //     StatCard(
            //       title: "pH Level",
            //       value: widget.soilData.ph?.toStringAsFixed(1) ?? 'N/A',
            //       unit: "",
            //       range: "Optimal: 6.0-7.0",
            //       rangeMin: 6.0,
            //       rangeMax: 7.0,
            //     ),
            //     StatCard(
            //       title: "OM",
            //       value:
            //           widget.soilData.organicMatter?.toStringAsFixed(1) ??
            //           'N/A',
            //       unit: "%",
            //       range: "Optimal: 2-6",
            //       rangeMin: 2,
            //       rangeMax: 6,
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 24),
            _buildSectionTitle("Complete Soil Data Summary"),
            const SizedBox(height: 16),
            _buildDataSummaryCard(),
            if (_predictionResponse != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle("Crop Recommendation (${_predictionResponse!.accuracyNote})"),
              const SizedBox(height: 16),
              _buildPredictionResultCard(_predictionResponse!),
            ],
            if (_aiAdvice != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle("General AI Advice"),
              const SizedBox(height: 16),
              _buildAiAdviceCard(_aiAdvice!),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (isAnyActionLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        _isPredicting
                          ? "Analyzing ${widget.soilData.nMgKg != null ? '111' : 'available'} soil features..."
                          : "Consulting AI for personalized advice...",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D32),
                          const Color(0xFF66BB6A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _predictBestCrop,
                      icon: const Icon(Icons.agriculture, color: Colors.white),
                      label: Text(
                        "Predict Best Crop",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1976D2),
                          const Color(0xFF42A5F5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _getGeneralAiAdvice,
                      icon: const Icon(Icons.psychology, color: Colors.white),
                      label: Text(
                        "Get General AI Advice",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPredictionResultCard(PredictionResponse response) {
    return Column(
      children: [
        // Model Info Card
        Card(
          color: Colors.blue.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Prediction Model Information",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 28),
                    Expanded(
                      child: Text(
                        "${response.modelType} • ${response.inputFeaturesUsed} comprehensive soil features analyzed",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Top Recommendation Card
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _getSuitabilityColor(response.topRecommendation.suitability), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getSuitabilityColor(response.topRecommendation.suitability),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        response.topRecommendation.suitability.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.star, color: Colors.amber.shade600, size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  response.topRecommendation.crop,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Family: ${response.topRecommendation.family}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: response.topRecommendation.overallConfidence,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getSuitabilityColor(response.topRecommendation.suitability),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  "Confidence: ${(response.topRecommendation.overallConfidence * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Alternative Recommendations
        if (response.alternativeRecommendations.isNotEmpty) ...[
          Text(
            "Alternative Recommendations",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...response.alternativeRecommendations.map((alt) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  Icons.grass,
                  color: _getSuitabilityColor(alt.suitability),
                ),
                title: Text(
                  alt.crop,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "${alt.family} • ${alt.suitability}",
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${(alt.overallConfidence * 100).toStringAsFixed(1)}%",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Color _getSuitabilityColor(String suitability) {
    switch (suitability.toLowerCase()) {
      case 'excellent':
        return Colors.green.shade600;
      case 'good':
        return Colors.lightGreen.shade600;
      case 'fair':
        return Colors.orange.shade600;
      case 'poor':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildAiAdviceCard(AiAdvice advice) {
    return Card(
      color: Colors.blueGrey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blueGrey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              advice.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              advice.summary,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blueGrey.shade700,
              ),
            ),
            const Divider(height: 24),
            if (advice.actionableSteps.isNotEmpty) ...[
              Text(
                "Actionable Steps:",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...advice.actionableSteps.map(
                (step) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                  ),
                  title: Text(step, style: GoogleFonts.poppins()),
                ),
              ),
            ],
            if (advice.thingsToAvoid.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "Things to Avoid:",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...advice.thingsToAvoid.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.highlight_off,
                    color: Colors.red.shade400,
                  ),
                  title: Text(item, style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Soil Chemistry Section
            _buildSummarySection(
              "Soil Chemistry",
              Icons.science,
              Colors.green.shade700,
              [
                _buildDataRow("Nitrogen (N)", widget.soilData.nMgKg, "mg/kg"),
                _buildDataRow("Phosphorus (P)", widget.soilData.pMgKg, "mg/kg"),
                _buildDataRow("Potassium (K)", widget.soilData.kMgKg, "mg/kg"),
                _buildDataRow("pH Level", widget.soilData.ph, ""),
                _buildDataRow("Moisture", widget.soilData.hum, "%"),
                _buildDataRow("Temperature", widget.soilData.tempC, "°C"),
                _buildDataRow("Conductivity", widget.soilData.conductivityUsCm, "µS/cm"),
                _buildDataRow("Calcium", widget.soilData.calcium, "mg/kg"),
                _buildDataRow("Magnesium", widget.soilData.magnesium, "mg/kg"),
                _buildDataRow("Sodium", widget.soilData.sodium, "mg/kg"),
                _buildDataRow("Exchangeable K", widget.soilData.exchangeableK, "mg/kg"),
                _buildDataRow("Sulfur", widget.soilData.sulfur, "mg/kg"),
                _buildDataRow("Organic Matter", widget.soilData.organicMatter, "%"),
                _buildDataRow("Copper", widget.soilData.copper, "mg/kg"),
                _buildDataRow("Zinc", widget.soilData.zinc, "mg/kg"),
                _buildDataRow("Iron", widget.soilData.iron, "mg/kg"),
                _buildDataRow("Manganese", widget.soilData.manganese, "mg/kg"),
                _buildDataRow("Boron", widget.soilData.boron, "mg/kg"),
              ],
            ),
            const Divider(height: 24),
            // Soil Properties Section
            _buildSummarySection(
              "Soil Properties",
              Icons.terrain,
              Colors.brown.shade700,
              [
                _buildDataRow("Soil Type", widget.soilData.soilType, ""),
                _buildDataRow("Texture Group", widget.soilData.soilTextureGroup, ""),
                _buildDataRow("Sand Content", widget.soilData.sandContent, "(0-3 scale)"),
                _buildDataRow("Silt Content", widget.soilData.siltContent, "(0-3 scale)"),
                _buildDataRow("Clay Content", widget.soilData.clayContent, "(0-3 scale)"),
                _buildDataRow("Existing Crops", widget.soilData.existingCrops, ""),
                _buildDataRow("Primary Crop", widget.soilData.primaryCrop, ""),
              ],
            ),
            const Divider(height: 24),
            // Location & Climate Section
            _buildSummarySection(
              "Location & Climate",
              Icons.location_on,
              Colors.blue.shade700,
              [
                _buildDataRow("Latitude", widget.soilData.latitude, "°"),
                _buildDataRow("Longitude", widget.soilData.longitude, "°"),
                _buildDataRow("Avg Temperature", widget.soilData.avgTempC, "°C"),
                _buildDataRow("Avg Humidity", widget.soilData.avgHumidity, "%"),
                _buildDataRow("Avg Precipitation", widget.soilData.avgPrecipitation, "mm/year"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(String title, IconData icon, Color color, List<Widget> rows) {
    // Filter out null rows
    final validRows = rows.where((row) => row != const SizedBox.shrink()).toList();

    if (validRows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...validRows,
      ],
    );
  }

  Widget _buildDataRow(String label, dynamic value, String unit) {
    // Handle null values
    if (value == null) return const SizedBox.shrink();

    String displayValue;
    if (value is double) {
      // For 0-3 scale values (sand, silt, clay content), show as integer
      if (unit.contains("0-3 scale") && value == value.toInt()) {
        displayValue = value.toInt().toString();
      } else {
        displayValue = value.toStringAsFixed(2);
      }
    } else if (value is String) {
      displayValue = value;
    } else {
      displayValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "$displayValue ${unit.isNotEmpty ? unit : ''}",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
