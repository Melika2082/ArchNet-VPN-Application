import 'package:archnet/vpnService/vpn_status_provider.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:archnet/pages/login.dart';
import 'package:archnet/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  await Hive.initFlutter();
  final box = await Hive.openBox('userBox');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => VpnStatusProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
      child: MyApp(box: box),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box box;
  const MyApp({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    const defaultFontFamily = TextStyle(
      fontFamily: 'vazir',
    );
    if (box.containsKey('token')) {
      return GetMaterialApp(
        title: 'ArchNet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: const TextTheme(
            titleLarge: defaultFontFamily,
            bodyMedium: defaultFontFamily,
            bodyLarge: defaultFontFamily,
            bodySmall: defaultFontFamily,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 28, 100, 184),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      );
    } else {
      return const MaterialApp(
        title: 'ArchNet',
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      );
    }
  }
}
