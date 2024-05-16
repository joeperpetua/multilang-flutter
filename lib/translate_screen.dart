// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:multilang/language_list.dart';
import 'package:multilang/services/sqlite_service.dart';
import 'package:multilang/services/translation.dart';
import 'package:multilang/services/utils.dart';

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
  List<Translation> _translations = [];
  bool _isLoading = false;

 @override
  void initState() {
    super.initState();
    _sqliteService = SqliteService();
    _sqliteService.initializeDB().whenComplete(() {
      setState(() {
        _refreshLanguages().then((_) {
          _getSharedText(context);
          debugPrint('[translate_screen] [initDB] ====== Enabled Languages: $_enabledLanguages');
        });
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

  Future<void> _getSharedText(BuildContext context) async {
    var intentText = await platform.invokeMethod('getSharedText');
    debugPrint("[translate_screen] asking for intent");
    if (intentText != null) {
      debugPrint("[translate_screen] INTENT=$intentText");
      setState(() {
        _inputText = intentText;
      });
      // ignore: use_build_context_synchronously
      await fetchTranslation(context, intentText);
    }
  }

  Future<void> fetchTranslation(context, text) async {
    setState(() {
      _isLoading = true;
    });
    String url = "https://apiml.joeper.myds.me/translate?q=${text}&sl=auto&tl=";
    debugPrint("[translate_screen] [fetchTranslation] ============= $_enabledLanguages");
    for (var index = 0; index < _enabledLanguages.length; index++){
      if (index != _enabledLanguages.length - 1) {
        url += _enabledLanguages[index].code;
        url += ',';
      } else {
        url += _enabledLanguages[index].code;
      }
    }
    debugPrint("[translate_screen] [fetchTranslation] ============= $url");
    
    http.Response fetchResponse = await http.get(Uri.parse(url));
    if (fetchResponse.statusCode == 200) {
      debugPrint("[translate_screen] [fetchTranslation] ============= ${fetchResponse.body}");
      final parsedJson = jsonDecode(fetchResponse.body);
      List<Translation> receivedTranslations = [];
      for (var translation in parsedJson['translations']) {
        Translation current = Translation.fromMap(translation);
        receivedTranslations.add(current);
      }
      setState(() {
        _isLoading = false;
        _translations = receivedTranslations;
        debugPrint("[translate_screen] [fetchTranslation] ============= ${_translations.toString()}");
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      showBanner(context, "Something wrong happened 😭... (${fetchResponse.statusCode})", const Duration(seconds: 5));
      throw Exception('Failed to fetch translation service. ${fetchResponse.statusCode} || ${fetchResponse.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[translate_screen] [build] Render triggered.");
    if (mounted) {
      _refreshLanguages();
    }
    debugPrint("[translate_screen] [build] ${_enabledLanguages.toString()}");
    debugPrint("[translate_screen] [build] ${_enabledLanguages.isEmpty.toString()} || ${_enabledLanguages.length}");
    String tempInputText = "";
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
          Expanded(child: LanguageList(key: UniqueKey(), enabledLanguages: _enabledLanguages, translations: _translations)),
          Container(
            padding: const EdgeInsets.only(top: 8, left: 8, bottom: 18, right: 18.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              // border: Border.all(width: 0, color: Colors.blue),
            ),
            child: Row (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                Expanded(child: TextFormField(
                      initialValue: _inputText.isNotEmpty ? _inputText : "",
                      minLines: 6,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
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
                      onChanged: (value) => {
                        tempInputText = value
                      },
                    ),
                  ),
                Container (
                  margin: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Container(
                        margin: const EdgeInsets.only(bottom: 4.0),
                        child: SizedBox(
                          height: 75,
                          width: 75,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                              ),
                            ),
                            onPressed: () async => {
                              FocusManager.instance.primaryFocus?.unfocus(),
                              await fetchTranslation(context, tempInputText),
                              setState(() {
                                _inputText = tempInputText;
                              })
                            },
                            child: _isLoading ? 
                              const SizedBox(width: 25, height: 25, child: CircularProgressIndicator()) 
                              : 
                              const Icon(Icons.subdirectory_arrow_left_rounded),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          height: 100,
                          width: 75,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                              ),
                            ),
                            onPressed: () => showBanner(context, "Feature not supported yet!", Durations.extralong4),
                            child: const Icon(Icons.mic),
                          ),
                        )
                      ),
                    ],
                  ),
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}
