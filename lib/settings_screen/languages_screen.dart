import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:multilang/settings_screen/language.dart';
import 'package:multilang/settings_screen/language_model.dart';


class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});
  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  late List<Language> _languagesToShow;

  @override
  void initState() {
    super.initState();
    _languagesToShow = Provider.of<LanguageModel>(context, listen: false).languages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Languages'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (text) {
              text = text.toLowerCase();
              setState(() {
                _languagesToShow = Provider.of<LanguageModel>(context, listen: false).languages.where((language) {
                  var languageName = language.name.toLowerCase();
                  var languageNative = language.native.toLowerCase();
                  return languageName.contains(text) || languageNative.contains(text);
                }).toList();
              });
            }),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _languagesToShow.length,
              itemBuilder: (context, index) {
                final language = _languagesToShow[index];
                return CheckboxListTile(
                  title: Text(language.name),
                  subtitle: Text(language.native),
                  value: language.selected,
                  onChanged: (bool? value) {
                    setState(() {
                      language.selected = value!;
                      Provider.of<LanguageModel>(context, listen: false).saveLanguages;
                    });
                  }
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}