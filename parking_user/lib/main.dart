import 'package:flutter/material.dart';
import 'package:parking_shared/objectbox.g.dart';
import 'package:parking_user/utilities/auth_check.dart';
import 'package:parking_user/utilities/theme_notifier.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

late final Store store;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are ready

  // Get a writable directory for ObjectBox
  final directory = await getApplicationDocumentsDirectory();
  store = await openStore(directory: directory.path);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Parkomat',
      themeMode: themeNotifier.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const AuthCheck(),
    );
  }
}