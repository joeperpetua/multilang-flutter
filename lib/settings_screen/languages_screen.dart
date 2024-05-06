import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

//import 'package:multilang/settings_screen/language.dart';
//import 'package:multilang/settings_screen/language_model.dart';
import 'package:multilang/services/sqlite_service.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});
  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  late SqliteService _sqliteService;
  late List<Language> _languageList = [];
  late List<Language> _enabledLanguages = [];
  late List<Language> _languagesToShow = [];

  @override
  void initState() {
    super.initState();
    _sqliteService = SqliteService();
    _sqliteService.initializeDB().whenComplete(() async {
      await _refreshLanguages();
      debugPrint('[languages_screen] ====== Languages: $_languageList');
      debugPrint('[languages_screen] ====== Enabled Languages: $_enabledLanguages');
      setState(() { 
        _languagesToShow = _languageList;
      });
    });
  }

  // This function is used to run a state change with the latest DB data
  Future<void> _refreshLanguages() async {  
    final data = await _sqliteService.getLanguages();
    setState(() {
      _languageList = data;
      _enabledLanguages = _languageList.where((lang) => lang.isActive()).toList();
    });
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
                _languagesToShow = _languageList.where((language) {
                  var languageName = language.displayText.toLowerCase();
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
                Map<String, dynamic> currentLanguage = _languagesToShow[index].toMap();
                return CheckboxListTile(
                  title: Text(currentLanguage['displayText']!),
                  subtitle: Text(currentLanguage['native']!),
                  value: currentLanguage['active']! == 1 ? true : false,
                  onChanged: (bool? value) async {
                    currentLanguage['active'] = value! ? 1 : 0;
                    await _sqliteService.updateLanguage(Language.fromMap(currentLanguage));
                    await _refreshLanguages();
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