import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:multilang/services/languages.dart';

class SqliteService {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    debugPrint(join(path, 'multilang.db'));
    return openDatabase(join(path, 'multilang.db'), onCreate: (database, version) async {
        await database.execute( 
          'CREATE TABLE settings(id INTEGER PRIMARY KEY AUTOINCREMENT, appLanguage TEXT, inputText TEXT);',
        );
        String settingsCreation = 'INSERT into settings(appLanguage, inputText) VALUES("eng", "")';
        await database.rawInsert(settingsCreation);

        await database.execute( 
          'CREATE TABLE languages(id INTEGER PRIMARY KEY AUTOINCREMENT, displayText TEXT, native TEXT, code TEXT, active INTEGER, displayOrder INTEGER);',
        );

        for (var language in languages) {
          String insertQuery = 'INSERT into languages(displayText, native, code, active, displayOrder) VALUES("${language['name']!}", "${language['native']}", "${language['code']!}", 0, -1)';
          await database.rawInsert(insertQuery);
        }
      },
      version: 1,
    );
  }

  // Define a function that inserts languages into the database
  Future<void> createLanguage(Language language) async {
    // Get a reference to the database.
    final Database db = await initializeDB();
    await db.insert(
      'languages',
      language.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateLanguage(Language language) async {
    // Get a reference to the database.
    final Database db = await initializeDB();

    // Update the given Language.
    await db.update(
      'languages',
      language.toMap(),
      // Ensure that the Language has a matching id.
      where: 'id = ?',
      // Pass the Language's id as a whereArg to prevent SQL injection.
      whereArgs: [language.id],
    );
  }

  // A method that retrieves all the items from the languages table.
  Future<List<Language>> getLanguages() async {
    // Get a reference to the database.
    final Database db = await initializeDB();

    // Query the table for all the languages.
    final List<Map<String, Object?>> languagesMaps = await db.query('languages');
    
    // Convert the list of each language's fields into a list of `Language` objects.
    return [
      for (var languageMap in languagesMaps)
      Language(
        id: languageMap['id'] as int,
        displayText: languageMap['displayText'] as String,
        native: languageMap['native'] as String,
        code: languageMap['code'] as String,
        active: languageMap['active'] as int,
        displayOrder: languageMap['displayOrder'] as int,
      ),
    ];

  }

  Future<Settings> getSettings() async {
    // Get a reference to the database.
    final Database db = await initializeDB();

    // Query the table for all the languages.
    final List<Map<String, Object?>> settingsMap = await db.query('settings');
    
    return Settings.fromMap(settingsMap[0]);
  }

  Future<void> updateSettings(Settings settings) async {
    // Get a reference to the database.
    final Database db = await initializeDB();

    // Update the given Language.
    await db.update(
      'settings',
      settings.toMap(),
      // Ensure that the Language has a matching id.
      where: 'id = ?',
      // Pass the Language's id as a whereArg to prevent SQL injection.
      whereArgs: [settings.id],
    );
  }
}

class Language {
  final int id;
  final String displayText;
  final String native;
  final String code;
  final int active;
  final int displayOrder;

  // set active(int data) {
  //   active = data;
  // }

  // set displayOrder(int order) {
  //   displayOrder = order;
  // }

  const Language({
    required this.id,
    required this.displayText,
    required this.native,
    required this.code,
    required this.active,
    required this.displayOrder,
  });

  Language.fromMap(Map<String, dynamic> item):
    id = item["id"],
    displayText = item["displayText"],
    native = item["native"],
    code = item["code"],
    active = item["active"],
    displayOrder = item["displayOrder"];


  // Convert a Language into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayText': displayText,
      'native': native,
      'code': code,
      'active': active,
      'displayOrder': displayOrder,
    };
  }

  bool isActive() {
    return active == 1 ? true : false;
  }

  @override
  String toString() {
    return 'Language{id: $id, displayText: $displayText, native: $native, code: $code, active: $active, displayOrder: $displayOrder}';
  }
}

class Settings {
  final int id;
  final String appLanguage;
  final String inputText;

  const Settings({
    required this.id,
    required this.appLanguage,
    required this.inputText,
  });

  Settings.fromMap(Map<String, dynamic> item):
    id = item["id"],
    appLanguage = item["appLanguage"],
    inputText = item["inputText"];


  // Convert a Language into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appLanguage': appLanguage,
      'inputText': inputText,
    };
  }
}