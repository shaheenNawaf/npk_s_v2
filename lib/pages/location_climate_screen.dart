// lib/screens/location_climate_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/soil_data.dart';
import '../services/climate_service.dart';
import 'widgets/app_bar.dart';
import 'results_screen.dart';

class LocationClimateScreen extends StatefulWidget {
  final SoilData soilData;

  const LocationClimateScreen({super.key, required this.soilData});

  @override
  State<LocationClimateScreen> createState() => _LocationClimateScreenState();
}

class _LocationClimateScreenState extends State<LocationClimateScreen> {
  final _formKey = GlobalKey<FormState>();
  late SoilData _soilData;
  final ClimateService _climateService = ClimateService();

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _precipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _soilData = widget.soilData;
    _fetchDataAndPopulateFields();
  }

  Future<void> _fetchDataAndPopulateFields() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Step 1: Get Location
      final position = await _climateService.getCurrentLocation();
      _latController.text = position.latitude.toStringAsFixed(4);
      _lonController.text = position.longitude.toStringAsFixed(4);

      // Step 2: Get Climate Data from NASA POWER API
      final climateData = await _climateService.fetchClimateData(
        position.latitude,
        position.longitude,
      );
      _tempController.text = climateData['avgTempC']!.toStringAsFixed(1);
      _humidityController.text = climateData['avgHumidity']!.toStringAsFixed(1);
      _precipController.text = climateData['avgPrecipitation']!.toStringAsFixed(
        0,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _tempController.dispose();
    _humidityController.dispose();
    _precipController.dispose();
    super.dispose();
  }

  void _onAnalyze() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _soilData.latitude = double.tryParse(_latController.text);
        _soilData.longitude = double.tryParse(_lonController.text);
        _soilData.avgTempC = double.tryParse(_tempController.text);
        _soilData.avgHumidity = double.tryParse(_humidityController.text);
        _soilData.avgPrecipitation = double.tryParse(_precipController.text);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(soilData: _soilData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildFormView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            "Fetching location & climate data...",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step 3: Location and Climate",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(
                "Could not auto-fetch data: $_errorMessage\nPlease enter values manually.",
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
            ],
            _buildTextField("Latitude", "(-90 to 90)", _latController),
            _buildTextField("Longitude", "(-180 to 180)", _lonController),
            _buildTextField("Average Temperature", "°C", _tempController),
            _buildTextField("Average Humidity", "%", _humidityController),
            _buildTextField(
              "Average Precipitation",
              "mm/year",
              _precipController,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _onAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Analyze Soil",
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

  Widget _buildTextField(
    String label,
    String unit,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}
