import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:multilang/dictionary_screen.dart';
import 'package:multilang/translate_screen.dart';

import 'package:multilang/settings_screen/settings_screen.dart';
import 'package:multilang/settings_screen/language_model.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LanguageModel(),
        ),
      ],
      child: MaterialApp(
        title: 'MultiLang',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'MultiLang'),
      )
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
      body: Consumer<LanguageModel>(
        builder: (context, language, child) {
          return  <Widget>[
            const TranslateScreen(),
            const DictionaryScreen(),
            const SettingsScreen(),
          ][currentPageIndex];
        }
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
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.school),
            icon: Icon(Icons.school_outlined),
            label: 'School',
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
