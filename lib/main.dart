import 'package:flutter/material.dart';
import 'theme.dart';
import 'core_scroll_behavior.dart';
import 'pages/home_page.dart';
import 'pages/list_page.dart';
import 'pages/details_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Submission App',
      theme: AppTheme.light(),
      builder: (context, child) => ScrollConfiguration(behavior: const AppScrollBehavior(), child: child!),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/list': (_) => const ListPage(),
        '/details': (_) => const DetailsPage(),
      },
    );
  }
}
