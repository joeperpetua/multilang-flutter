import 'package:flutter/material.dart';

// import 'package:multilang/settings_screen/language.dart';
import 'package:multilang/services/sqlite_service.dart';


class LanguageList extends StatefulWidget {
  final List<Language> enabledLanguages;
  final String text;

  const LanguageList({Key? key, required this.enabledLanguages, required this.text}) : super(key: key);

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  late SqliteService _sqliteService;
  String _text = '';
  late List<Language> _enabledLanguages = [];

 @override
  void initState() {
    super.initState();
    _sqliteService = SqliteService();
    _sqliteService.initializeDB().whenComplete(() async {
      await _refreshLanguages();
      debugPrint('[languages_list] [init] ====== Enabled Languages: $_enabledLanguages');
      setState(() { 
        _text = widget.text;
        debugPrint('[languages_list] [init]====== Received $_text');
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
    debugPrint('[translate_screen] [refresh] ====== Enabled Languages: $_enabledLanguages');
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
    debugPrint('[translate_screen] [$context] ====== Order:');
    for (Language lang in list) {
      debugPrint('[translate_screen] [$context] ============ : ${lang.displayOrder} - ${lang.code}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final language = _enabledLanguages.removeAt(oldIndex);
        _enabledLanguages.insert(newIndex, language);
        printOrder('onReOrder', _enabledLanguages);
        await _saveOrder(_enabledLanguages);
      },
      children: _enabledLanguages.map((language) {
        return Card(
          key: ValueKey(language.code),
          shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Colors.blue),
              borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(language.code),
              ),
              title: Text(_text),
              // subtitle: Text(language.native),
              onTap: () {
                // Add your onTap functionality here
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
