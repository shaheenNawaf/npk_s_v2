import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:npk_s_v2/pages/widgets/stat_card.dart';
import '../models/soil_data.dart';
import '../models/crop_prediction.dart';
import '../models/ai_advice.dart';
import '../services/gemini_service.dart';
import '../services/prediction_service.dart';
import 'widgets/stat_card.dart';
import 'home_screen.dart';

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
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      throw AssertionError(
        'GEMINI_API_KEY is not set. Please run with --dart-define-from-file=config.json',
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
    final primaryNutrientCards = _buildPrimaryNutrientCards();
    final soilConditionCards = _buildSoilConditionCards();
    final secondaryNutrientCards = _buildSecondaryNutrientCards();
    final traceMineralCards = _buildTraceMineralCards();
    final textureCards = _buildTextureCards();
    final climateCards = _buildClimateCards();

    final Color primaryGreen = const Color.fromARGB(255, 93, 168, 115);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Column(
          children: [
            Text(
              "AGRI-SENSE",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              "IoT Smart Soil Advisor",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (primaryNutrientCards.isNotEmpty)
              _buildCollapsibleSection(
                icon: Icons.eco,
                iconColor: Colors.green,
                title: "Primary Nutrients",
                subtitle: "Key macronutrients (NPK)",
                initiallyExpanded: true,
                cards: primaryNutrientCards,
              ),
            if (soilConditionCards.isNotEmpty)
              _buildCollapsibleSection(
                icon: Icons.public,
                iconColor: Colors.blue,
                title: "Soil & Environment",
                subtitle: "Physical and environmental properties",
                cards: soilConditionCards,
              ),
            if (secondaryNutrientCards.isNotEmpty)
              _buildCollapsibleSection(
                icon: Icons.scatter_plot,
                iconColor: Colors.orange,
                title: "Secondary Nutrients",
                subtitle: "Essential secondary elements",
                cards: secondaryNutrientCards,
              ),
            if (traceMineralCards.isNotEmpty)
              _buildCollapsibleSection(
                icon: Icons.grain,
                iconColor: Colors.purple,
                title: "Trace Minerals",
                subtitle: "Important micronutrients",
                cards: traceMineralCards,
              ),
            if (textureCards.isNotEmpty)
              _buildCollapsibleSection(
                icon: Icons.texture,
                iconColor: Colors.orangeAccent,
                title: "Texture Details",
                subtitle: "Physical composition of the soil",
                cards: textureCards,
              ),
            if (climateCards.isNotEmpty)
              _buildCollapsibleSection(
                icon: Icons.thermostat,
                iconColor: Colors.redAccent,
                title: "Climate Data",
                subtitle: "Long-term environmental averages",
                cards: climateCards,
              ),

            if (_predictionResponse != null &&
                _predictionResponse!.predictions.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._predictionResponse!.predictions.map(
                (prediction) => _buildPredictionResultCard(prediction),
              ),
            ],
            if (_aiAdvice != null) ...[
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
            const SizedBox(height: 24),
            _buildActionCard(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPrimaryNutrientCards() {
    List<Widget> cards = [];
    if (widget.soilData.nMgKg != null) {
      cards.add(
        StatCard(
          title: "Nitrogen",
          value: widget.soilData.nMgKg!.toStringAsFixed(0),
          unit: "mg/kg",
          range: "Optimal: 25-50",
          rangeMin: 25,
          rangeMax: 50,
        ),
      );
    }
    if (widget.soilData.pMgKg != null) {
      cards.add(
        StatCard(
          title: "Phosphorus",
          value: widget.soilData.pMgKg!.toStringAsFixed(0),
          unit: "mg/kg",
          range: "Optimal: 30-50",
          rangeMin: 30,
          rangeMax: 50,
        ),
      );
    }
    if (widget.soilData.kMgKg != null) {
      cards.add(
        StatCard(
          title: "Potassium",
          value: widget.soilData.kMgKg!.toStringAsFixed(0),
          unit: "mg/kg",
          range: "Optimal: 100-200",
          rangeMin: 100,
          rangeMax: 200,
        ),
      );
    }
    return cards;
  }

  List<Widget> _buildSoilConditionCards() {
    List<Widget> cards = [];
    if (widget.soilData.ph != null) {
      cards.add(
        StatCard(
          title: "pH Level",
          value: widget.soilData.ph!.toStringAsFixed(1),
          unit: "",
          range: "Optimal: 6.0-7.0",
          rangeMin: 6.0,
          rangeMax: 7.0,
        ),
      );
    }
    if (widget.soilData.hum != null) {
      cards.add(
        StatCard(
          title: "Moisture",
          value: widget.soilData.hum!.toStringAsFixed(0),
          unit: "%",
          range: "Optimal: 40-60",
          rangeMin: 40,
          rangeMax: 60,
        ),
      );
    }
    if (widget.soilData.tempC != null) {
      cards.add(
        StatCard(
          title: "Temperature",
          value: widget.soilData.tempC!.toStringAsFixed(1),
          unit: "°C",
          range: "Optimal: 18-24",
          rangeMin: 18,
          rangeMax: 24,
        ),
      );
    }
    if (widget.soilData.conductivityUsCm != null) {
      cards.add(
        StatCard(
          title: "Conductivity",
          value: widget.soilData.conductivityUsCm!.toStringAsFixed(2),
          unit: "dS/m",
          range: "Optimal: 0-2",
          rangeMin: 0,
          rangeMax: 2,
        ),
      );
    }
    return cards;
  }

  List<Widget> _buildSecondaryNutrientCards() {
    List<Widget> cards = [];
    if (widget.soilData.calcium != null) {
      cards.add(
        StatCard(
          title: "Calcium",
          value: widget.soilData.calcium!.toStringAsFixed(0),
          unit: "mg/kg",
          range: "Optimal: 1000-2000",
          rangeMin: 1000,
          rangeMax: 2000,
        ),
      );
    }
    if (widget.soilData.magnesium != null) {
      cards.add(
        StatCard(
          title: "Magnesium",
          value: widget.soilData.magnesium!.toStringAsFixed(0),
          unit: "mg/kg",
          range: "Optimal: 100-300",
          rangeMin: 100,
          rangeMax: 300,
        ),
      );
    }
    if (widget.soilData.sodium != null) {
      cards.add(
        StatCard(
          title: "Sodium",
          value: widget.soilData.sodium!.toStringAsFixed(0),
          unit: "mg/kg",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 200,
        ),
      );
    }
    if (widget.soilData.sulfur != null) {
      cards.add(
        StatCard(
          title: "Sulfur",
          value: widget.soilData.sulfur!.toStringAsFixed(0),
          unit: "mg/kg",
          range: "Optimal: 10-20",
          rangeMin: 10,
          rangeMax: 20,
        ),
      );
    }
    if (widget.soilData.exchangeableK != null) {
      cards.add(
        StatCard(
          title: "Exchange. K",
          value: widget.soilData.exchangeableK!.toStringAsFixed(2),
          unit: "meq/100g",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 1,
        ),
      );
    }
    return cards;
  }

  List<Widget> _buildTraceMineralCards() {
    List<Widget> cards = [];
    if (widget.soilData.copper != null) {
      cards.add(
        StatCard(
          title: "Copper",
          value: widget.soilData.copper!.toStringAsFixed(1),
          unit: "mg/kg",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 10,
        ),
      );
    }
    if (widget.soilData.zinc != null) {
      cards.add(
        StatCard(
          title: "Zinc",
          value: widget.soilData.zinc!.toStringAsFixed(1),
          unit: "mg/kg",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 10,
        ),
      );
    }
    if (widget.soilData.iron != null) {
      cards.add(
        StatCard(
          title: "Iron",
          value: widget.soilData.iron!.toStringAsFixed(1),
          unit: "mg/kg",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 50,
        ),
      );
    }
    if (widget.soilData.manganese != null) {
      cards.add(
        StatCard(
          title: "Manganese",
          value: widget.soilData.manganese!.toStringAsFixed(1),
          unit: "mg/kg",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 50,
        ),
      );
    }
    if (widget.soilData.boron != null) {
      cards.add(
        StatCard(
          title: "Boron",
          value: widget.soilData.boron!.toStringAsFixed(1),
          unit: "mg/kg",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 2,
        ),
      );
    }
    return cards;
  }

  List<Widget> _buildTextureCards() {
    List<Widget> cards = [];
    if (widget.soilData.sandContent != null) {
      cards.add(
        StatCard(
          title: "Sand",
          value: widget.soilData.sandContent!.toStringAsFixed(0),
          unit: "%",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 100,
        ),
      );
    }
    if (widget.soilData.siltContent != null) {
      cards.add(
        StatCard(
          title: "Silt",
          value: widget.soilData.siltContent!.toStringAsFixed(0),
          unit: "%",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 100,
        ),
      );
    }
    if (widget.soilData.clayContent != null) {
      cards.add(
        StatCard(
          title: "Clay",
          value: widget.soilData.clayContent!.toStringAsFixed(0),
          unit: "%",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 100,
        ),
      );
    }
    return cards;
  }

  List<Widget> _buildClimateCards() {
    List<Widget> cards = [];
    if (widget.soilData.avgTempC != null) {
      cards.add(
        StatCard(
          title: "Avg Temp",
          value: widget.soilData.avgTempC!.toStringAsFixed(1),
          unit: "°C",
          range: "Varies",
          rangeMin: -50,
          rangeMax: 50,
        ),
      );
    }
    if (widget.soilData.avgHumidity != null) {
      cards.add(
        StatCard(
          title: "Avg Humidity",
          value: widget.soilData.avgHumidity!.toStringAsFixed(0),
          unit: "%",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 100,
        ),
      );
    }
    if (widget.soilData.avgPrecipitation != null) {
      cards.add(
        StatCard(
          title: "Avg Precip.",
          value: widget.soilData.avgPrecipitation!.toStringAsFixed(0),
          unit: "mm/yr",
          range: "Varies",
          rangeMin: 0,
          rangeMax: 10000,
        ),
      );
    }
    return cards;
  }

  Widget _buildCollapsibleSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Widget> cards,
    bool initiallyExpanded = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: cards,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    bool isAnyActionLoading = _isPredicting || _isGettingAdvice;
    final Color primaryGreen = const Color.fromARGB(255, 93, 168, 115);

    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.psychology,
                color: Colors.deepPurpleAccent,
                size: 32,
              ),
              title: Text(
                "Next Steps",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                "Use our AI models for recommendations",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            const Divider(height: 24),
            isAnyActionLoading
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                : Column(
                  children: [
                    ElevatedButton(
                      onPressed: _predictBestCrop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Predict Best Crop",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _getGeneralAiAdvice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Get General AI Advice",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

  Widget _buildPredictionResultCard(CropPrediction prediction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.auto_awesome,
                color: Colors.amber,
                size: 32,
              ),
              title: Text(
                "Custom Model Prediction",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                "Results from your trained model",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            const Divider(height: 24),
            Text(
              "Predicted Family: ${prediction.cropFamily}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Confidence: ${(prediction.familyConfidence * 100).toStringAsFixed(1)}%",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Top Recommendations:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...prediction.topCrops.map(
              (crop) => ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: const Icon(Icons.grass, color: Colors.green),
                title: Text(crop.specificCrop, style: GoogleFonts.poppins()),
                trailing: Text(
                  "${(crop.confidence * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAdviceCard(AiAdvice advice) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.lightbulb_outline,
                color: Colors.blue.shade400,
                size: 32,
              ),
              title: Text(
                "General AI Advice",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                "Powered by Gemini",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            const Divider(height: 24),
            Text(
              advice.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
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
            if (advice.actionableSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "Actionable Steps:",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...advice.actionableSteps.map(
                (step) => ListTile(
                  contentPadding: const EdgeInsets.only(left: 0, top: 4),
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  title: Text(step, style: GoogleFonts.poppins()),
                  minLeadingWidth: 20,
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
              ...advice.thingsToAvoid.map(
                (item) => ListTile(
                  contentPadding: const EdgeInsets.only(left: 0, top: 4),
                  leading: Icon(
                    Icons.highlight_off,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  title: Text(item, style: GoogleFonts.poppins()),
                  minLeadingWidth: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
