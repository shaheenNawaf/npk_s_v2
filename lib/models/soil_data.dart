import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class SoilData {
  final String? description;
  final DateTime? time;
  final double? tempC;
  final double? hum;
  final double? conductivityUsCm;
  final double? ph;
  final double? nMgKg;
  final double? pMgKg;
  final double? kMgKg;

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
      description: _parseValue<String>(data['Description'], (s) => s),
      time: parseTime(data['Time']),
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
}
