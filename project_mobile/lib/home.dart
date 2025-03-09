import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MushroomIOTApp());
}

class MushroomIOTApp extends StatelessWidget {
  const MushroomIOTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  List<dynamic> weatherData = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    const city = 'Bangkok'; // You can change the city name to your preference
    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=e13e248ba58a789dbfacad81dd150a7e&units=metric');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          weatherData = data[
              'list']; // Adjust this depending on the structure of the response
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: weatherData.isNotEmpty
            ? ListView.builder(
                itemCount: weatherData.length,
                itemBuilder: (context, index) {
                  final item = weatherData[index];
                  return WeatherCard(
                    day: "Day ${index + 1}",
                    humidity: "${item['main']['humidity']}%",
                    temperature:
                        "${item['main']['temp_min']} / ${item['main']['temp_max']}",
                    icon: Icons
                        .wb_sunny, // This can be dynamic based on weather conditions
                  );
                },
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String day;
  final String humidity;
  final String temperature;
  final IconData icon;

  const WeatherCard({
    Key? key,
    required this.day,
    required this.humidity,
    required this.temperature,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Humidity: $humidity"),
                Text(
                  "$temperature °C",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Icon(icon, size: 50, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
