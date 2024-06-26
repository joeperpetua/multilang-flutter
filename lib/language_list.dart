import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:multilang/settings_screen/language.dart';
import 'package:multilang/services/sqlite_service.dart';
import 'package:multilang/services/translation.dart';
import 'package:multilang/services/utils.dart';

class LanguageList extends StatefulWidget {
  final List<Language> enabledLanguages;
  final List<Translation> translations;

  const LanguageList({Key? key, required this.enabledLanguages, required this.translations}) : super(key: key);

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  late SqliteService _sqliteService;
  List<Translation> _translations = [];
  late List<Language> _enabledLanguages = [];
  final List<String> _rtlLanguages = ['ara', 'heb', 'fas', 'yid'];

 @override
  void initState() {
    super.initState();
    _sqliteService = SqliteService();
    _sqliteService.initializeDB().whenComplete(() async {
      await _refreshLanguages();
      debugPrint('[languages_list] [init] ====== Enabled Languages: $_enabledLanguages');
      setState(() { 
        _translations = widget.translations;
        debugPrint('[languages_list] [init]====== Received ${_translations.toString()}');
      });
    });
  }

  // This function is used to run a state change with the latest DB data
  Future<void> _refreshLanguages() async {  
    final data = await _sqliteService.getLanguages();
    data.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    setState(() {
      _enabledLanguages = data.where((lang) => lang.active == 1).toList();
    });
    debugPrint('[languages_list] [refresh] ====== Enabled Languages: $_enabledLanguages');
    printOrder('refresh', _enabledLanguages);
  }

  Future<void> _saveOrder(enabledLanguages) async {
    for (var index = 0; index < enabledLanguages.length; index++) {
      Map<String, dynamic> currentLanguage = enabledLanguages[index].toMap();
      currentLanguage['displayOrder'] = index;
      await _sqliteService.updateLanguage(Language.fromMap(currentLanguage));
    }
    await _refreshLanguages();
  }

  void printOrder(context, list) {
    debugPrint('[languages_list] [$context] ====== Order:');
    for (Language lang in list) {
      debugPrint('[languages_list] [$context] ============ : ${lang.displayOrder} - ${lang.code}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    printOrder("build", _enabledLanguages);
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final language = _enabledLanguages.removeAt(oldIndex);
          _enabledLanguages.insert(newIndex, language); // Render current reordered state
          printOrder('onReOrder', _enabledLanguages);
          _saveOrder(_enabledLanguages); // Save current reordered state, and trigger a re-render will updated data from DB
        });
      },
      children: _enabledLanguages.map((language) {
        List<Translation> currentTranslation = _translations.where((translation) => translation.target == language.code).toList();
        debugPrint("[languages_list] [build] ============ : ${currentTranslation.toString()} - ${currentTranslation.length}");
        String toDisplay = currentTranslation.isNotEmpty ? currentTranslation.first.text : "";
        return Card(
          key: ValueKey(language.code),
          shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Colors.blue),
              borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
            leading: CircleAvatar(
              child: Text(language.code),
            ),
            title: Text(
              toDisplay,
              textDirection: _rtlLanguages.singleWhere(
                (element) => element == language.code, orElse: () => 'ltr') != 'ltr' ? TextDirection.rtl : TextDirection.ltr,
              ),
            trailing: PopupMenuButton(
              onSelected: (value) {
                debugPrint("[languages_list] [onSelectedMenuOption] Selected: $value");
                switch(value) {
                  case "copy":
                    Clipboard.setData(ClipboardData(text: toDisplay)).then((_) {
                      showBanner(context, "Copied translation to clipboard!", const Duration(seconds: 1));
                    });
                    break;
                  case "listen":
                    showBanner(context, "Feature not supported yet!", const Duration(seconds: 1));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: "copy",
                  child: Text("Copy"),
                ),
                const PopupMenuItem(
                  value: "listen",
                  child: Text("Listen"),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
