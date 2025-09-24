import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

import '../models/soil_data.dart';
import '../models/crop_prediction.dart';
import '../services/file_processing_service.dart';
import '../services/gemini_service.dart';
import '../services/prediction_service.dart';
import 'widgets/app_bar.dart';
import 'widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SoilData? _soilData;
  bool _isLoadingFile = false;
  String? _errorMessage;

  late final GeminiService _geminiService;
  late final FileProcessingService _fileProcessingService;
  late final PredictionService _predictionService;

  bool _isPredicting = false;
  bool _isGettingAdvice = false;
  CropPrediction? _cropPrediction; // For the TF/LLM Crop Recommendation
  String? _aiAdvice;

  @override
  void initState() {
    super.initState();
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      throw AssertionError(
        'GEMINI_API_KEY is not set. Run with --dart-define-from-file=config.json',
      );
    }
    _geminiService = GeminiService(apiKey);
    _fileProcessingService = FileProcessingService();
    _predictionService = PredictionService();
  }

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _isLoadingFile = true;
      _errorMessage = null;
      _soilData = null;
      _cropPrediction = null;
      _aiAdvice = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        withData: true,
      );

      if (result != null) {
        final file = result.files.first;
        final fileExtension = p.extension(file.name).toLowerCase();
        Uint8List? fileBytes =
            kIsWeb ? file.bytes : await File(file.path!).readAsBytes();

        if (fileBytes == null) throw Exception("Could not read file bytes.");

        SoilData? processedData;
        if (fileExtension == '.xlsx') {
          processedData = _fileProcessingService.processExcelData(fileBytes);
        } else if (fileExtension == '.csv') {
          processedData = await _fileProcessingService.processCsvData(
            fileBytes,
          );
        } else {
          throw Exception("Unsupported file type.");
        }

        setState(() {
          _soilData = processedData;
          if (_soilData == null) {
            _errorMessage = "Could not find a valid row in the file.";
          }
        });
      } else {
        setState(() {
          _errorMessage = "File selection cancelled.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoadingFile = false;
      });
    }
  }

  Future<void> _predictBestCrop() async {
    if (_soilData == null) return;
    setState(() {
      _isPredicting = true;
      _errorMessage = null;
      _cropPrediction = null;
    });

    try {
      final result = await _predictionService.predictCrop(_soilData!);
      setState(() {
        _cropPrediction = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isPredicting = false;
      });
    }
  }

  Future<void> _getGeneralAiAdvice() async {
    if (_soilData == null) return;
    setState(() {
      _isGettingAdvice = true;
      _errorMessage = null;
      _aiAdvice = null;
    });

    final result = await _geminiService.getSoilCareAdvice(_soilData!);

    setState(() {
      _aiAdvice = result;
      _isGettingAdvice = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _soilData == null ? _buildWaitingView() : _buildResultsView(),
    );
  }

  Widget _buildWaitingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child:
                        _isLoadingFile
                            ? CircularProgressIndicator(
                              strokeWidth: 6,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            )
                            : Container(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Waiting for Sensor",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Place the sensor in the soil, or select a data file to begin.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoadingFile ? null : _pickAndProcessFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isLoadingFile ? "Processing..." : "Open File",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {}, // Placeholder for manual input
              child: Text(
                "Input Manually",
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    bool isAnyActionLoading = _isPredicting || _isGettingAdvice;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Soil Analysis Complete"),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                StatCard(
                  title: "Potassium",
                  value: _soilData?.kMgKg?.toStringAsFixed(0) ?? 'N/A',
                  unit: "mg/kg",
                  range: "Range: 0-3000 (Optimal: 200-400)",
                ),
                StatCard(
                  title: "Phosphorus",
                  value: _soilData?.pMgKg?.toStringAsFixed(0) ?? 'N/A',
                  unit: "mg/kg",
                  range: "Range: 0-200 (Optimal: 15-50)",
                ),
                StatCard(
                  title: "Nitrogen",
                  value: _soilData?.nMgKg?.toStringAsFixed(0) ?? 'N/A',
                  unit: "mg/kg",
                  range: "Range: 0-300 (Optimal: 15-40)",
                ),
                StatCard(
                  title: "Moisture",
                  value: _soilData?.hum?.toStringAsFixed(0) ?? 'N/A',
                  unit: "%",
                  range: "Range: 0-100% (Optimal: 30-60%)",
                ),
                StatCard(
                  title: "pH Level",
                  value: _soilData?.ph?.toStringAsFixed(1) ?? 'N/A',
                  unit: "",
                  range: "Optimal Range: 5.5-7.5)",
                ),
              ],
            ),

            if (_cropPrediction != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle("Custom Model Prediction"),
              const SizedBox(height: 16),
              _buildPredictionResultCard(_cropPrediction!),
            ],

            if (_aiAdvice != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle("General AI Advice"),
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(_aiAdvice!),
                ),
              ),
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _predictBestCrop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
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
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Family: ${prediction.cropFamily}",
              style: GoogleFonts.poppins(
                fontSize: 18,
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
            const Divider(height: 24),
            Text(
              "Top Recommendations:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...prediction.topCrops.map(
              (crop) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grass, color: Colors.green),
                title: Text(crop.specificCrop, style: GoogleFonts.poppins()),
                trailing: Text(
                  "${(crop.confidence * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
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
}
