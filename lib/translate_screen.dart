import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:multilang/language_list.dart';
import 'package:multilang/settings_screen/language.dart';
import 'package:multilang/settings_screen/language_model.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  List<Language> _selectedLanguages = [];
  String _inputText = '';
  String _cardText = '';
  
  static const platform = MethodChannel('app.channel.shared.data');

  late FocusNode focusNode;

  @override
  void initState() {
    _loadDataFromModel();
    _getSharedText();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void _loadDataFromModel() async {
    await Provider.of<LanguageModel>(context, listen: false).initPrefs();

    setState(() {
      _selectedLanguages = Provider.of<LanguageModel>(context, listen: false).selectedLanguages;
    });
  }

  Future<void> _getSharedText() async {
    var intentText = await platform.invokeMethod('getSharedText');
    debugPrint("DEBUG: asking for intent");
    if (intentText != null) {
      debugPrint("DEBUG: INTENT=$intentText");
      setState(() {
        _inputText = intentText;
      });
      focusNode.requestFocus();
    }
  }

  Future<void> _getTranslation(String text) async {
    setState(() {
      _cardText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Render triggered.");
    //inspect(_selectedLanguages);
    if (_selectedLanguages.isEmpty){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
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
    debugPrint("Input text: $_inputText");
    return SizedBox.expand(
      child: Column(
        children: <Widget> [
          Expanded(child: LanguageList(key: UniqueKey(), selectedLanguages: _selectedLanguages, data: _cardText)),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // border: Border.all(width: 0, color: Colors.blue),
              ),
              child: TextFormField(
                initialValue: _inputText,
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.text,
                focusNode: focusNode,
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
                onChanged: (value) => setState(() {
                  _inputText = value;
                  debugPrint("Changed text: $_inputText");
                }),
                onFieldSubmitted: _getTranslation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
