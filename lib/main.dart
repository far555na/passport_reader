import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/authentication_screen.dart';

void main() {
  runApp(const ProviderScope(child: PassportReaderApp()));
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
