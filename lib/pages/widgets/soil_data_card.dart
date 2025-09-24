import 'package:flutter/material.dart';
import '../../models/soil_data.dart';
import 'package:intl/intl.dart';

class SoilDataCard extends StatelessWidget {
  final SoilData data;
  final bool isGeminiLoading;
  final VoidCallback onGetPlants;
  final VoidCallback onGetSoilCare;

  const SoilDataCard({
    super.key,
    required this.data,
    required this.isGeminiLoading,
    required this.onGetPlants,
    required this.onGetSoilCare,
  });

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
              'Time',
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
            const Divider(height: 30),
            Text('AI Analysis:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (isGeminiLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onGetPlants,
                    child: const Text('Suggest Plants'),
                  ),
                  ElevatedButton(
                    onPressed: onGetSoilCare,
                    child: const Text('Get Soil Advice'),
                  ),
                ],
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
            width: 120,
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
