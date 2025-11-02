import '../models/soil_data.dart';

class MockDataService {
  static SoilData getMockSoilData() {
    return SoilData(
      // Soil Chemistry
      nMgKg: 35.0,
      pMgKg: 40.0,
      kMgKg: 150.0,
      ph: 6.5,
      hum: 50.0,
      tempC: 25.0,
      conductivityUsCm: 200.0,
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
      soilTextureGroup: 'Medium',
      sandContent: 2.0, // 0-3 scale: 2 = sandy component present
      siltContent: 0.0, // 0-3 scale: 0 = no silt component
      clayContent: 0.0, // 0-3 scale: 0 = no clay component
      isLoam: true,
      existingCrops: 'Corn, Wheat',
      primaryCrop: 'Corn',

      // Location & Climate
      latitude: 14.5995,
      longitude: 120.9842,
      avgTempC: 27.5,
      avgHumidity: 75.0,
      avgPrecipitation: 2000.0,
    );
  }
}
