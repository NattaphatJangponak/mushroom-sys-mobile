import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http; // Import the new Growing class

const String typePotUrl = 'http://192.168.1.101:5000/api/mushroom';

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
    print('POST Data: $data');
    final response = await http.post(
      Uri.parse('http://192.168.1.101:5000/api/viewGrowing'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    print('POST Response: ${response.statusCode} ${response.body}');
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
      Uri.parse('http://192.168.1.101:5000/api/viewGrowing/$id'),
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
      Uri.parse('http://192.168.1.101:5000/api/viewGrowing/$id'),
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

List<GrowingPot> parseGrowingPots(String jsonStr) {
  final decoded = json.decode(jsonStr);
  print(decoded);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => GrowingPot.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

List<TypePot> parseTypePots(String jsonStr) {
  final decoded = json.decode(jsonStr);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => TypePot.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

class GrowingpotPage extends StatefulWidget {
  final int growingId; // ตัวแปรสำหรับเก็บค่า ID

  // Constructor ที่รับค่า ID
  const GrowingpotPage({super.key, required this.growingId});

  @override
  // ignore: library_private_types_in_public_api
  _GrowingpotPageState createState() => _GrowingpotPageState();
}

class _GrowingpotPageState extends State<GrowingpotPage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<GrowingPot> pots = []; // สำหรับเก็บ List ของ GrowingPot
  List<TypePot> typePots = [];
  String selectedTypePot = '';
  String selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      String growingPotData = await fetchData(
          'http://192.168.1.101:5000/api/viewGrowing/${widget.growingId}');
      String typePotData = await fetchData(typePotUrl);

      print('Fetched growingPotData: $growingPotData');
      print('Fetched typePotData: $typePotData');

      setState(() {
        pots = parseGrowingPots(growingPotData);
        typePots = parseTypePots(typePotData);
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  void _openEditModal(GrowingPot pot) {
    String selectedTypePot =
        typePots.firstWhere((t) => t.typePotId == pot.typePotId).typePotName;
    String selectedStatus = pot.status;
    final TextEditingController potNameController =
        TextEditingController(text: pot.potName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit GrowingPot'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTypePot,
                  decoration: const InputDecoration(labelText: 'Type Pot Name'),
                  items: typePots.map((typePot) {
                    return DropdownMenuItem(
                      value: typePot.typePotName,
                      child: Text(typePot.typePotName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTypePot = value ?? '';
                    });
                  },
                  hint: const Text('Select Type Pot Name'),
                ),
                TextField(
                  controller: potNameController,
                  decoration: const InputDecoration(labelText: 'Pot Name'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: 'safe',
                      child: Text('Safe'),
                    ),
                    DropdownMenuItem(
                      value: 'danger',
                      child: Text('Danger'),
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
                int newTypePotId = typePots
                    .firstWhere((t) => t.typePotName == selectedTypePot)
                    .typePotId;
                print(
                    'PUT Data: ${pot.growingPotId}, Type Pot ID: $newTypePotId, Pot Name: ${potNameController.text}, Status: $selectedStatus');
                await putData(
                    pot.growingPotId,
                    {
                      'type_pot_id': newTypePotId,
                      'pot_name': potNameController.text,
                      'status': selectedStatus,
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
    String selectedTypePot =
        typePots.isNotEmpty ? typePots.first.typePotName : '';
    String selectedStatus = 'pending';
    final TextEditingController potNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add GrowingPot'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTypePot,
                  decoration: const InputDecoration(labelText: 'Type Pot Name'),
                  items: typePots.map((typePot) {
                    return DropdownMenuItem(
                      value: typePot.typePotName,
                      child: Text(typePot.typePotName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTypePot = value ?? '';
                    });
                  },
                  hint: const Text('Select Type Pot Name'),
                ),
                TextField(
                  controller: potNameController,
                  decoration: const InputDecoration(labelText: 'Pot Name'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: 'safe',
                      child: Text('Safe'),
                    ),
                    DropdownMenuItem(
                      value: 'danger',
                      child: Text('Danger'),
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
                int newTypePotId = typePots
                    .firstWhere((t) => t.typePotName == selectedTypePot)
                    .typePotId;
                await postData({
                  'type_pot_id': newTypePotId,
                  'pot_name': potNameController.text,
                  'status': selectedStatus,
                  'growing_id': widget.growingId, // Add the growing_id field
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
        child: pots.isNotEmpty
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: pots.length,
                itemBuilder: (context, index) {
                  final pot = pots[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(3),
                    child: InkWell(
                      onTap: () {
                        _openEditModal(pot);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Builder(
                                builder: (context) {
                                  try {
                                    if (pot.imgPath.trim().isEmpty) {
                                      return const Icon(
                                          Icons.image_not_supported,
                                          size: 50);
                                    }
                                    final decodedBytes = base64Decode(
                                        pot.imgPath.split(',').last);
                                    return Image.memory(
                                      decodedBytes,
                                      height: 150,
                                      fit: BoxFit.contain,
                                    );
                                  } catch (e) {
                                    return const Icon(Icons.error, size: 50);
                                  }
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(pot.growingPotId.toString(),
                                      style: TextStyle(fontSize: 14)),
                                  Text(pot.potName,
                                      style: TextStyle(fontSize: 14)),
                                  Text(pot.status,
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Ink(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.white),
                                      onPressed: () {
                                        _openEditModal(pot);
                                      },
                                    ),
                                  ),
                                  Ink(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.white),
                                      onPressed: () {
                                        deleteData(pot.growingPotId, _loadData);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(child: Text('No pots found')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[700],
      ),
    );
  }
}

class GrowingPot {
  final int growingPotId;
  final int typePotId;
  final int? index; // Allow index to be nullable
  final String imgPath;
  String aiResult;
  final String status;
  String potName;

  GrowingPot({
    required this.growingPotId,
    required this.typePotId,
    this.index, // Allow index to be nullable
    required this.imgPath,
    required this.aiResult,
    required this.status,
    required this.potName,
  });

  factory GrowingPot.fromJson(Map<String, dynamic> json) {
    return GrowingPot(
      growingPotId: json['growing_pot_id'],
      typePotId: json['type_pot_id'],
      index: json['index'], // Allow index to be nullable
      imgPath: json['img_path'] ?? 'No data entered',
      aiResult: json['ai_result'] ?? 'No data entered',
      status: json['status'],
      potName: json['pot_name'],
    );
  }
}

class TypePot {
  final int typePotId;
  final String typePotName;

  TypePot({
    required this.typePotId,
    required this.typePotName,
  });

  factory TypePot.fromJson(Map<String, dynamic> json) {
    return TypePot(
      typePotId: json['type_pot_id'],
      typePotName: json['type_pot_name'],
    );
  }
}

class Growing {
  final int growingId;
  int farmId;
  int deviceId;

  Growing({
    required this.growingId,
    required this.farmId,
    required this.deviceId,
  });

  factory Growing.fromJson(Map<String, dynamic> json) {
    return Growing(
      growingId: json['growing_id'],
      farmId: json['farm_id'],
      deviceId: json['device_id'],
    );
  }
}
