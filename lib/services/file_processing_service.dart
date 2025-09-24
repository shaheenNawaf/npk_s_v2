import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../models/soil_data.dart';

class FileProcessingService {
  SoilData? processExcelData(Uint8List bytes) {
    var excel = Excel.decodeBytes(bytes);
    Sheet? sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null || sheet.maxRows <= 1) {
      throw Exception("Excel file is empty or contains no data.");
    }

    List<String> headers =
        sheet.rows.first
            .map((cell) => cell?.value.toString().trim() ?? '')
            .toList();

    DateTime? latestTime;
    SoilData? tempLatestSoilData;

    for (int i = 1; i < sheet.maxRows; i++) {
      List<Data?> row = sheet.rows[i];
      if (row.any((cell) => cell?.value != null)) {
        Map<String, dynamic> rowMap = {};
        for (int j = 0; j < headers.length; j++) {
          if (j < row.length) {
            rowMap[headers[j]] = row[j];
          }
        }
        SoilData currentRowData = SoilData.fromMap(rowMap);
        if (currentRowData.time != null) {
          if (latestTime == null || currentRowData.time!.isAfter(latestTime)) {
            latestTime = currentRowData.time;
            tempLatestSoilData = currentRowData;
          }
        }
      }
    }
    return tempLatestSoilData;
  }

  Future<SoilData?> processCsvData(Uint8List bytes) async {
    final csvString = utf8.decode(bytes);
    final List<List<dynamic>> fields = const CsvToListConverter().convert(
      csvString,
    );

    if (fields.length <= 1) {
      throw Exception("CSV file is empty or has no data.");
    }

    final headers = fields[0].map((h) => h.toString().trim()).toList();
    final timeColumnIndex = headers.indexOf('Time');

    if (timeColumnIndex == -1) {
      throw Exception("CSV file is missing the 'Time' column.");
    }

    DateTime? latestTime;
    List<dynamic>? latestRow;

    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length > timeColumnIndex) {
        try {
          final timeString = row[timeColumnIndex].toString();
          final currentTime = DateFormat(
            "yyyy-MM-dd HH:mm:ss",
          ).parse(timeString);
          if (latestTime == null || currentTime.isAfter(latestTime)) {
            latestTime = currentTime;
            latestRow = row;
          }
        } catch (e) {
          // Empty ang mga rows na not following the format, might add another parser dito just to keep things uniform.
        }
      }
    }

    if (latestRow != null) {
      Map<String, dynamic> rowMap = {};
      for (int j = 0; j < headers.length; j++) {
        if (j < latestRow.length) {
          rowMap[headers[j]] = latestRow[j].toString();
        }
      }
      return SoilData.fromMap(rowMap);
    }
    return null;
  }
}
