import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
// import 'dart:developer';

import 'package:multilang/settings_screen/language.dart';
import 'package:multilang/settings_screen/language_model.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  List<Language> _languagesToShow = [];
  bool isStopped = false;
  int render = 0;
  
  static const platform = MethodChannel('app.channel.shared.data');
  String dataShared = '';

  @override
  void initState() {
    super.initState();
    loadDataFromModel();
    getSharedText();
  }

  void loadDataFromModel() async {
    await Provider.of<LanguageModel>(context, listen: false).initPrefs();
    setState(() {
      _languagesToShow = Provider.of<LanguageModel>(context, listen: false).selectedLanguages;
    });
  }

  Future<void> getSharedText() async {
    var intentText = await platform.invokeMethod('getSharedText');
    debugPrint("DEBUG: asking for intent");
    if (intentText != null) {
      debugPrint("DEBUG: INTENT=$intentText");
      setState(() {
        dataShared = intentText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _languagesToShow.length,
      itemBuilder: (context, index) {
        final language = _languagesToShow[index];
        if (language.selected){
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(language.code),
              ),
              title: Text(language.name),
              subtitle: Text(language.selected.toString()),
              onTap: () {
                // Add your onTap functionality here
              },
            ),
          );
        } else {
          return const Text('');
        }
      }
    );
  }
}
