import 'package:flutter/material.dart';
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
      debugPrint("[languages_screen] ====== Updated Lang list: $_enabledLanguages");
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[languages_screen] ====== Render triggered. Enabled Langs: $_enabledLanguages");
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
              }
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _languagesToShow.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> currentLanguage = _languagesToShow[index].toMap();
                return CheckboxListTile(
                  key: ValueKey(currentLanguage['id']),
                  title: Text(currentLanguage['displayText']!),
                  subtitle: Text(currentLanguage['native']!),
                  value: currentLanguage['active']! == 1 ? true : false,
                  onChanged: (bool? value) async {
                    debugPrint("[languages_screen] ====== onChange event triggered, updating languages list.");
                    currentLanguage['active'] = value! ? 1 : 0;
                    setState(() {
                      _languagesToShow[index] = Language.fromMap(currentLanguage);
                    });
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