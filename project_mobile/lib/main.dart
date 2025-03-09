import 'package:flutter/material.dart';
import 'package:mobile_project/about_pages.dart';
import 'package:mobile_project/typepot.dart';
import 'package:mobile_project/home.dart';
import 'package:mobile_project/register.dart';
// import 'package:mobile_project/farm_type.dart';
// import 'package:mobile_project/grow.dart';
// import 'package:mobile_project/cultivation.dart';
import 'package:mobile_project/nav_bar.dart';
//import 'package:mobile_project/device_manage.dart';
import 'package:mobile_project/device_manage2.dart';
import 'package:mobile_project/farm_type2.dart';
import 'package:mobile_project/grow2.dart';
import 'package:mobile_project/cultivation2.dart';
import 'package:mobile_project/cultivationpot.dart';
import 'package:mobile_project/growingpot.dart';
import 'package:mobile_project/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme:
            const AppBarTheme(color: Color.fromARGB(255, 179, 179, 179)),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 179, 179, 179)),
        useMaterial3: true,
      ),
      initialRoute: "/login",
      routes: {
        '/login': (context) => LoginApp(), // No navigation drawer
        '/register': (context) => RegisterScreen(), // No navigation drawer
        '/about_page': (context) => NavBar(
              body: AboutPages(),
              title: 'About Page',
              image: Image.asset('assets/images/mushroom.png', height: 30),
            ),
        '/home': (context) => NavBar(
              body: WeatherScreen(),
              title: 'Weather Page',
              image: Image.asset('assets/images/mushroom.png', height: 30),
            ),
        '/typepot': (context) => NavBar(
              body: TypepotPage(),
              title: 'Mauhroom Type Page',
              image: Image.asset('assets/images/mushroom.png', height: 30),
            ),
        // '/farm_type': (context) => NavBar(
        //       body: FarmType(),
        //       title: 'Farm Type Page',
        //       image: Image.asset('assets/images/mushroom.png', height: 30),
        //     ),
        '/farm_type2': (context) => NavBar(
              body: FarmPage(),
              title: 'Farm Type Page',
              image: Image.asset('assets/images/mushroom.png', height: 30),
            ),
        // '/device_manage': (context) => NavBar(
        //       body: DeviceManage(),
        //       title: 'Device Manage Page',
        //       image: Image.asset('assets/images/mushroom.png', height: 30),
        //     ),
        '/device_manage2': (context) => NavBar(
              body: DevicePage(),
              title: 'Device Page',
              image: Image.asset('assets/images/mushroom.png', height: 30),
            ),
        // '/typepot': (context) =>  NavBar(
        //       body: TypepotPage(),
        //       title: 'Typepot Page',
        //     ),
        // '/cultivation': (context) => NavBar(
        //       body: CultivationType(),
        //       title: 'Cultivation Page',
        //       image: Image.asset('assets/images/mushroom.png', height: 30),
        //     ),

        '/cultivation2': (context) => NavBar(
              body: CultivationPage(),
              title: 'Cultivation Page',
              image: Image.asset('assets/images/mushroom.png', height: 30),
            ),
        // '/grow': (context) => NavBar(
        //       body: GrowType(),
        //       title: 'Growing Page',
        //       image: Image.asset('assets/images/mushroom.png', height: 30),
        //     ),
        '/grow2': (context) => NavBar(
              body: GrowingPage(),
              title: 'Growing Page',
              image: Image.asset('assets/images/mushroom.png', height: 30),
            ),
        '/cultivationpot': (context) {
          final int cultivationId =
              ModalRoute.of(context)!.settings.arguments as int;

          return NavBar(
            body: CultivationpotPage(cultivationId: cultivationId),
            title: 'Cultivationpot',
            image: Image.asset('assets/images/mushroom.png', height: 30),
          );
        },
        '/growingpot': (context) {
          final int growingId =
              ModalRoute.of(context)!.settings.arguments as int;

          return NavBar(
            body: GrowingpotPage(growingId: growingId),
            title: 'Cultivationpot',
            image: Image.asset('assets/images/mushroom.png', height: 30),
          );
        },
        // '/cultivationpot': (context) =>  NavBar(
        //       body: CultivationpotPage(),
        //       title: 'Cultivationpot Page',
        //     ),
        // '/growingpot': (context) =>  NavBar(
        //       body: GrowingpotPage(),
        //       title: 'Growingpot Page',
        // ),
      },
    );
  }
}
