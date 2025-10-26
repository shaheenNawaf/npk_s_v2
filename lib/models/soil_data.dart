import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class SoilData {
  String? description;
  DateTime? time;
  double? tempC;
  double? hum;
  double? conductivityUsCm;
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
  String? soilTextureGroup;
  double? sandContent;
  double? siltContent;
  double? clayContent;
  bool? isLoam;
  String? existingCrops;
  String? primaryCrop;

  SoilData({
    this.description,
    this.time,
    this.tempC,
    this.hum,
    this.conductivityUsCm,
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
    this.soilTextureGroup,
    this.sandContent,
    this.siltContent,
    this.clayContent,
    this.isLoam,
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

    DateTime? parseTime(dynamic value) {
      if (value == null) return null;
      try {
        String timeString;
        if (value is Data) {
          if (value.value == null) return null;
          timeString = value.value.toString();
        } else if (value is String) {
          timeString = value;
        } else {
          timeString = value.toString();
        }
        final DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
        return format.parse(timeString);
      } catch (e) {
        print('Error parsing time $value: $e');
      }
      return null;
    }

    return SoilData(
      description: _parseValue<String>(data['description'], (s) => s),
      time: parseTime(data['time']),
      tempC: _parseValue<double>(data['temp(C)'], (s) => double.tryParse(s)),
      hum: _parseValue<double>(data['hum(%)'], (s) => double.tryParse(s)),
      conductivityUsCm: _parseValue<double>(
        data['conductivity(us/cm)'],
        (s) => double.tryParse(s),
      ),
      ph: _parseValue<double>(data['ph'], (s) => double.tryParse(s)),
      nMgKg: _parseValue<double>(data['n(mg/kg)'], (s) => double.tryParse(s)),
      pMgKg: _parseValue<double>(data['p(mg/kg)'], (s) => double.tryParse(s)),
      kMgKg: _parseValue<double>(data['k(mg/kg)'], (s) => double.tryParse(s)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': tempC,
      'humidity': hum,
      'ph': ph,
      'n': nMgKg,
      'p': pMgKg,
      'k': kMgKg,
      'conductivity': conductivityUsCm,
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
      'soilTextureGroup': soilTextureGroup,
      'sandContent': sandContent,
      'siltContent': siltContent,
      'clayContent': clayContent,
      'isLoam': isLoam,
      'existingCrops': existingCrops,
      'primaryCrop': primaryCrop,
    };
  }
}
