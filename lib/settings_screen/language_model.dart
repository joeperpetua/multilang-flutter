import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:multilang/settings_screen/language.dart';

class LanguageModel extends ChangeNotifier {
  late List<Language> _languages;
  SharedPreferences? _prefs;

  LanguageModel() {
    _languages = [
      Language(name: 'English', native: 'English', code: 'en', selected: false),
      Language(name: 'Spanish', native: 'Español', code: 'es', selected: false),
      Language(name: 'French', native: 'Français', code: 'fr', selected: false),
      Language(name: 'German', native: 'Deutsch', code: 'de', selected: false),
      Language(name: 'Italian', native: 'Italiano', code: 'it', selected: false),
      Language(name: 'Portuguese', native: 'Português', code: 'pt', selected: false),
      Language(name: 'Russian', native: 'Русский', code: 'ru', selected: false),
      Language(name: 'Chinese', native: '中文', code: 'zh', selected: false),
      Language(name: 'Arabic', native: 'العربية', code: 'ar', selected: false),
      Language(name: 'Japanese', native: '日本語', code: 'ja', selected: false),
    ];
    initPrefs();
  }

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences? get prefs => _prefs;
  List<Language> get languages => _languages;
  List<Language> get selectedLanguages => _getSelectedLanguages();
  void get saveLanguages => _saveLanguages();
  // void setOrder => _setOrder();

  List<Language> _getSelectedLanguages() {
    final selectedLanguages = _languages.where((element) => element.selected == true).toList();
    return selectedLanguages;
  }

  void _saveLanguages() async {
    final selectedLanguages = _languages.where(
      (language) => language.selected
    ).map(
      (language) => language.code
    ).toList();
    _prefs?.setStringList('selectedLanguages', selectedLanguages);
    notifyListeners();
  }

  // void _setOrder(List<Language> abc) async {
  //   final orderedList = selectedLanguages.map(
  //     (language) => language.code
  //   ).toList();
  //   _prefs?.setStringList('orderedList', orderedList);
  // }
}