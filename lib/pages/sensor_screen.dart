import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/soil_data.dart';
import 'soil_chemistry_screen.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  StreamSubscription? _scanSubscription;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  String _statusMessage = "Scanning for sensors...";
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectedDevice?.disconnect();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _statusMessage = "Scanning for nearby sensors...";
    });
    _scanSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        setState(() {
          _scanResults =
              results.where((r) => r.device.platformName.isNotEmpty).toList();
        });
      },
      onError: (e) {
        setState(() {
          _statusMessage = "Scan Error: $e";
        });
      },
    );
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _statusMessage = "Connecting to ${device.platformName}...";
    });

    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
        license: License.free,
      );
      setState(() {
        _connectedDevice = device;
        _statusMessage = "Connected! Reading data...";
      });

      await _readData(device);
    } catch (e) {
      setState(() {
        _statusMessage = "Connection Failed: $e";
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _readData(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      BluetoothService targetService = services.firstWhere(
        (s) => s.uuid.str.toLowerCase() == serviceUuid,
      );
      BluetoothCharacteristic targetCharacteristic = targetService
          .characteristics
          .firstWhere((c) => c.uuid.str.toLowerCase() == characteristicUuid);

      List<int> value = await targetCharacteristic.read();
      String jsonString = utf8.decode(value);

      _parseAndNavigate(jsonString);
    } catch (e) {
      setState(() {
        _statusMessage = "Failed to read data: $e";
      });
      device.disconnect();
    }
  }

  void _parseAndNavigate(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      final soilData = SoilData(
        nMgKg: (data['N'] as num?)?.toDouble(),
        pMgKg: (data['P'] as num?)?.toDouble(),
        kMgKg: (data['K'] as num?)?.toDouble(),
        ph: (data['ph'] as num?)?.toDouble(),
      );

      // Successfully parsed, now navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SoilChemistryScreen(initialData: soilData),
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Failed to parse sensor data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to Sensor", style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isConnecting) const CircularProgressIndicator(),
                if (_isConnecting) const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: GoogleFonts.poppins(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(result.device.platformName),
                  subtitle: Text(result.device.remoteId.str),
                  onTap:
                      _isConnecting
                          ? null
                          : () => _connectToDevice(result.device),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isConnecting ? null : _startScan,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
