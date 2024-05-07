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
  String _inputText = "";

 @override
  void initState() {
    super.initState();
    _sqliteService = SqliteService();
    _sqliteService.initializeDB().whenComplete(() async {
      await _refreshLanguages();
      _getSharedText();
      debugPrint('[translate_screen] [initDB] ====== Enabled Languages: $_enabledLanguages');
      setState(() {
        _refreshLanguages();
      });
    });   
  }

  // This function is used to run a state change with the latest DB data
  Future<void> _refreshLanguages() async {
    final languages = await _sqliteService.getLanguages();
    List<Language> enabledInDB = languages.where((lang) => lang.active == 1).toList();
    debugPrint('[translate_screen] [refreshLang] ====== Current: ${_enabledLanguages.length} || Fetch from DB: ${enabledInDB.length}');
    if (_enabledLanguages.length != enabledInDB.length){
      setState(() {
        _enabledLanguages = enabledInDB;
      });
      debugPrint('[translate_screen] [refreshLang] ====== Updated state: $_enabledLanguages');
    } else {
      debugPrint('[translate_screen] [refreshLang] ====== Omit state update');
    }
    
  }

  Future<void> _getSharedText() async {
    var intentText = await platform.invokeMethod('getSharedText');
    debugPrint("[translate_screen] asking for intent");
    if (intentText != null) {
      debugPrint("[translate_screen] INTENT=$intentText");
      setState(() {
        _inputText = intentText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[translate_screen] [build] Render triggered.");
    _refreshLanguages();
    debugPrint("[translate_screen] [build] ${_enabledLanguages.toString()}");
    debugPrint("[translate_screen] [build] ${_enabledLanguages.isEmpty.toString()} || ${_enabledLanguages.length}");
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
          Expanded(child: LanguageList(key: UniqueKey(), enabledLanguages: _enabledLanguages, text: _inputText)),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // border: Border.all(width: 0, color: Colors.blue),
              ),
              child: TextFormField(
                initialValue: _inputText.isNotEmpty ? _inputText : "",
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
                    _inputText = value;
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
