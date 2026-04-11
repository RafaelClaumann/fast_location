import 'package:fast_location/src/shared/controllers/address_controller.dart';
import 'package:fast_location/src/shared/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'src/modules/history/page/history_page.dart';
import 'src/modules/home/page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Hive
  await Hive.initFlutter();

  // Registra o adaptador que o build_runner gerou
  Hive.registerAdapter(AddressModelAdapter());

  runApp(
    // O ChangeNotifierProvider gerencia a vida útil do seu Controller
    ChangeNotifierProvider(
      create: (context) => AddressController()..loadAddresses(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Location',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}
