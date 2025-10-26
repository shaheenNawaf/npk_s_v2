import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

import '../models/soil_data.dart';
import '../services/file_processing_service.dart';
import 'widgets/app_bar.dart';
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

        if (processedData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SoilChemistryScreen(initialData: processedData!),
            ),
          );
        } else {
          throw Exception("Could not find a valid row in the file.");
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Choose an Input Method",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildInputButton(
                icon: Icons.sensors,
                label: "Connect to Sensor",
                onPressed: () {
                  /* Placeholder for sensor logic */
                },
              ),
              const SizedBox(height: 20),
              _buildInputButton(
                icon: Icons.edit_document,
                label: "Input Manually",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              SoilChemistryScreen(initialData: SoilData()),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildInputButton(
                icon: Icons.upload_file,
                label: _isLoadingFile ? "Processing..." : "Open Data File",
                onPressed: _isLoadingFile ? null : _openDataFile,
                child:
                    _isLoadingFile
                        ? const CircularProgressIndicator(color: Colors.white)
                        : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
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
    );
  }

  Widget _buildInputButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    Widget? child,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      //child: child,
    );
  }
}
