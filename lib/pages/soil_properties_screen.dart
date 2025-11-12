import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:npk_s_v2/pages/results_screen.dart';

import '../models/soil_data.dart';
import '../services/mock_data_service.dart';
import 'widgets/form_app_bar.dart';
import 'widgets/soil_guide_modal.dart';

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
    'Unknown',
    'Sand',
    'Loamy Sand',
    'Sandy Loam',
    'Sandy Clay Loam',
    'Loam',
    'Silt Loam',
    'Silt',
    'Clay Loam',
    'Clay',
    'Silty Clay',
    'Sandy Clay',
    'Silty Clay Loam'
        'Peat',
  ];
  final List<Map<String, String>> _textureGroups = [
    {'name': 'Unknown', 'description': 'Not yet determined'},
    {
      'name': 'Coarse',
      'description': 'Sandy soils - loose, gritty texture, drains quickly',
    },
    {
      'name': 'Medium',
      'description': 'Loamy soils - balanced mixture, ideal for most crops',
    },
    {
      'name': 'Fine',
      'description':
          'Clay-heavy soils - smooth, sticky when wet, holds water well',
    },
    {
      'name': 'Organic',
      'description': 'Peat soils - high organic matter, very water retentive',
    },
  ];

  String? _selectedSoilType;
  String? _selectedTextureGroup;

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

  void _useTypicalValues() {
    final mockData = MockDataService.getMockSoilData();
    setState(() {
      _selectedSoilType = mockData.soilType;
      _existingCropsController.text = mockData.existingCrops ?? '';
      _primaryCropController.text = mockData.primaryCrop ?? '';
    });
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _soilData.soilType = _selectedSoilType;
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
      appBar: const FormAppBar(
        title: "AGRI-SENSE",
        subtitle: "Personalized Crop Recommendations",
        progress: 2 / 2,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Soil Properties",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _useTypicalValues,
                icon: const Icon(Icons.science_outlined, size: 18),
                label: const Text("Use Typical Values for Testing"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF7E57C2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionCard(
                icon: Icons.terrain,
                iconColor: Colors.brown,
                title: "Soil Composition",
                subtitle: "Define the soil's classification",
                trailing: IconButton(
                  onPressed: () => _showSoilGuideModal(context),
                  icon: const Icon(Icons.help_outline, color: Colors.blue),
                ),
                fields: [
                  _buildDropdown(
                    "Soil Type",
                    "Select a soil type",
                    _soilTypes,
                    _selectedSoilType,
                    (val) => setState(() => _selectedSoilType = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                icon: Icons.history,
                iconColor: Colors.purple,
                title: "Crop History",
                subtitle: "Information about previous or current crops",
                fields: [
                  _buildTextField(
                    label: "Existing Crops",
                    hint: "e.g., Corn, Wheat",
                    unit: "",
                    controller: _existingCropsController,
                    isOptional: true,
                    isNumeric: false,
                  ),
                  _buildTextField(
                    label: "Primary Crop",
                    hint: "e.g., Rice",
                    unit: "",
                    controller: _primaryCropController,
                    isOptional: true,
                    isNumeric: false,
                  ),
                ],
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 93, 168, 115),
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

  void _showSoilGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SoilGuideModal(),
    );
  }

  // Reusable helper widgets for consistent styling
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Widget> fields,
    Widget? trailing, //For the icon modal trigger ito et
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
              trailing: trailing,
            ),
            const Divider(height: 24),
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String hint,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
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
          DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: onChanged,
            hint: Text(
              hint,
              style: GoogleFonts.poppins(color: Colors.grey.shade400),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
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
            items:
                items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
            validator:
                (value) => value == null ? 'Please select an option' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String unit,
    required TextEditingController controller,
    bool isOptional = false,
    bool isNumeric = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              if (isOptional)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Chip(
                    label: const Text("Optional"),
                    labelStyle: const TextStyle(fontSize: 10),
                    backgroundColor: Colors.grey.shade200,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType:
                isNumeric
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              suffixIcon:
                  unit.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Text(
                          unit,
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                      : null,
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
            validator: (value) {
              if (!isOptional && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              if (isNumeric &&
                  value != null &&
                  value.isNotEmpty &&
                  double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
