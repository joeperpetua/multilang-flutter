import 'package:flutter/material.dart';

// import 'package:multilang/settings_screen/language.dart';
import 'package:multilang/services/sqlite_service.dart';


class LanguageList extends StatefulWidget {
  final List<Language> enabledLanguages;
  final String data;

  const LanguageList({Key? key, required this.enabledLanguages, required this.data}) : super(key: key);

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  late SqliteService _sqliteService;
  String _data = '';
  late List<Language> _enabledLanguages = [];

 @override
  void initState() {
    super.initState();
    
    _sqliteService = SqliteService();
    _sqliteService.initializeDB().whenComplete(() async {
      await _refreshLanguages();
      debugPrint('[languages_list] ====== Enabled Languages: $_enabledLanguages');
      setState(() { 
        _data = widget.data;
        debugPrint('[languages_list] ====== Received $_data');
      });
    });
    
  }

  // This function is used to run a state change with the latest DB data
  Future<void> _refreshLanguages() async {  
    final data = await _sqliteService.getLanguages();
    setState(() {
      _enabledLanguages = data.where((lang) => lang.active == 1).toList();
    });
    debugPrint('[translate_screen] ====== Enabled Languages: $_enabledLanguages');
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final language = _enabledLanguages.removeAt(oldIndex);
          _enabledLanguages.insert(newIndex, language);
        });
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
              title: Text(_data),
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

  // @override
  // void dispose() {
  //   super.dispose();
  //   widget.enabledLanguages.clear();
  //   widget.enabledLanguages.addAll(_enabledLanguages);
  // }
}
