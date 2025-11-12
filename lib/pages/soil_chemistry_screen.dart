import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/soil_data.dart';
import '../services/mock_data_service.dart';
import 'widgets/form_app_bar.dart';
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

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _soilData = widget.initialData;
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
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _useTypicalValues() {
    final mockData = MockDataService.getMockSoilData();
    setState(() {
      _controllers['nMgKg']?.text = mockData.nMgKg?.toString() ?? '';
      _controllers['pMgKg']?.text = mockData.pMgKg?.toString() ?? '';
      _controllers['kMgKg']?.text = mockData.kMgKg?.toString() ?? '';
      _controllers['ph']?.text = mockData.ph?.toString() ?? '';
      _controllers['calcium']?.text = mockData.calcium?.toString() ?? '';
      _controllers['magnesium']?.text = mockData.magnesium?.toString() ?? '';
      _controllers['sodium']?.text = mockData.sodium?.toString() ?? '';
      _controllers['exchangeableK']?.text =
          mockData.exchangeableK?.toString() ?? '';
      _controllers['organicMatter']?.text =
          mockData.organicMatter?.toString() ?? '';
      _controllers['sulfur']?.text = mockData.sulfur?.toString() ?? '';
      _controllers['copper']?.text = mockData.copper?.toString() ?? '';
      _controllers['zinc']?.text = mockData.zinc?.toString() ?? '';
      _controllers['iron']?.text = mockData.iron?.toString() ?? '';
      _controllers['manganese']?.text = mockData.manganese?.toString() ?? '';
      _controllers['boron']?.text = mockData.boron?.toString() ?? '';
    });
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _soilData.nMgKg = double.tryParse(_controllers['nMgKg']!.text);
        _soilData.pMgKg = double.tryParse(_controllers['pMgKg']!.text);
        _soilData.kMgKg = double.tryParse(_controllers['kMgKg']!.text);
        _soilData.ph = double.tryParse(_controllers['ph']!.text);
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
      appBar: const FormAppBar(
        title: "AGRI-SENSE",
        subtitle: "Personalized Crop Recommendations",
        progress: 1 / 2,
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
                "Soil Chemistry",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter the chemical properties of your soil. If a value is unknown, you can leave it blank or use typical values.",
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
                icon: Icons.eco,
                iconColor: Colors.green,
                title: "Primary Nutrients (NPK)",
                subtitle: "Essential macronutrients for plant growth",
                fields: [
                  _buildTextField(
                    label: "Nitrogen (N)",
                    hint: "e.g., 25",
                    unit: "mg/kg",
                    controller: _controllers['nMgKg']!,
                    infoTooltip: "Vital for leaf growth",
                  ),
                  _buildTextField(
                    label: "Phosphorus (P)",
                    hint: "e.g., 20",
                    unit: "mg/kg",
                    controller: _controllers['pMgKg']!,
                    infoTooltip: "Crucial for root development",
                  ),
                  _buildTextField(
                    label: "Potassium (K)",
                    hint: "e.g., 150",
                    unit: "mg/kg",
                    controller: _controllers['kMgKg']!,
                    infoTooltip: "Important for overall plant health",
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                icon: Icons.public,
                iconColor: Colors.blue,
                title: "Soil Conditions",
                subtitle: "Physical and environmental properties",
                fields: [
                  _buildTextField(
                    label: "pH Level",
                    hint: "e.g., 6.5",
                    unit: "pH",
                    controller: _controllers['ph']!,
                    infoTooltip: "Acidity or alkalinity of the soil",
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                icon: Icons.scatter_plot,
                iconColor: Colors.orange,
                title: "Macronutrients",
                subtitle: "Important trace elements",
                fields: [
                  _buildTextField(
                    label: "Calcium (Ca)",
                    hint: "e.g., 1500",
                    unit: "mg/kg",
                    controller: _controllers['calcium']!,
                  ),
                  _buildTextField(
                    label: "Magnesium (Mg)",
                    hint: "e.g., 300",
                    unit: "mg/kg",
                    controller: _controllers['magnesium']!,
                  ),
                  _buildTextField(
                    label: "Sodium (Na)",
                    hint: "e.g., 50",
                    unit: "mg/kg",
                    controller: _controllers['sodium']!,
                  ),
                  _buildTextField(
                    label: "Exchangeable K",
                    hint: "e.g., 120",
                    unit: "meq/100g",
                    controller: _controllers['exchangeableK']!,
                  ),
                  _buildTextField(
                    label: "Sulfur",
                    hint: "e.g., 120",
                    unit: "mg/kg",
                    controller: _controllers['sulfur']!,
                  ),
                  _buildTextField(
                    label: "Organic Matter (OM)",
                    hint: "e.g., 1%",
                    unit: "%",
                    controller: _controllers['organicMatter']!,
                  ),
                  _buildTextField(
                    label: "Copper (Cu)",
                    hint: "e.g., 1",
                    unit: "mg/kg",
                    controller: _controllers['copper']!,
                  ),
                  _buildTextField(
                    label: "Zinc (Zn)",
                    hint: "e.g., 1",
                    unit: "mg/kg",
                    controller: _controllers['zinc']!,
                  ),
                  _buildTextField(
                    label: "Iron (Fe)",
                    hint: "e.g., 1",
                    unit: "mg/kg",
                    controller: _controllers['iron']!,
                  ),
                  _buildTextField(
                    label: "Manganese (Mn)",
                    hint: "e.g., 1",
                    unit: "mg/kg",
                    controller: _controllers['manganese']!,
                  ),
                  _buildTextField(
                    label: "Boron (B)",
                    hint: "e.g., 1",
                    unit: "mg/kg",
                    controller: _controllers['boron']!,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
    String? infoTooltip,
    bool isOptional = false,
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
              if (infoTooltip != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Tooltip(
                    message: infoTooltip,
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade300,
                    ),
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
            validator: (value) {
              if (!isOptional && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              if (value != null &&
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
