import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/soil_data.dart';
import '../services/climate_service.dart';
import '../services/mock_data_service.dart';
import 'widgets/form_app_bar.dart';
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
      final position = await _climateService.getCurrentLocation();
      _latController.text = position.latitude.toStringAsFixed(4);
      _lonController.text = position.longitude.toStringAsFixed(4);

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

  void _useTypicalValues() {
    final mockData = MockDataService.getMockSoilData();
    setState(() {
      _latController.text = mockData.latitude?.toStringAsFixed(4) ?? '';
      _lonController.text = mockData.longitude?.toStringAsFixed(4) ?? '';
      _tempController.text = mockData.avgTempC?.toStringAsFixed(1) ?? '';
      _humidityController.text = mockData.avgHumidity?.toStringAsFixed(1) ?? '';
      _precipController.text =
          mockData.avgPrecipitation?.toStringAsFixed(0) ?? '';
    });
  }

  Future<void> _useMockLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use Manila, Philippines as mock location
      final mockData = MockDataService.getMockSoilData();
      final latitude = mockData.latitude!;
      final longitude = mockData.longitude!;

      _latController.text = latitude.toStringAsFixed(4);
      _lonController.text = longitude.toStringAsFixed(4);

      // Fetch real climate data from NASA API for this mock location
      final climateData = await _climateService.fetchClimateData(
        latitude,
        longitude,
      );
      _tempController.text = climateData['avgTempC']!.toStringAsFixed(1);
      _humidityController.text = climateData['avgHumidity']!.toStringAsFixed(1);
      _precipController.text = climateData['avgPrecipitation']!.toStringAsFixed(
        0,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mock location loaded: Manila, Philippines (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})',
            ),
            backgroundColor: const Color.fromARGB(255, 93, 168, 115),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      // If NASA API fails, just use the mock values
      _useTypicalValues();
    }
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(soilData: _soilData),
        ),
        (Route<dynamic> route) => false, //clears previous data btw
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FormAppBar(
        title: "AGRI-SENSE",
        subtitle: "Personalized Crop Recommendations",
        progress: 3 / 3,
      ),
      backgroundColor: Colors.white,
      body: _isLoading ? _buildLoadingView() : _buildFormView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 93, 168, 115),
            ),
            const SizedBox(height: 20),
            Text(
              "Fetching location & climate data...",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Taking too long?",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _useMockLocation,
              icon: const Icon(Icons.location_city, size: 18),
              label: const Text("Use Mock Location (Manila)"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF7E57C2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
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
              "Location & Climate",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We've automatically fetched your local data. You can adjust the values if needed.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "Could not auto-fetch data",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _useMockLocation,
                    icon: const Icon(Icons.location_city, size: 18),
                    label: const Text("Use Mock Location"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF7E57C2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _useTypicalValues,
                    icon: const Icon(Icons.science_outlined, size: 18),
                    label: const Text("Use Test Values"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF7E57C2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionCard(
              icon: Icons.location_on,
              iconColor: Colors.redAccent,
              title: "Geographic & Climate Data",
              subtitle: "Auto-fetched from your device & NASA POWER",
              fields: [
                _buildTextField(
                  label: "Latitude",
                  hint: "-90 to 90",
                  unit: "°",
                  controller: _latController,
                ),
                _buildTextField(
                  label: "Longitude",
                  hint: "-180 to 180",
                  unit: "°",
                  controller: _lonController,
                ),
                _buildTextField(
                  label: "Average Temperature",
                  hint: "e.g., 27",
                  unit: "°C",
                  controller: _tempController,
                ),
                _buildTextField(
                  label: "Average Humidity",
                  hint: "e.g., 80",
                  unit: "%",
                  controller: _humidityController,
                ),
                _buildTextField(
                  label: "Average Precipitation",
                  hint: "e.g., 2000",
                  unit: "mm/year",
                  controller: _precipController,
                ),
              ],
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _onAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 93, 168, 115),
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

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Widget> fields,
  }) {
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
              leading: Icon(icon, color: iconColor, size: 32),
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            const Divider(height: 24),
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String unit,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Text(
                  unit,
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 93, 168, 115),
                  width: 2,
                ),
              ),
            ),
            validator:
                (value) =>
                    (value == null || value.isEmpty)
                        ? 'This field is required'
                        : null,
          ),
        ],
      ),
    );
  }
}
