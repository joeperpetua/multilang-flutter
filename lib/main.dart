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
    int getPage() {
    return pageIndex;
  }

  void setPage(int index) {
    pageIndex = index;
  }
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  final List<Widget> _pages = const <Widget>[
    DictionaryScreen(),
    TranslateScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    _pageController = PageController(
      keepPage: true,
      initialPage: widget.getPage(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer<LanguageModel>(
        builder: (context, language, child) {
          return SizedBox.expand(
            child: PageView.builder(
              itemCount: 5,
              controller: _pageController,
              onPageChanged: (index) => setState(() {
                widget.setPage(index);
                _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
              }),
              itemBuilder: (context, index) => IndexedStack(
                index: index,
                children: _pages,
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Dictionary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Translate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: widget.getPage(),
        selectedItemColor: Colors.amber[800],
        onTap: (index) => setState(() {
          widget.setPage(index);
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        })
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
