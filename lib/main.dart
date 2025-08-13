import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'veggielibrary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final deviceId = prefs.getString('device_id');

  runApp(MyApp(deviceId: deviceId));
}

class MyApp extends StatelessWidget {
  final String? deviceId;
  const MyApp({super.key, this.deviceId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Care',
      theme: ThemeData(primarySwatch: Colors.green),
      home:
          deviceId == null
              ? const DeviceGate()
              : DashboardScreen(deviceId: deviceId!),
    );
  }
}

// ================== DEVICE SELECTION SCREEN ==================
class DeviceGate extends StatefulWidget {
  const DeviceGate({super.key});

  @override
  State<DeviceGate> createState() => _DeviceGateState();
}

class _DeviceGateState extends State<DeviceGate> {
  final _controller = TextEditingController();

  Future<void> _validateAndSaveDeviceId() async {
    final id = _controller.text.trim();
    if (id.isEmpty) return;

    final ref = FirebaseDatabase.instance.ref('sensors/$id');
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      // Show Invalid Code
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Invalid code"),
              content: const Text("The device ID you entered does not exist."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } else {
      // Save & Navigate
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_id', id);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen(deviceId: id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'ADD DEVICE',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              Icon(Icons.wifi, size: 100, color: Colors.green[200]),
              const SizedBox(height: 60),
              const Text(
                'Manual Activation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter Device ID (e.g. plant_001)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Connect Button
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _validateAndSaveDeviceId,
                  child: const Text('CONNECT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== SETTINGS SCREEN ==================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoWatering = true;
  bool adaptiveLed = true;
  String selectedVegetable = "Vegetable list";

  Future<void> _connectNewDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_id');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const DeviceGate()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                "Automatic Watering",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              value: autoWatering,
              onChanged: (v) => setState(() => autoWatering = v),
            ),
            const SizedBox(height: 8),

            // Centered Dropdown
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 150,
                child: DropdownButton<String>(
                  value: selectedVegetable,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items:
                      ["Vegetable list", "Lettuce", "Tomato", "Spinach"]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() => selectedVegetable = value!),
                ),
              ),
            ),

            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text(
                "Adaptive LED Light",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              value: adaptiveLed,
              onChanged: (v) => setState(() => adaptiveLed = v),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _connectNewDevice,
              child: const Text("Connect Device"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== DASHBOARD SCREEN ==================
class DashboardScreen extends StatefulWidget {
  final String deviceId;
  const DashboardScreen({super.key, required this.deviceId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DatabaseReference ref;
  bool isConnected = false;
  Map<String, dynamic> data = {
    "soil": 0,
    "temp": 0,
    "humidity": 0,
    "light_raw": 0,
  };
  DateTime lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref('sensors/${widget.deviceId}');

    // Listen for changes
    ref.onValue.listen((event) {
      final dbSnap = event.snapshot;

      if (dbSnap.value != null) {
        final map = Map<String, dynamic>.from(
          dbSnap.value as Map<dynamic, dynamic>,
        );
        setState(() {
          isConnected = true;
          lastUpdate = DateTime.now();
          data = {
            "soil": map['soil'] ?? 0,
            "temp": map['temp'] ?? 0,
            "humidity": map['humidity'] ?? 0,
            "light_raw": map['light_raw'] ?? 0,
          };
        });
      }
    });

    // Periodic check for connection timeout
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (DateTime.now().difference(lastUpdate) > const Duration(seconds: 5)) {
        setState(() {
          isConnected = false;
          data = {"soil": 0, "temp": 0, "humidity": 0, "light_raw": 0};
        });
      }
      return mounted;
    });
  }

  Widget _buildTile(String label, String value) {
    return Container(
      width: 150,
      height: 120,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[500],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        title: const Text('Plant Care'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(Icons.local_florist, size: 120, color: Colors.green[700]),
            const SizedBox(height: 8),
            Text(
              'Device: ${widget.deviceId}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected ? "Connected" : "Disconnected",
                  style: TextStyle(
                    fontSize: 14,
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildTile('SOILMOISTURE', '${data["soil"]}%'),
                _buildTile('TEMPERATURE', '${data["temp"]}°C'),
                _buildTile('HUMIDITY', '${data["humidity"]}%'),
                _buildTile('LIGHT', '${data["light_raw"]}'),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Realtime updates from device',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.local_florist),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VeggieLibraryScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
