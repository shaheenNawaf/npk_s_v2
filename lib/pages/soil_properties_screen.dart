// lib/screens/soil_properties_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/soil_data.dart';
import 'widgets/app_bar.dart';
import 'results_screen.dart';

class SoilPropertiesScreen extends StatefulWidget {
  final SoilData soilData;

  const SoilPropertiesScreen({super.key, required this.soilData});

  @override
  State<SoilPropertiesScreen> createState() => _SoilPropertiesScreenState();
}

class _SoilPropertiesScreenState extends State<SoilPropertiesScreen> {
  final _formKey = GlobalKey<FormState>();
  late SoilData _soilData;

  // Dropdown options
  final List<String> _soilTypes = [
    'Beach sand',
    'Silty clay',
    'Silty clay loam',
    'Silt loam',
    'Clay',
    'Clay loam',
    'Loam',
    'Loamy sand',
    'Sandy clay loam',
    'Sandy clay',
    'Sandy loam',
    'Silt',
    'Gravelly sandy clay loam',
  ];
  final List<String> _textureGroups = [
    'Coarse-textured soils',
    'Medium-textured soils',
    'Moderately fine-textured soils',
    'Fine-textured soils',
  ];

  String? _selectedSoilType;
  String? _selectedTextureGroup;
  bool _isLoam = false;

  final TextEditingController _sandController = TextEditingController();
  final TextEditingController _siltController = TextEditingController();
  final TextEditingController _clayController = TextEditingController();
  final TextEditingController _existingCropsController =
      TextEditingController();
  final TextEditingController _primaryCropController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _soilData = widget.soilData;
  }

  @override
  void dispose() {
    _sandController.dispose();
    _siltController.dispose();
    _clayController.dispose();
    _existingCropsController.dispose();
    _primaryCropController.dispose();
    super.dispose();
  }

  void _onAnalyze() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _soilData.soilType = _selectedSoilType;
        _soilData.soilTextureGroup = _selectedTextureGroup;
        _soilData.sandContent = double.tryParse(_sandController.text);
        _soilData.siltContent = double.tryParse(_siltController.text);
        _soilData.clayContent = double.tryParse(_clayController.text);
        _soilData.isLoam = _isLoam;
        _soilData.existingCrops = _existingCropsController.text;
        _soilData.primaryCrop =
            _primaryCropController.text.isNotEmpty
                ? _primaryCropController.text
                : null;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Step 2: Soil Properties",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                "Soil Type",
                _soilTypes,
                _selectedSoilType,
                (val) => setState(() => _selectedSoilType = val),
              ),
              _buildDropdown(
                "Soil Texture Group",
                _textureGroups,
                _selectedTextureGroup,
                (val) => setState(() => _selectedTextureGroup = val),
              ),
              _buildTextField("Sand Content", "%", _sandController),
              _buildTextField("Silt Content", "%", _siltController),
              _buildTextField("Clay Content", "%", _clayController),
              SwitchListTile(
                title: Text("Is the soil loamy?", style: GoogleFonts.poppins()),
                value: _isLoam,
                onChanged: (val) => setState(() => _isLoam = val),
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Existing Crops",
                "",
                _existingCropsController,
                isOptional: true,
              ),
              _buildTextField(
                "Primary Crop (Optional)",
                "",
                _primaryCropController,
                isOptional: true,
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
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String unit,
    TextEditingController controller, {
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType:
            unit == '%'
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
