//Libraries nigga

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

//App Imports
import '../models/soil_data.dart';
import '../services/file_processing_service.dart';
import '../services/gemini_service.dart';
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
  bool _isGeminiLoading = false;
  String? _cropRecommendation;

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
  }

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _isLoadingFile = true;
      _errorMessage = null;
      _soilData = null;
      _cropRecommendation = null;
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

  Future<void> _getRecommendations() async {
    if (_soilData == null) return;
    setState(() {
      _isGeminiLoading = true;
      _cropRecommendation = null;
    });

    final result = await _geminiService.getPlantRecommendations(_soilData!);

    setState(() {
      _cropRecommendation = result;
      _isGeminiLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _soilData == null ? _buildWaitingView() : _buildResultsView(),
    );
  }

  //Waiting for Sensor
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
              onPressed: () {},
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

  /// Soil Analysis Complete Screen
  Widget _buildResultsView() {
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
            const SizedBox(height: 24),

            _buildSectionTitle("✨ AI Recommendations"),
            const SizedBox(height: 16),
            if (_cropRecommendation != null)
              Card(
                color: Colors.green.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(_cropRecommendation!),
                ),
              ),

            if (_isGeminiLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isGeminiLoading ? null : _getRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "🤖 Get Crop Recommendations",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
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
