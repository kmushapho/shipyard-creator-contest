import 'dart:async';
import 'dart:convert';               // ← added for jsonDecode
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'recipes.db';
  static const String recipesTable = 'recipes';
  static const String tagsTable = 'recipe_tags';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, dbName);

    // Delete old DB during testing (remove this line later)
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $recipesTable (
        id INTEGER PRIMARY KEY,
        name TEXT,
        servings INTEGER,
        serving_size TEXT,
        steps TEXT,
        ingredients TEXT,
        ingredients_raw TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tagsTable (
        recipe_id INTEGER,
        tag TEXT,
        PRIMARY KEY (recipe_id, tag)
      )
    ''');
  }

  /// Import the CSV (call this once, e.g. on first launch)
  Future<void> importCsvFromAssets(String assetPath) async {
    final db = await database;

    // Load CSV from assets
    final String csvString = await rootBundle.loadString(assetPath);
    final List<List<dynamic>> rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(csvString);

    if (rows.isEmpty) return;
    rows.removeAt(0); // remove header row

    final Batch batch = db.batch();
    int count = 0;

    for (final row in rows) {
      if (row.length < 10) continue; // skip bad rows

      try {
        // Real column order in recipes_w_search_terms.csv
        final int id = int.tryParse(row[0]?.toString() ?? '0') ?? 0;
        final String name = row[1]?.toString() ?? '';
        final String servingsStr = row[6]?.toString() ?? '0';
        final int servings = int.tryParse(servingsStr) ?? 0;
        final String servingSize = row[5]?.toString() ?? '';

        final String stepsStr = row[7]?.toString() ?? '[]';
        final String ingredientsStr = row[3]?.toString() ?? '[]';
        final String ingredientsRaw = row[4]?.toString() ?? '';

        // Insert recipe
        batch.insert(
          recipesTable,
          {
            'id': id,
            'name': name,
            'servings': servings,
            'serving_size': servingSize,
            'steps': stepsStr,           // keep original JSON string
            'ingredients': ingredientsStr,
            'ingredients_raw': ingredientsRaw,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Parse tags (column 8) – handles ['vegan', 'easy', ...]
        final String tagsStr = row[8]?.toString() ?? '[]';
        List<dynamic> tagsList = [];
        try {
          // Replace single quotes so jsonDecode works
          final String fixed = tagsStr.replaceAll("'", '"');
          tagsList = jsonDecode(fixed) as List<dynamic>;
        } catch (e) {
          // fallback if parsing fails
          tagsList = [];
        }

        for (final tag in tagsList) {
          final String cleanTag = tag?.toString().trim() ?? '';
          if (cleanTag.isNotEmpty) {
            batch.insert(
              tagsTable,
              {'recipe_id': id, 'tag': cleanTag},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }

        count++;
        if (count % 500 == 0) {
          await batch.commit(noResult: true);
          print('Imported $count recipes so far...');
        }
      } catch (e) {
        print('Skipped bad row: $e');
      }
    }

    await batch.commit(noResult: true);
    print('✅ Import finished! Total recipes: $count');
  }

  // Example: get all vegan recipes
  Future<List<Map<String, dynamic>>> getRecipesByTag(String tag) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT r.* 
      FROM $recipesTable r
      JOIN $tagsTable t ON r.id = t.recipe_id
      WHERE t.tag = ?
    ''', [tag]);
  }
}