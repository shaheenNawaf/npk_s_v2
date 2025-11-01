import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/soil_data.dart';
import '../services/mock_data_service.dart';
import 'widgets/form_app_bar.dart';
import 'widgets/soil_guide_modal.dart';
import 'location_climate_screen.dart';

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
    'Unknown','Sand', 'Loamy Sand', 'Sandy Loam', 'Sandy Clay Loam',
    'Loam', 'Silt Loam', 'Silt', 'Clay Loam',
    'Clay', 'Silty Clay', 'Sandy Clay', 'Silty Clay Loam'
    'Peat'
  ];
  final List<Map<String, String>> _textureGroups = [
    {'name': 'Unknown', 'description': 'Not yet determined'},
    {'name': 'Coarse', 'description': 'Sandy soils - loose, gritty texture, drains quickly'},
    {'name': 'Medium', 'description': 'Loamy soils - balanced mixture, ideal for most crops'},
    {'name': 'Fine', 'description': 'Clay-heavy soils - smooth, sticky when wet, holds water well'},
    {'name': 'Organic', 'description': 'Peat soils - high organic matter, very water retentive'}
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
      _selectedTextureGroup = mockData.soilTextureGroup;
      _sandController.text = mockData.sandContent?.toString() ?? '';
      _siltController.text = mockData.siltContent?.toString() ?? '';
      _clayController.text = mockData.clayContent?.toString() ?? '';
      _existingCropsController.text = mockData.existingCrops ?? '';
      _primaryCropController.text = mockData.primaryCrop ?? '';
    });
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      // Validate that sand, silt, and clay values are within 0-3 range
      final sand = double.tryParse(_sandController.text);
      final silt = double.tryParse(_siltController.text);
      final clay = double.tryParse(_clayController.text);

      // Check if any entered values are outside the 0-3 range
      if ((sand != null && (sand < 0 || sand > 3)) ||
          (silt != null && (silt < 0 || silt > 3)) ||
          (clay != null && (clay < 0 || clay > 3))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sand, Silt, and Clay content must be between 0 and 3'),
          ),
        );
        return;
      }

      setState(() {
        _soilData.soilType = _selectedSoilType;
        _soilData.soilTextureGroup = _selectedTextureGroup;
        _soilData.sandContent = double.tryParse(_sandController.text);
        _soilData.siltContent = double.tryParse(_siltController.text);
        _soilData.clayContent = double.tryParse(_clayController.text);
        _soilData.existingCrops = _existingCropsController.text;
        _soilData.primaryCrop =
            _primaryCropController.text.isNotEmpty
                ? _primaryCropController.text
                : null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationClimateScreen(soilData: _soilData),
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
        progress: 2 / 3,
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
              Text(
                "Describe the physical characteristics of your soil.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

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
                  _buildTextureGroupDropdown(
                    "Soil Texture Group",
                    "Select a texture group",
                    _textureGroups,
                    _selectedTextureGroup,
                    (val) => setState(() => _selectedTextureGroup = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                icon: Icons.grain,
                iconColor: Colors.orangeAccent,
                title: "Texture Details",
                subtitle: "Soil component intensity (0-3 scale)",
                fields: [
                  _buildScaleLegend(),
                  _buildTextField(
                    label: "Sand Content",
                    hint: "0-3",
                    unit: "",
                    controller: _sandController,
                  ),
                  _buildTextField(
                    label: "Silt Content",
                    hint: "0-3",
                    unit: "",
                    controller: _siltController,
                  ),
                  _buildTextField(
                    label: "Clay Content",
                    hint: "0-3",
                    unit: "",
                    controller: _clayController,
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

  Widget _buildTextureGroupDropdown(
    String label,
    String hint,
    List<Map<String, String>> items,
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
            initialValue: selectedValue,
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
            selectedItemBuilder: (BuildContext context) {
              return items.map((Map<String, String> item) {
                return Text(
                  item['name']!,
                  style: GoogleFonts.poppins(),
                  overflow: TextOverflow.ellipsis,
                );
              }).toList();
            },
            items: items.map((Map<String, String> item) {
              return DropdownMenuItem<String>(
                value: item['name'],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['name']!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item['description']!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              );
            }).toList(),
            validator:
                (value) => value == null ? 'Please select an option' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildScaleLegend() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                "Soil Content Scale (0-3)",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLegendItem("0", "None - Component not present in soil type"),
          _buildLegendItem("1", "Some - Reserved (not currently used)"),
          _buildLegendItem("2", "Moderate - Component mentioned (e.g., 'sandy loam', 'silty clay')"),
          _buildLegendItem("3", "Dominant - Pure component (e.g., 'sand', 'silt', 'clay')"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String value, String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
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
