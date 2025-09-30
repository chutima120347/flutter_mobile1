import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String token = "b07c04e65409bc21692828671378a7b32b01b4cb";

const String defaultCity = "bangkok";

class AqiExample extends StatefulWidget {
  const AqiExample({super.key});

  @override
  State<AqiExample> createState() => _AqiExampleState();
}

class _AqiExampleState extends State<AqiExample> {
  bool loading = true;
  int? aqi;
  String? cityName;
  double? tempC;
  double? humidity;
  double? wind;
  double? pressure;
  double? pm25;
  double? pm10;
  String? updateText;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
      error = null;
    });

    final url = "https://api.waqi.info/feed/$defaultCity/?token=$token";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) throw Exception("HTTP ${res.statusCode}");

      final body = json.decode(res.body);
      if (body["status"] != "ok")
        throw Exception("API status: ${body["status"]}");

      final data = body["data"];
      setState(() {
        aqi = data["aqi"] ?? 0;
        cityName = data["city"]?["name"] ?? defaultCity;
        tempC = (data['iaqi']?['t']?['v'] as num?)?.toDouble();
        humidity = (data['iaqi']?['h']?['v'] as num?)?.toDouble();
        wind = (data['iaqi']?['w']?['v'] as num?)?.toDouble();
        pressure = (data['iaqi']?['p']?['v'] as num?)?.toDouble();
        pm25 = (data['iaqi']?['pm25']?['v'] as num?)?.toDouble();
        pm10 = (data['iaqi']?['pm10']?['v'] as num?)?.toDouble();

        final ts = data['time']?['s'] as String?;
        if (ts != null) updateText = prettyTime(ts);

        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  String prettyTime(String s) {
    final parts = s.split(' ');
    final datePart = parts[0];
    final timePart = parts[1].substring(0, 5);
    final date = DateTime.parse("$datePart $timePart:00");
    const weekdays = [
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์',
    ];
    return 'อัปเดตล่าสุด: ${weekdays[date.weekday - 1]} เวลา $timePart';
  }

  Map<String, dynamic> aqiStyle(int? aqi) {
    aqi ??= 0;
    if (aqi <= 50)
      return {
        "color": Colors.green,
        "emoji": "😃",
        "label": "Good",
        "gradient": [Colors.green.shade400, Colors.green.shade100],
      };
    if (aqi <= 100)
      return {
        "color": Colors.yellow.shade800,
        "emoji": "😊",
        "label": "Moderate",
        "gradient": [Colors.yellow.shade700, Colors.yellow.shade200],
      };
    if (aqi <= 150)
      return {
        "color": Colors.orange,
        "emoji": "😷",
        "label": "Unhealthy SG",
        "gradient": [Colors.orange.shade600, Colors.orange.shade200],
      };
    if (aqi <= 200)
      return {
        "color": Colors.red,
        "emoji": "🤒",
        "label": "Unhealthy",
        "gradient": [Colors.red.shade700, Colors.red.shade200],
      };
    if (aqi <= 300)
      return {
        "color": Colors.purple,
        "emoji": "🤢",
        "label": "Very Unhealthy",
        "gradient": [Colors.purple.shade700, Colors.purple.shade200],
      };
    return {
      "color": Colors.brown,
      "emoji": "☠️",
      "label": "Hazardous",
      "gradient": [Colors.brown.shade700, Colors.brown.shade200],
    };
  }

  Widget miniTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget observationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Current Observation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                miniTile(
                  Icons.thermostat,
                  "Temp",
                  tempC != null ? "${tempC!.toStringAsFixed(1)} °C" : "-",
                ),
                miniTile(
                  Icons.water_drop,
                  "Humidity",
                  humidity != null ? "${humidity!.toStringAsFixed(1)} %" : "-",
                ),
                miniTile(
                  Icons.air,
                  "Wind",
                  wind != null ? "${wind!.toStringAsFixed(1)} m/s" : "-",
                ),
                miniTile(
                  Icons.compress,
                  "Pressure",
                  pressure != null
                      ? "${pressure!.toStringAsFixed(1)} hPa"
                      : "-",
                ),
                miniTile(
                  Icons.cloud,
                  "PM2.5",
                  pm25 != null ? "${pm25!.toStringAsFixed(1)} µg/m³" : "-",
                ),
                miniTile(
                  Icons.cloud_queue,
                  "PM10",
                  pm10 != null ? "${pm10!.toStringAsFixed(1)} µg/m³" : "-",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = aqiStyle(aqi);

    return Scaffold(
      appBar: AppBar(
        title: Text("Air Quality Index (AQI)"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: style["gradient"],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : error != null
              ? Text(
                  "Error: $error",
                  style: const TextStyle(color: Colors.white),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "🌍 $cityName",
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${aqi ?? '-'} ${style["emoji"]}",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: style["color"],
                        ),
                      ),
                      Text(
                        style["label"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: style["color"],
                        ),
                      ),
                      if (updateText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            updateText!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      const SizedBox(height: 24),
                      observationCard(),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: fetchData,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
