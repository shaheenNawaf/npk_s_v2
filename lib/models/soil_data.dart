import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class SoilData {
  double? ph;
  double? nMgKg;
  double? pMgKg;
  double? kMgKg;
  double? calcium;
  double? magnesium;
  double? sodium;
  double? exchangeableK;
  double? sulfur;
  double? organicMatter;
  double? copper;
  double? zinc;
  double? iron;
  double? manganese;
  double? boron;
  String? soilType;
  String? existingCrops;
  String? primaryCrop;

  SoilData({
    this.ph,
    this.nMgKg,
    this.pMgKg,
    this.kMgKg,
    this.calcium,
    this.magnesium,
    this.sodium,
    this.exchangeableK,
    this.sulfur,
    this.organicMatter,
    this.copper,
    this.zinc,
    this.iron,
    this.manganese,
    this.boron,
    this.soilType,
    this.existingCrops,
    this.primaryCrop,
  });

  factory SoilData.fromMap(Map<String, dynamic> data) {
    T? _parseValue<T>(dynamic value, T? Function(String) parser) {
      if (value == null) return null;
      if (value is T) return value;
      try {
        String stringValue;
        if (value is Data) {
          if (value.value == null) return null;
          stringValue = value.value.toString();
        } else {
          stringValue = value.toString();
        }
        return parser(stringValue);
      } catch (e) {
        print('Error parsing value $value: $e');
      }
      return null;
    }

    return SoilData(
      ph: _parseValue<double>(data['ph'], (s) => double.tryParse(s)),
      nMgKg: _parseValue<double>(data['n(mg/kg)'], (s) => double.tryParse(s)),
      pMgKg: _parseValue<double>(data['p(mg/kg)'], (s) => double.tryParse(s)),
      kMgKg: _parseValue<double>(data['k(mg/kg)'], (s) => double.tryParse(s)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ph': ph,
      'n': nMgKg,
      'p': pMgKg,
      'k': kMgKg,
      'calcium': calcium,
      'magnesium': magnesium,
      'sodium': sodium,
      'exchangeableK': exchangeableK,
      'sulfur': sulfur,
      'organicMatter': organicMatter,
      'copper': copper,
      'zinc': zinc,
      'iron': iron,
      'manganese': manganese,
      'boron': boron,
      'soilType': soilType,
      'existingCrops': existingCrops,
      'primaryCrop': primaryCrop,
    };
  }
}
