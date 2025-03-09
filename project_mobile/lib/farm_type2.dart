import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:math';

const String urlApi = 'http://192.168.1.101:5000/api/farm';

// ฟังก์ชันโหลดข้อมูล JSON สำหรับ farm
Future<String> fetchFarmData() async {
  try {
    final response = await http.get(Uri.parse(urlApi));
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return response.body;
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load data in fetchData: $e');
  }
}

// ฟังก์ชันสำหรับ POST farm (ตัวอย่างส่ง HTTP request)
Future<void> postFarmData(FarmData newFarm, Function _loadFarmData) async {
  try {
    final response = await http.post(
      Uri.parse(urlApi),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'farm_name': newFarm.farm_name,
        'farm_type': newFarm.farm_type,
        'farm_description': newFarm.farm_description,
        'farm_status': newFarm.farm_status,
        'temperature': newFarm.temperature,
        'humidity': newFarm.humidity,
      }),
    );
    if (response.statusCode == 201) {
      print("postFarmData 201");
      // Reload data after adding
      _loadFarmData();
    } else {
      throw Exception(
          'Failed to post farm data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to post farm data: $e');
  }
}

// ฟังก์ชันสำหรับ PUT farm (ตัวอย่างส่ง HTTP request)
Future<void> putFarmData(FarmData updatedFarm, Function _loadFarmData) async {
  try {
    final response = await http.put(
      Uri.parse('$urlApi/${updatedFarm.farm_id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'farm_name': updatedFarm.farm_name,
        'farm_type': updatedFarm.farm_type,
        'farm_description': updatedFarm.farm_description,
        'farm_status': updatedFarm.farm_status,
        'temperature': updatedFarm.temperature,
        'humidity': updatedFarm.humidity,
      }),
    );

    if (response.statusCode == 200) {
      print("putFarmData 200");
      // Reload data after updating
      _loadFarmData();
    } else {
      throw Exception(
          'Failed to update farm data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to update farm data: $e');
  }
}

Future<void> deleteFarmData(int farmId, Function _loadFarmData) async {
  try {
    final response = await http.delete(
      Uri.parse('$urlApi/$farmId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("deleteFarmData 200");
      // Reload data after deleting
      _loadFarmData();
    } else {
      throw Exception(
          'Failed to delete farm data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to delete farm data: $e');
  }
}

// ฟังก์ชันสำหรับ DELETE farm (ลบข้อมูลจาก UI)
void deleteFarm(List<FarmData> farms, int farmId, Function updateUI,
    Function loadFarmData) async {
  try {
    await deleteFarmData(farmId, loadFarmData);
    farms.removeWhere((farm) => farm.farm_id == farmId);
    updateUI();
  } catch (e) {
    throw Exception('Failed to delete farm: $e');
  }
}

// แปลง JSON เป็น FarmData List
List<FarmData> parseFarms(String jsonStr) {
  final decoded = json.decode(jsonStr);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => FarmData.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

class FarmPage extends StatefulWidget {
  const FarmPage({super.key});

  @override
  _FarmPageState createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  @override
  void initState() {
    super.initState();
    _loadFarmData(); // Call _loadData when the page is initialized
  }

  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<FarmData> farms = []; // สำหรับเก็บ List ของ FarmData

  void _loadFarmData() async {
    try {
      String jsonData = await fetchFarmData();
      setState(() {
        farms = parseFarms(jsonData)
            .cast<FarmData>(); // แปลง JSON เป็น FarmData List
        data = jsonData;
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  // ฟังก์ชันสำหรับเปิด modal แก้ไขข้อมูลของฟาร์ม
  void _openEditModal(FarmData farm) {
    final TextEditingController nameController =
        TextEditingController(text: farm.farm_name);
    final TextEditingController descriptionController =
        TextEditingController(text: farm.farm_description);
    String selectedType = farm.farm_type;
    String selectedStatus = farm.farm_status == 1 ? 'Active' : 'Inactive';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Farm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Farm Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedType.isEmpty ? null : selectedType,
                  decoration: const InputDecoration(labelText: 'Farm Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'โรงเพาะ',
                      child: Text('โรงเพาะ'),
                    ),
                    DropdownMenuItem(
                      value: 'โรงปลูก',
                      child: Text('โรงปลูก'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? '';
                    });
                  },
                  hint: const Text('Select Farm Type'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus.isEmpty ? null : selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? '';
                    });
                  },
                  hint: const Text('Select Status'),
                ),
              ],
            ),
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
                final updatedFarm = FarmData(
                  farm_id: farm.farm_id,
                  farm_name: nameController.text,
                  farm_type: selectedType,
                  farm_description: descriptionController.text,
                  farm_status: selectedStatus == 'Active' ? 1 : 0,
                  temperature: farm.temperature,
                  humidity: farm.humidity,
                );
                await putFarmData(updatedFarm, _loadFarmData);
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
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedType = '';
    String selectedStatus = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Farm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Farm Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedType.isEmpty ? null : selectedType,
                  decoration: const InputDecoration(labelText: 'Farm Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'โรงเพาะ',
                      child: Text('โรงเพาะ'),
                    ),
                    DropdownMenuItem(
                      value: 'โรงปลูก',
                      child: Text('โรงปลูก'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? '';
                    });
                  },
                  hint: const Text('Select Farm Type'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus.isEmpty ? null : selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? '';
                    });
                  },
                  hint: const Text('Select Status'),
                ),
              ],
            ),
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
                final newFarm = FarmData(
                  farm_id: farms.isNotEmpty ? farms.last.farm_id + 1 : 1,
                  farm_name: nameController.text,
                  farm_type: selectedType,
                  farm_description: descriptionController.text,
                  farm_status: selectedStatus == 'Active' ? 1 : 0,
                  temperature: 20.0,
                  humidity: 50.0,
                );
                await postFarmData(newFarm, _loadFarmData);
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
        child: farms.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    flex:
                        1, // Adjust flex to control size relative to the list below
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children:
                          List.generate(4, (index) => GaugeWidget(value: 31)),
                    ),
                  ),
                  Expanded(
                    flex: 2, // Adjust flex to provide more space for the list
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: farms.length,
                      itemBuilder: (context, index) {
                        final farm = farms[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.all(3),
                          child: InkWell(
                            onTap: () {
                              // Response when card is tapped
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CircleAvatar(
                                    child: Text(farm.farm_id.toString()),
                                  ),
                                  Text(farm.farm_name,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(farm.farm_type,
                                          style: TextStyle(fontSize: 14)),
                                      Text(
                                          farm.farm_status == 1
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  Text(farm.farm_description,
                                      style: TextStyle(fontSize: 14)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Ink(
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.white),
                                          onPressed: () {
                                            _openEditModal(farm);
                                          },
                                        ),
                                      ),
                                      Ink(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.white),
                                          onPressed: () {
                                            deleteFarm(farms, farm.farm_id, () {
                                              setState(() {});
                                            }, _loadFarmData);
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
                    ),
                  ),
                ],
              )
            : Center(child: Text('No farms found')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[700],
      ),
    );
  }
}

class GaugeWidget extends StatelessWidget {
  final double value;

  GaugeWidget({required this.value});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          axisLabelStyle: GaugeTextStyle(color: Colors.black, fontSize: 12),
          pointers: [NeedlePointer(value: value)],
          annotations: [
            GaugeAnnotation(
              widget: Text('$value%',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              angle: 90,
              positionFactor: 0.5,
            )
          ],
        ),
      ],
    );
  }
}

class FarmData {
  final int farm_id;
  final String farm_name;
  final String farm_type;
  final String farm_description;
  final int farm_status;
  final double temperature;
  final double humidity;

  FarmData({
    required this.farm_id,
    required this.farm_name,
    required this.farm_type,
    required this.farm_description,
    required this.farm_status,
    required this.temperature,
    required this.humidity,
  });

  factory FarmData.fromJson(Map<String, dynamic> json) {
    return FarmData(
      farm_id: json['farm_id'],
      farm_name: json['farm_name'],
      farm_type: json['farm_type'],
      farm_description: json['farm_description'],
      farm_status: json['farm_status'] is bool
          ? (json['farm_status'] ? 1 : 0)
          : json['farm_status'],
      temperature: json['temperature'] != null
          ? (json['temperature'] as num).toDouble()
          : 0.0,
      humidity:
          json['humidity'] != null ? (json['humidity'] as num).toDouble() : 0.0,
    );
  }
}
