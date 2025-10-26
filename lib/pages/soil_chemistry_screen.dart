// lib/screens/soil_chemistry_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/soil_data.dart';
import 'widgets/app_bar.dart';
import 'soil_properties_screen.dart';

class SoilChemistryScreen extends StatefulWidget {
  final SoilData initialData;

  const SoilChemistryScreen({super.key, required this.initialData});

  @override
  State<SoilChemistryScreen> createState() => _SoilChemistryScreenState();
}

class _SoilChemistryScreenState extends State<SoilChemistryScreen> {
  final _formKey = GlobalKey<FormState>();
  late SoilData _soilData;

  // A map to hold all our text editing controllers
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _soilData = widget.initialData;

    // Initialize controllers with initial data
    _controllers['nMgKg'] = TextEditingController(
      text: _soilData.nMgKg?.toString() ?? '',
    );
    _controllers['pMgKg'] = TextEditingController(
      text: _soilData.pMgKg?.toString() ?? '',
    );
    _controllers['kMgKg'] = TextEditingController(
      text: _soilData.kMgKg?.toString() ?? '',
    );
    _controllers['ph'] = TextEditingController(
      text: _soilData.ph?.toString() ?? '',
    );
    _controllers['hum'] = TextEditingController(
      text: _soilData.hum?.toString() ?? '',
    );
    _controllers['tempC'] = TextEditingController(
      text: _soilData.tempC?.toString() ?? '',
    );
    _controllers['conductivityUsCm'] = TextEditingController(
      text: _soilData.conductivityUsCm?.toString() ?? '',
    );
    _controllers['calcium'] = TextEditingController(
      text: _soilData.calcium?.toString() ?? '',
    );
    _controllers['magnesium'] = TextEditingController(
      text: _soilData.magnesium?.toString() ?? '',
    );
    _controllers['sodium'] = TextEditingController(
      text: _soilData.sodium?.toString() ?? '',
    );
    _controllers['exchangeableK'] = TextEditingController(
      text: _soilData.exchangeableK?.toString() ?? '',
    );
    _controllers['sulfur'] = TextEditingController(
      text: _soilData.sulfur?.toString() ?? '',
    );
    _controllers['organicMatter'] = TextEditingController(
      text: _soilData.organicMatter?.toString() ?? '',
    );
    _controllers['copper'] = TextEditingController(
      text: _soilData.copper?.toString() ?? '',
    );
    _controllers['zinc'] = TextEditingController(
      text: _soilData.zinc?.toString() ?? '',
    );
    _controllers['iron'] = TextEditingController(
      text: _soilData.iron?.toString() ?? '',
    );
    _controllers['manganese'] = TextEditingController(
      text: _soilData.manganese?.toString() ?? '',
    );
    _controllers['boron'] = TextEditingController(
      text: _soilData.boron?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    // Dispose all controllers to free up resources
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      // Update the SoilData object with values from the controllers
      setState(() {
        _soilData.nMgKg = double.tryParse(_controllers['nMgKg']!.text);
        _soilData.pMgKg = double.tryParse(_controllers['pMgKg']!.text);
        _soilData.kMgKg = double.tryParse(_controllers['kMgKg']!.text);
        _soilData.ph = double.tryParse(_controllers['ph']!.text);
        _soilData.hum = double.tryParse(_controllers['hum']!.text);
        _soilData.tempC = double.tryParse(_controllers['tempC']!.text);
        _soilData.conductivityUsCm = double.tryParse(
          _controllers['conductivityUsCm']!.text,
        );
        _soilData.calcium = double.tryParse(_controllers['calcium']!.text);
        _soilData.magnesium = double.tryParse(_controllers['magnesium']!.text);
        _soilData.sodium = double.tryParse(_controllers['sodium']!.text);
        _soilData.exchangeableK = double.tryParse(
          _controllers['exchangeableK']!.text,
        );
        _soilData.sulfur = double.tryParse(_controllers['sulfur']!.text);
        _soilData.organicMatter = double.tryParse(
          _controllers['organicMatter']!.text,
        );
        _soilData.copper = double.tryParse(_controllers['copper']!.text);
        _soilData.zinc = double.tryParse(_controllers['zinc']!.text);
        _soilData.iron = double.tryParse(_controllers['iron']!.text);
        _soilData.manganese = double.tryParse(_controllers['manganese']!.text);
        _soilData.boron = double.tryParse(_controllers['boron']!.text);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SoilPropertiesScreen(soilData: _soilData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Step 1: Soil Chemistry",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Nitrogen (N)', 'mg/kg', _controllers['nMgKg']!),
              _buildTextField(
                'Phosphorus (P)',
                'mg/kg',
                _controllers['pMgKg']!,
              ),
              _buildTextField('Potassium (K)', 'mg/kg', _controllers['kMgKg']!),
              _buildTextField('pH Level', '', _controllers['ph']!),
              _buildTextField('Moisture', '%', _controllers['hum']!),
              _buildTextField('Temperature', '°C', _controllers['tempC']!),
              _buildTextField(
                'Conductivity',
                'us/cm',
                _controllers['conductivityUsCm']!,
              ),
              _buildTextField(
                'Calcium (Ca)',
                'mg/kg',
                _controllers['calcium']!,
              ),
              _buildTextField(
                'Magnesium (Mg)',
                'mg/kg',
                _controllers['magnesium']!,
              ),
              _buildTextField('Sodium (Na)', 'mg/kg', _controllers['sodium']!),
              _buildTextField(
                'Exchangeable K',
                'meq/100g',
                _controllers['exchangeableK']!,
              ),
              _buildTextField('Sulfur (S)', 'mg/kg', _controllers['sulfur']!),
              _buildTextField(
                'Organic Matter (OM)',
                '%',
                _controllers['organicMatter']!,
              ),
              _buildTextField('Copper (Cu)', 'mg/kg', _controllers['copper']!),
              _buildTextField('Zinc (Zn)', 'mg/kg', _controllers['zinc']!),
              _buildTextField('Iron (Fe)', 'mg/kg', _controllers['iron']!),
              _buildTextField(
                'Manganese (Mn)',
                'mg/kg',
                _controllers['manganese']!,
              ),
              _buildTextField('Boron (B)', 'mg/kg', _controllers['boron']!),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Next",
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
      ),
    );
  }
}
