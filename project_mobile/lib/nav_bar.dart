import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final Widget body;
  final String title;
  final Image? image;

  const NavBar(
      {required this.body, required this.title, super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (image != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: image,
              ),
            Text(title),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: Text(
                'Mushroom System',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.nature),
              title: const Text('Mushroom Type'),
              onTap: () {
                Navigator.pushNamed(context, '/typepot');
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.info),
            //   title: const Text('Farm Type'),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/farm_type');
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.agriculture),
              title: const Text('Farm Type'),
              onTap: () {
                Navigator.pushNamed(context, '/farm_type2');
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.info),
            //   title: const Text('Device manage'),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/device_manage');
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.devices_other_outlined),
              title: const Text('Device manage'),
              onTap: () {
                Navigator.pushNamed(context, '/device_manage2');
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.person),
            //   title: const Text('Growing'),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/grow');
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.house_siding_outlined),
              title: const Text('Cutivation'),
              onTap: () {
                Navigator.pushNamed(context, '/cultivation2');
              },
            ),
            ListTile(
              leading: const Icon(Icons.house_outlined),
              title: const Text('Growing'),
              onTap: () {
                Navigator.pushNamed(context, '/grow2');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.person),
            //   title: const Text('cultivationpot'),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/cultivationpot');
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.person),
            //   title: const Text('Cutivation'),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/cultivation');
            //   },
            // ),
          ],
        ),
      ),
      body: body,
    );
  }
}
