import 'package:flutter/material.dart';
import 'screens/authentication_screen.dart';

void main() {
  runApp(const PassportReaderApp());
}

class PassportReaderApp extends StatelessWidget {
  const PassportReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passport Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthenticationScreen(),
    );
  }
}
