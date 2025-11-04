import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:npk_s_v2/pages/sensor_screen.dart';
import 'package:path/path.dart' as p;

import '../models/soil_data.dart';
import '../services/file_processing_service.dart';
import '../services/prediction_service.dart';
import 'soil_chemistry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingFile = false;
  String? _errorMessage;
  final FileProcessingService _fileProcessingService = FileProcessingService();
  final PredictionService _predictionService = PredictionService();

  bool _isCheckingBackend = true;
  bool _backendHealthy = false;
  String _backendMessage = 'Checking backend connection...';

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    setState(() {
      _isCheckingBackend = true;
      _backendMessage = 'Checking backend connection...';
    });

    final healthCheck = await _predictionService.checkHealth();

    if (mounted) {
      setState(() {
        _isCheckingBackend = false;
        _backendHealthy = healthCheck['status'] as bool;
        _backendMessage = healthCheck['message'] as String;
      });
    }
  }

  Future<void> _openDataFile() async {
    setState(() {
      _isLoadingFile = true;
      _errorMessage = null;
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

        SoilData? processedData =
            fileExtension == '.xlsx'
                ? _fileProcessingService.processExcelData(fileBytes)
                : await _fileProcessingService.processCsvData(fileBytes);

        if (processedData != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SoilChemistryScreen(initialData: processedData),
            ),
          );
        } else {
          throw Exception("Could not find valid data in the file.");
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFile = false;
        });
      }
    }
  }

  void _enterManually() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SoilChemistryScreen(initialData: SoilData()),
      ),
    );
  }

  void _connectSensor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SensorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color.fromARGB(255, 93, 168, 115);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //Curved Eme
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              color: primaryGreen,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.40,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("🌱", style: TextStyle(fontSize: 55)),
                              const SizedBox(width: 12),
                              Text(
                                "AGRI-SENSE",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              "Personalized crop recommendations based on your soil analysis and environmental data",
                              textAlign: TextAlign.start,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  // Backend Health Status Indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _isCheckingBackend
                              ? Colors.blue.shade50
                              : _backendHealthy
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _isCheckingBackend
                                ? Colors.blue.shade200
                                : _backendHealthy
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_isCheckingBackend)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue.shade700,
                            ),
                          )
                        else
                          Icon(
                            _backendHealthy ? Icons.check_circle : Icons.error,
                            color:
                                _backendHealthy
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                            size: 20,
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _backendMessage,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  _isCheckingBackend
                                      ? Colors.blue.shade900
                                      : _backendHealthy
                                      ? Colors.green.shade900
                                      : Colors.red.shade900,
                            ),
                          ),
                        ),
                        if (!_isCheckingBackend)
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              size: 18,
                              color:
                                  _backendHealthy
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                            ),
                            onPressed: _checkBackendHealth,
                            tooltip: 'Retry connection',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Choose an Input Method",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "How would you like to share your data?",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _InputMethodButton(
                    title: "Connect Your Sensor",
                    subtitle: "Real-time soil data via IoT device",
                    icon: Icons.sensors,
                    onTap: _connectSensor,
                    color: primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  _InputMethodButton(
                    title: "Enter Data Manually",
                    subtitle: "Input your soil parameters by hand",
                    icon: Icons.edit_note,
                    onTap: _enterManually,
                    color: primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  _InputMethodButton(
                    title: "Upload Data File",
                    subtitle: "Import from existing test results",
                    icon: Icons.upload_file,
                    onTap: _isLoadingFile ? null : _openDataFile,
                    isLoading: _isLoadingFile,
                    color: primaryGreen,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _InputMethodButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color color;

  const _InputMethodButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
