import 'package:flutter/material.dart';
// import 'typepot.dart';
// import 'home.dart';
// import 'register.dart';
// import 'device.dart';
// import 'farm_type.dart';
// import 'grow.dart';
// import 'cultivation2.dart';

class AboutPages extends StatelessWidget {
  const AboutPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.grey[800],
      //   title: Row(
      //     children: [ ทำ file นี้
      //       Icon(Icons.menu, color: Colors.white),
      //       SizedBox(width: 10),
      //       Text('App Mushroom IOT', style: TextStyle(color: Colors.white)),
      //     ],
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Info",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Center(
              //   child: Image.network(
              //     "https://cdn.grange.co.uk/assets/new-cars/lamborghini/revuelto/revuelto-1_20241107093150469.png",
              //     height: 150,
              //   ),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('home'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'at/Master_data');
                },
                child: const Text('MushroomTypeScreen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Register'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/device');
                },
                child: const Text('device'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/farm_type');
                },
                child: const Text('farmtype'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/grow');
                },
                child: const Text('grow_type'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cultivation');
                },
                child: const Text('cultivation_type'),
              ),

              // IconButton(
              //     icon: Icon(Icons.display_settings),
              //     onPressed: () {
              //       Navigator.pushNamed(
              //         context,
              //         '/display_page',
              //       );
              //     })
            ],
          ),
        ),
      ),
    );
  }
}
