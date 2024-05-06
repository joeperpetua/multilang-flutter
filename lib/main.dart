import 'package:flutter/material.dart';

// import 'package:multilang/services/sqlite_service.dart';

import 'package:multilang/dictionary_screen.dart';
import 'package:multilang/translate_screen.dart';

import 'package:multilang/settings_screen/settings_screen.dart';

// import 'dart:developer';

int pageIndex = 1;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MultiLang',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'MultiLang'),
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [TranslateScreen(key: UniqueKey()), DictionaryScreen(key: UniqueKey()), const SettingsScreen()]
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.translate),
            icon: Icon(Icons.translate_outlined),
            label: 'Translate',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            selectedIcon: Icon(Icons.menu_book_outlined),
            label: 'Dictionary',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
