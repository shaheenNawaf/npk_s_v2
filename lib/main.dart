import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:google_generative_ai/google_generative_ai.dart';

// --- Data Model ---
class SoilData {
  final String? description;
  final DateTime? time;
  final double? tempC;
  final double? hum;
  final double? conductivityUsCm;
  final double? ph;
  final double? nMgKg;
  final double? pMgKg;
  final double? kMgKg;

  SoilData({
    this.description,
    this.time,
    this.tempC,
    this.hum,
    this.conductivityUsCm,
    this.ph,
    this.nMgKg,
    this.pMgKg,
    this.kMgKg,
  });

  factory SoilData.fromMap(Map<String, dynamic> data) {
    T? _parseValue<T>(dynamic value, T? Function(String) parser) {
      if (value == null) return null;
      if (value is T) return value;
      try {
        String stringValue;
        if (value is Data) {
          if (value.value == null) return null;
          stringValue = value.value.toString();
        } else {
          stringValue = value.toString();
        }
        return parser(stringValue);
      } catch (e) {
        print('Error parsing value $value: $e');
      }
      return null;
    }

    DateTime? parseTime(dynamic value) {
      if (value == null) return null;
      try {
        String timeString;
        if (value is Data) {
          if (value.value == null) return null;
          timeString = value.value.toString();
        } else if (value is String) {
          timeString = value;
        } else {
          timeString = value.toString();
        }
        final DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
        return format.parse(timeString);
      } catch (e) {
        print('Error parsing time $value: $e');
      }
      return null;
    }

    return SoilData(
      description: _parseValue<String>(data['description'], (s) => s),
      time: parseTime(data['time']),
      tempC: _parseValue<double>(data['temp(℃)'], (s) => double.tryParse(s)),
      hum: _parseValue<double>(data['hum(%)'], (s) => double.tryParse(s)),
      conductivityUsCm: _parseValue<double>(
        data['conductivity(us/cm)'],
        (s) => double.tryParse(s),
      ),
      ph: _parseValue<double>(data['ph'], (s) => double.tryParse(s)),
      nMgKg: _parseValue<double>(data['n(mg/kg)'], (s) => double.tryParse(s)),
      pMgKg: _parseValue<double>(data['p(mg/kg)'], (s) => double.tryParse(s)),
      kMgKg: _parseValue<double>(data['k(mg/kg)'], (s) => double.tryParse(s)),
    );
  }
}

// --- Gemini API Service ---
class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
        generationConfig: GenerationConfig(maxOutputTokens: 2000),
      );

  Future<String> getPlantRecommendations(SoilData data) async {
    final prompt = _buildPlantPrompt(data);
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          "Could not generate a response. Please try again.";
    } catch (e) {
      print("Error calling Gemini API: $e");
      return "An error occurred while getting recommendations. Please check your network and API key.";
    }
  }

  Future<String> getSoilCareAdvice(SoilData data) async {
    final prompt = _buildSoilCarePrompt(data);
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          "Could not generate a response. Please try again.";
    } catch (e) {
      print("Error calling Gemini API: $e");
      return "An error occurred while getting advice. Please check your network and API key.";
    }
  }

  String _buildPlantPrompt(SoilData data) {
    return '''
    Analyze the following soil conditions and recommend suitable plants.

    Soil Data:
    - Temperature: ${data.tempC?.toStringAsFixed(1) ?? 'N/A'} °C
    - Humidity: ${data.hum?.toStringAsFixed(1) ?? 'N/A'} %
    - pH: ${data.ph?.toStringAsFixed(2) ?? 'N/A'}
    - Nitrogen (N): ${data.nMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Phosphorus (P): ${data.pMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Potassium (K): ${data.kMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Conductivity: ${data.conductivityUsCm?.toStringAsFixed(1) ?? 'N/A'} us/cm

    Based on these conditions, what specific plants (vegetables, fruits, flowers) are most suitable for this soil? Please provide a short list with brief reasons for each recommendation.
    ''';
  }

  String _buildSoilCarePrompt(SoilData data) {
    return '''
    Provide soil care advice based on the following data.

    Current Soil State:
    - pH: ${data.ph?.toStringAsFixed(2) ?? 'N/A'}
    - Nitrogen (N): ${data.nMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Phosphorus (P): ${data.pMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Potassium (K): ${data.kMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg

    Based on this data, how can I best take care of this soil? Provide actionable steps to improve or maintain its health (e.g., what to add, what to avoid).
    ''';
  }
}

// --- Main Application ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soil Data Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SoilData? _latestSoilData;
  bool _isLoading = false;
  String? _errorMessage;
  late final GeminiService _geminiService;
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
          processedData = _processExcelData(fileBytes);
        } else if (fileExtension == '.csv') {
          processedData = await _processCsvData(fileBytes);
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

  SoilData? _processExcelData(Uint8List bytes) {
    var excel = Excel.decodeBytes(bytes);
    Sheet? sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null || sheet.maxRows <= 1) {
      throw Exception("Excel file is empty or contains no data.");
    }

    List<String> headers =
        sheet.rows.first
            .map((cell) => cell?.value.toString().trim() ?? '')
            .toList();

    DateTime? latestTime;
    SoilData? tempLatestSoilData;

    for (int i = 1; i < sheet.maxRows; i++) {
      List<Data?> row = sheet.rows[i];
      if (row.any((cell) => cell?.value != null)) {
        Map<String, dynamic> rowMap = {};
        for (int j = 0; j < headers.length; j++) {
          if (j < row.length) {
            rowMap[headers[j]] = row[j];
          }
        }
        SoilData currentRowData = SoilData.fromMap(rowMap);
        if (currentRowData.time != null) {
          if (latestTime == null || currentRowData.time!.isAfter(latestTime)) {
            latestTime = currentRowData.time;
            tempLatestSoilData = currentRowData;
          }
        }
      }
    }
    return tempLatestSoilData;
  }

  Future<SoilData?> _processCsvData(Uint8List bytes) async {
    final csvString = utf8.decode(bytes);
    final List<List<dynamic>> fields = const CsvToListConverter().convert(
      csvString,
    );

    if (fields.length <= 1) {
      throw Exception("CSV file is empty or has no data.");
    }

    final headers = fields[0].map((h) => h.toString().trim()).toList();
    final timeColumnIndex = headers.indexOf('Time');

    if (timeColumnIndex == -1) {
      throw Exception("CSV file is missing the 'Time' column.");
    }

    DateTime? latestTime;
    List<dynamic>? latestRow;

    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length > timeColumnIndex) {
        try {
          final timeString = row[timeColumnIndex].toString();
          final currentTime = DateFormat(
            "yyyy-MM-dd HH:mm:ss",
          ).parse(timeString);
          if (latestTime == null || currentTime.isAfter(latestTime)) {
            latestTime = currentTime;
            latestRow = row;
          }
        } catch (e) {
          // Ignore rows with invalid date formats
        }
      }
    }

    if (latestRow != null) {
      Map<String, dynamic> rowMap = {};
      for (int j = 0; j < headers.length; j++) {
        if (j < latestRow.length) {
          rowMap[headers[j]] = latestRow[j].toString();
        }
      }
      return SoilData.fromMap(rowMap);
    }
    return null;
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

// --- UI Widgets ---
class SoilDataCard extends StatelessWidget {
  final SoilData data;
  final bool isGeminiLoading;
  final VoidCallback onGetPlants;
  final VoidCallback onGetSoilCare;

  const SoilDataCard({
    super.key,
    required this.data,
    required this.isGeminiLoading,
    required this.onGetPlants,
    required this.onGetSoilCare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Soil Data:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            _buildDataRow('Description', data.description),
            _buildDataRow(
              'Time',
              data.time != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(data.time!)
                  : 'N/A',
            ),
            _buildDataRow(
              'Temperature',
              data.tempC != null ? '${data.tempC} °C' : 'N/A',
            ),
            _buildDataRow(
              'Humidity',
              data.hum != null ? '${data.hum} %' : 'N/A',
            ),
            _buildDataRow(
              'Conductivity',
              data.conductivityUsCm != null
                  ? '${data.conductivityUsCm} us/cm'
                  : 'N/A',
            ),
            _buildDataRow('pH', data.ph?.toStringAsFixed(2) ?? 'N/A'),
            _buildDataRow(
              'Nitrogen (N)',
              data.nMgKg != null ? '${data.nMgKg} mg/kg' : 'N/A',
            ),
            _buildDataRow(
              'Phosphorus (P)',
              data.pMgKg != null ? '${data.pMgKg} mg/kg' : 'N/A',
            ),
            _buildDataRow(
              'Potassium (K)',
              data.kMgKg != null ? '${data.kMgKg} mg/kg' : 'N/A',
            ),
            const Divider(height: 30),
            Text('AI Analysis:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (isGeminiLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onGetPlants,
                    child: const Text('Suggest Plants'),
                  ),
                  ElevatedButton(
                    onPressed: onGetSoilCare,
                    child: const Text('Get Soil Advice'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}

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
