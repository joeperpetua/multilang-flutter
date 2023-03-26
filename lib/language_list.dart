import 'package:flutter/material.dart';

import 'package:multilang/settings_screen/language.dart';


class LanguageList extends StatefulWidget {
  final List<Language> selectedLanguages;
  final String data;

  const LanguageList({Key? key, required this.selectedLanguages, required this.data}) : super(key: key);

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  late List<Language> _selectedLanguages;
  late String _data;

  @override
  void initState() {
    super.initState();
    _selectedLanguages = List.from(widget.selectedLanguages);
    _data = widget.data;
    debugPrint('====== Received $_data');
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final language = _selectedLanguages.removeAt(oldIndex);
          _selectedLanguages.insert(newIndex, language);
        });
      },
      children: _selectedLanguages.map((language) {
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

  @override
  void dispose() {
    super.dispose();
    widget.selectedLanguages.clear();
    widget.selectedLanguages.addAll(_selectedLanguages);
  }
}
