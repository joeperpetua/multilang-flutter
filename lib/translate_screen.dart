// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:multilang/language_list.dart';
import 'package:multilang/services/sqlite_service.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  static const platform = MethodChannel('app.channel.shared.data');
  late SqliteService _sqliteService;
  late List<Language> _enabledLanguages = [];
  late Settings _settings;

 @override
  void initState() {
    super.initState();
    _sqliteService = SqliteService();
    _sqliteService.initializeDB().whenComplete(() async {
      await _refreshSettings();
      await _refreshLanguages();
      _getSharedText();
      debugPrint('[translate_screen] ====== Enabled Languages: $_enabledLanguages');
      setState(() { });
    });
  }

  // This function is used to run a state change with the latest DB data
  Future<void> _refreshLanguages() async {  
    final languages = await _sqliteService.getLanguages();
    setState(() {
      _enabledLanguages = languages.where((lang) => lang.active == 1).toList();
    });
    debugPrint('[translate_screen] ====== Enabled Languages: $_enabledLanguages');
  }

  Future<void> _refreshSettings() async {  
    Settings data = await _sqliteService.getSettings(); 
    setState(() {
      _settings = data;
    }); 
  }

  Future<void> _getSharedText() async {
    var intentText = await platform.invokeMethod('getSharedText');
    debugPrint("[translate_screen] asking for intent");
    if (intentText != null) {
      debugPrint("[translate_screen] INTENT=$intentText");
      setState(() {
        Map<String, dynamic> newSettings = _settings.toMap();
        newSettings['inputText'] = intentText;
        _sqliteService.updateSettings(Settings.fromMap(newSettings));
      });
      await _refreshSettings();
      // focusNode.requestFocus();
    }
  }

  Future<void> _getTranslation(String text) async {
    setState(() {
      Map<String, dynamic> newSettings = _settings.toMap();
      newSettings['inputText'] = text;
      _sqliteService.updateSettings(Settings.fromMap(newSettings));
    });
    await _refreshSettings();
  }



  @override
  Widget build(BuildContext context) {
    debugPrint("[translate_screen] Render triggered.");
    debugPrint("[translate_screen] ${_enabledLanguages.toString()}");
    //inspect(_selectedLanguages);
    if (_enabledLanguages.isEmpty){
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: TextStyle(fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(text: 'No languages are selected, please go to '),
                    TextSpan(text: 'Settings > Languages', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' to select the languages to use.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox.expand(
      child: Column(
        children: <Widget> [
          Expanded(child: LanguageList(key: UniqueKey(), enabledLanguages: _enabledLanguages, data: _settings.inputText)),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // border: Border.all(width: 0, color: Colors.blue),
              ),
              child: TextFormField(
                initialValue: _settings.inputText,
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.text,
                // focusNode: focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1, color: Colors.blue),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Enter text to translate...',
                ),
                onFieldSubmitted: (value) => {
                  setState(() {
                    _getTranslation(value);
                  }),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
