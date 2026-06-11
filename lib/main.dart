import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/dashboard_page.dart';

void main() {
  runApp(const LangmanApp());
}

class LangmanApp extends StatelessWidget {
  const LangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Langman',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed:
            const Color(0xFF2A5298),
      ),

      routes: {
        '/dashboard': (context) =>
            const DashboardPage(),
      },

      home: const LoginPage(),
    );
  }
}