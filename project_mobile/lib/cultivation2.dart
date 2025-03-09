import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_project/cultivationpot.dart';
import 'package:mobile_project/nav_bar.dart';

const String url = 'http://192.168.1.101:5000/api/cultivation';
const String deviceUrl = 'http://192.168.1.101:5000/api/device';
const String farmUrl = 'http://192.168.1.101:5000/api/farm';

// ฟังก์ชันโหลดข้อมูล JSON
Future<String> fetchData(String apiUrl) async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load data in fetchData: $e');
  }
}

// ฟังก์ชันสำหรับ POST ข้อมูล
Future<void> postData(Map<String, dynamic> data, Function _loadData) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      _loadData();
    } else {
      throw Exception(
          'Failed to post data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to post data: $e');
  }
}

// ฟังก์ชันสำหรับ PUT ข้อมูล
Future<void> putData(
    int id, Map<String, dynamic> data, Function _loadData) async {
  try {
    final response = await http.put(
      Uri.parse('$url/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      _loadData();
    } else {
      throw Exception(
          'Failed to update data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to update data: $e');
  }
}

// ฟังก์ชันสำหรับ DELETE ข้อมูล
Future<void> deleteData(int id, Function _loadData) async {
  try {
    final response = await http.delete(
      Uri.parse('$url/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      _loadData();
    } else {
      throw Exception(
          'Failed to delete data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to delete data: $e');
  }
}

// แปลง JSON เป็น List<Cultivation>
List<Cultivation> parseCultivations(String jsonStr) {
  final decoded = json.decode(jsonStr);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => Cultivation.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

class CultivationPage extends StatefulWidget {
  const CultivationPage({super.key});

  @override
  State<CultivationPage> createState() => _CultivationPageState();
}

class _CultivationPageState extends State<CultivationPage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<Cultivation> cultivations = []; // สำหรับเก็บ List ของ cultivation
  List<Device> devices = [];
  List<Farm> farms = [];
  String selectedDevice = '';
  String selectedFarm = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      String cultivationData = await fetchData(url);
      String deviceData = await fetchData(deviceUrl);
      String farmData = await fetchData(farmUrl);

      setState(() {
        cultivations = parseCultivations(cultivationData);
        devices = parseDevices(deviceData);
        farms = parseFarms(farmData);
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  List<Device> parseDevices(String jsonStr) {
    final decoded = json.decode(jsonStr);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      final List<dynamic> list = decoded['data'];
      return list.map((data) => Device.fromJson(data)).toList();
    } else {
      throw Exception("Unexpected JSON format");
    }
  }

  List<Farm> parseFarms(String jsonStr) {
    final decoded = json.decode(jsonStr);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      final List<dynamic> list = decoded['data'];
      return list.map((data) => Farm.fromJson(data)).toList();
    } else {
      throw Exception("Unexpected JSON format");
    }
  }

  void _openEditModal(Cultivation item) {
    String selectedDevice =
        devices.firstWhere((d) => d.device_id == item.device_id).device_name;
    String selectedFarm =
        farms.firstWhere((f) => f.farm_id == item.farm_id).farm_name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Cultivation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFarm,
                decoration: const InputDecoration(labelText: 'Farm Name'),
                items: farms.map((farm) {
                  return DropdownMenuItem(
                    value: farm.farm_name,
                    child: Text(farm.farm_name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFarm = value ?? '';
                  });
                },
                hint: const Text('Select Farm Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedDevice,
                decoration: const InputDecoration(labelText: 'Device Name'),
                items: devices.map((device) {
                  return DropdownMenuItem(
                    value: device.device_name,
                    child: Text(device.device_name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDevice = value ?? '';
                  });
                },
                hint: const Text('Select Device Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int newFarmId = farms
                    .firstWhere((f) => f.farm_name == selectedFarm)
                    .farm_id;
                int newDeviceId = devices
                    .firstWhere((d) => d.device_name == selectedDevice)
                    .device_id;
                await putData(
                    item.cultivation_id,
                    {
                      'farm_id': newFarmId,
                      'device_id': newDeviceId,
                    },
                    _loadData);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _openAddModal() {
    String selectedDevice = devices.isNotEmpty ? devices.first.device_name : '';
    String selectedFarm = farms.isNotEmpty ? farms.first.farm_name : '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Cultivation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFarm,
                decoration: const InputDecoration(labelText: 'Farm Name'),
                items: farms.map((farm) {
                  return DropdownMenuItem(
                    value: farm.farm_name,
                    child: Text(farm.farm_name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFarm = value ?? '';
                  });
                },
                hint: const Text('Select Farm Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedDevice,
                decoration: const InputDecoration(labelText: 'Device Name'),
                items: devices.map((device) {
                  return DropdownMenuItem(
                    value: device.device_name,
                    child: Text(device.device_name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDevice = value ?? '';
                  });
                },
                hint: const Text('Select Device Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int newFarmId = farms
                    .firstWhere((f) => f.farm_name == selectedFarm)
                    .farm_id;
                int newDeviceId = devices
                    .firstWhere((d) => d.device_name == selectedDevice)
                    .device_id;
                await postData({
                  'farm_id': newFarmId,
                  'device_id': newDeviceId,
                }, _loadData);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: cultivations.isNotEmpty
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: cultivations.length,
                itemBuilder: (context, index) {
                  final cultivation = cultivations[index];
                  final farm = farms.firstWhere(
                      (f) => f.farm_id == cultivation.farm_id,
                      orElse: () => Farm(farm_id: 0, farm_name: 'Unknown'));
                  final device = devices.firstWhere(
                      (d) => d.device_id == cultivation.device_id,
                      orElse: () =>
                          Device(device_id: 0, device_name: 'Unknown'));

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(3),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavBar(
                              body: CultivationpotPage(
                                  cultivationId: cultivation.cultivation_id),
                              title: 'Cultivation Page',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        height: 250, // Increase the height of the card
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircleAvatar(
                              child: Text(device.device_id.toString()),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(farm.farm_name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(device.device_name,
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    onPressed: () {
                                      _openEditModal(cultivation);
                                    },
                                  ),
                                ),
                                Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.remove_red_eye,
                                        color: Colors.white),
                                    onPressed: () {
                                      /*
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CultivationpotPage(
                                                  cultivationId: cultivation
                                                      .cultivation_id),
                                        ),
                                      );
                                      */
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NavBar(
                                            body: CultivationpotPage(
                                                cultivationId:
                                                    cultivation.cultivation_id),
                                            title: 'Cultivation Page',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: IconButton(
                                    icon:
                                        Icon(Icons.delete, color: Colors.white),
                                    onPressed: () {
                                      deleteData(cultivation.cultivation_id,
                                          _loadData);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(child: Text('No growings found')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[700],
      ),
    );
  }
}

// Class สำหรับแปลง JSON
class Cultivation {
  final int cultivation_id;
  int farm_id;
  int device_id;

  Cultivation({
    required this.cultivation_id,
    required this.farm_id,
    required this.device_id,
  });

  factory Cultivation.fromJson(Map<String, dynamic> json) {
    return Cultivation(
      cultivation_id: json['cultivation_id'],
      farm_id: json['farm_id'],
      device_id: json['device_id'],
    );
  }
}

class Device {
  final int device_id;
  final String device_name;

  Device({
    required this.device_id,
    required this.device_name,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      device_id: json['device_id'],
      device_name: json['device_name'],
    );
  }
}

class Farm {
  final int farm_id;
  final String farm_name;

  Farm({
    required this.farm_id,
    required this.farm_name,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      farm_id: json['farm_id'],
      farm_name: json['farm_name'],
    );
  }
}
