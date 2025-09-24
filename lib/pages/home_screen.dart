import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

//For the services and basic data model
import '../models/soil_data.dart';
import '../services/gemini_service.dart';
import '../services/file_processing_service.dart';

//Inner Cards -- will revisit
import 'widgets/gemini_result_card.dart';
import 'widgets/soil_data_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SoilData? _latestSoilData;
  bool _isLoading = false;
  String? _errorMessage;
  late final GeminiService _geminiService;
  late final FileProcessingService _fileProcessingService;
  bool _isGeminiLoading = false;
  String? _geminiError;
  String? _plantRecommendation;
  String? _soilCareAdvice;

  @override
  void initState() {
    super.initState();
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      throw AssertionError(
        'GEMINI_API_KEY is not set. Please create config.json and run with --dart-define-from-file=config.json',
      );
    }
    _geminiService = GeminiService(apiKey);
    _fileProcessingService = FileProcessingService();
  }

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _latestSoilData = null;
      _plantRecommendation = null;
      _soilCareAdvice = null;
      _geminiError = null;
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
        Uint8List? fileBytes;

        if (kIsWeb) {
          fileBytes = file.bytes;
        } else {
          if (file.path != null) {
            fileBytes = await File(file.path!).readAsBytes();
          }
        }

        if (fileBytes == null) {
          throw Exception("Could not read file bytes.");
        }

        SoilData? processedData;
        if (fileExtension == '.xlsx') {
          processedData = _fileProcessingService.processExcelData(fileBytes);
        } else if (fileExtension == '.csv') {
          processedData = await _fileProcessingService.processCsvData(
            fileBytes,
          );
        } else {
          throw Exception("Unsupported file type: $fileExtension");
        }

        setState(() {
          _latestSoilData = processedData;
          if (_latestSoilData == null) {
            _errorMessage =
                "Could not find a valid row with a timestamp in the file.";
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
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getPlantRecommendations() async {
    if (_latestSoilData == null) return;
    setState(() {
      _isGeminiLoading = true;
      _geminiError = null;
      _plantRecommendation = null;
    });

    final result = await _geminiService.getPlantRecommendations(
      _latestSoilData!,
    );

    setState(() {
      _plantRecommendation = result;
      _isGeminiLoading = false;
    });
  }

  Future<void> _getSoilCareAdvice() async {
    if (_latestSoilData == null) return;
    setState(() {
      _isGeminiLoading = true;
      _geminiError = null;
      _soilCareAdvice = null;
    });

    final result = await _geminiService.getSoilCareAdvice(_latestSoilData!);

    setState(() {
      _soilCareAdvice = result;
      _isGeminiLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soil Data Analyzer')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickAndProcessFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _isLoading
                      ? 'Processing...'
                      : 'Select Data File (.xlsx, .csv)',
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              if (_latestSoilData != null)
                SoilDataCard(
                  data: _latestSoilData!,
                  onGetPlants: _getPlantRecommendations,
                  onGetSoilCare: _getSoilCareAdvice,
                  isGeminiLoading: _isGeminiLoading,
                ),

              if (_geminiError != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _geminiError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (_plantRecommendation != null)
                GeminiResultCard(
                  title: "Plant Recommendations",
                  content: _plantRecommendation!,
                ),

              if (_soilCareAdvice != null)
                GeminiResultCard(
                  title: "Soil Care Advice",
                  content: _soilCareAdvice!,
                ),

              if (!_isLoading &&
                  _latestSoilData == null &&
                  _errorMessage == null)
                const Center(
                  child: Text('No data loaded. Please select a file.'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
