import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/mrz_scanner/views/mrz_result_screen.dart';

void main() {
  runApp(const ProviderScope(child: PassportReaderApp()));
}

class PassportReaderApp extends StatelessWidget {
  const PassportReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passport Reader',
      theme: AppTheme.lightTheme,
      home: const MrzResultScreen(),
    );
  }
}
