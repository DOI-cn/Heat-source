import 'package:flutter/material.dart';

import 'ui/pages/history_page.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/result_page.dart';

void main() {
  runApp(const CalorieApp());
}

class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (_) => const HomePage(),
        ResultPage.routeName: (_) => const ResultPage(),
        HistoryPage.routeName: (_) => const HistoryPage(),
      },
    );
  }
}
