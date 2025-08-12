import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/layouts/main_layout.dart';
import 'presentation/pages/home_page.dart';
import 'state/providers/example_provider.dart';
import 'core/utils/app_scroll_behavior.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExampleProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Submission App',
        theme: AppTheme.light(),
        builder: (context, child) => ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: child!,
        ),
        home: const MainLayout(child: HomePage()),
      ),
    );
  }
}
