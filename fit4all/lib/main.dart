import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enforce portrait mode for better MVP experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const Fit4AllApp());
}

class Fit4AllApp extends StatelessWidget {
  const Fit4AllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fit4all',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
