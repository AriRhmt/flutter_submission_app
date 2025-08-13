import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme.dart';
import 'core_scroll_behavior.dart';
import 'pages/main_list_page.dart';
import 'pages/detail_page.dart';
import 'pages/settings_page.dart';
import 'pages/grocery_page.dart';
import 'pages/details_page.dart';
import 'pages/list_page.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  ThemeMode _mode = ThemeMode.light;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Submission App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode,
      builder: (context, child) => ScrollConfiguration(behavior: const AppScrollBehavior(), child: child!),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('id')],
      routes: {
        '/': (_) => _ScaffoldShell(
              index: _tab,
              onIndexChanged: (i) => setState(() => _tab = i),
              pages: [
                const MainListPage(),
                const GroceryPage(),
                SettingsPage(
                  themeMode: _mode,
                  onThemeModeChanged: (m) => setState(() => _mode = m),
                ),
              ],
            ),
        '/detail': (_) => const DetailPage(),
        '/details': (_) => const DetailsPage(),
        '/list': (_) => const ListPage(),
      },
    );
  }
}

class _ScaffoldShell extends StatelessWidget {
  const _ScaffoldShell({required this.index, required this.onIndexChanged, required this.pages});
  final int index;
  final ValueChanged<int> onIndexChanged;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onIndexChanged,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu_rounded), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.shopping_basket_rounded), label: 'Grocery'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
