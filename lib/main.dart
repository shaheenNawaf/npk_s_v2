import 'dart:io';
import 'dart:convert'; // Required for utf8.decode (for CSV)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p; // For getting file extension

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
        return null;
      }
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soil Data App',
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

  // NEW: Unified file picking and processing function
  Future<void> _pickAndProcessFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _latestSoilData = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'], // Allow both file types
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

  // NEW: Refactored Excel processing logic
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

  // NEW: Added CSV processing logic
  Future<SoilData?> _processCsvData(Uint8List bytes) async {
    final csvString = utf8.decode(bytes);
    final List<List<dynamic>> fields = const CsvToListConverter().convert(
      csvString,
    );

    if (fields.length <= 1) {
      throw Exception("CSV file is empty or has no data.");
    }

    final headers = fields[0].map((h) => h.toString().trim()).toList();
    final timeColumnIndex = headers.indexOf('time');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soil Data Analyzer')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                // UPDATED: Calls the new unified function
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
                  child: CircularProgressIndicator(),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: SoilDataCard(data: _latestSoilData!),
                  ),
                )
              else if (!_isLoading && _errorMessage == null)
                const Text('No data loaded. Please select a file.'),
            ],
          ),
        ),
      ),
    );
  }
}

// The SoilDataCard widget remains unchanged
class SoilDataCard extends StatelessWidget {
  // ... (No changes here, the widget is the same as the last version)
  final SoilData data;

  const SoilDataCard({super.key, required this.data});

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
              'Date & Time',
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
            width: 120, // Align labels
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
