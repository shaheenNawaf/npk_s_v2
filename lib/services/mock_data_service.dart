import '../models/soil_data.dart';

class MockDataService {
  static SoilData getMockSoilData() {
    return SoilData(
      nMgKg: 35.0,
      pMgKg: 40.0,
      kMgKg: 150.0,
      ph: 6.5,
      calcium: 1200.0,
      magnesium: 250.0,
      sodium: 80.0,
      exchangeableK: 0.5,
      sulfur: 15.0,
      organicMatter: 4.0,
      copper: 2.5,
      zinc: 3.0,
      iron: 50.0,
      manganese: 25.0,
      boron: 0.8,

      // Soil Properties
      soilType: 'Loam',
    );
  }
}
