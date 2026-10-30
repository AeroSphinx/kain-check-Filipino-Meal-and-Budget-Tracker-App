import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/food.dart';
import '../models/meal_log.dart';
import '../models/user_settings.dart';
import 'food_seed_data.dart';

class AppDatabase {
  AppDatabase._privateConstructor();

  static final AppDatabase instance = AppDatabase._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'kain_check.db');

    final db = await openDatabase(path, version: 1, onCreate: _createTables);

    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM foods'),
        ) ??
        0;

    if (count == 0) {
      final batch = db.batch();

      for (final food in initialFoods) {
        final data = food.toMap();
        data.remove('id');
        batch.insert('foods', data);
      }

      await batch.commit(noResult: true);
    }

    return db;
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        canteen_price INTEGER NOT NULL,
        carinderia_price INTEGER NOT NULL,
        restaurant_min_price INTEGER NOT NULL,
        restaurant_max_price INTEGER NOT NULL,
        serving_size_notes TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER NOT NULL,
        food_name TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        servings REAL NOT NULL,
        price_paid REAL NOT NULL,
        date_eaten TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY,
        daily_budget REAL NOT NULL,
        daily_calorie_goal REAL NOT NULL,
        daily_protein_goal REAL NOT NULL
      )
    ''');

    await db.insert('user_settings', {
      'id': 1,
      'daily_budget': 150.0,
      'daily_calorie_goal': 2000.0,
      'daily_protein_goal': 50.0,
    });
  }

  Future<int> insertFood(Food food) async {
    final db = await database;
    final data = food.toMap();
    data.remove('id');

    return await db.insert('foods', data);
  }

  Future<List<Food>> getFoods() async {
    final db = await database;

    final result = await db.query('foods', orderBy: 'name ASC');

    return result.map((map) => Food.fromMap(map)).toList();
  }

  Future<int> insertMealLog(MealLog meal) async {
    final db = await database;
    final data = meal.toMap();
    data.remove('id');

    return await db.insert('meal_logs', data);
  }

  Future<List<MealLog>> getMealLogsByDate(DateTime date) async {
    final db = await database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfNextDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'meal_logs',
      where: 'date_eaten >= ? AND date_eaten < ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        startOfNextDay.toIso8601String(),
      ],
      orderBy: 'date_eaten ASC',
    );

    return result.map((map) => MealLog.fromMap(map)).toList();
  }

  Future<int> deleteMealLog(int id) async {
    final db = await database;

    return await db.delete('meal_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<UserSettings> getUserSettings() async {
    final db = await database;

    final result = await db.query(
      'user_settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    return UserSettings.fromMap(result.first);
  }

  Future<int> saveUserSettings(UserSettings settings) async {
    final db = await database;

    return await db.insert('user_settings', {
      'id': 1,
      'daily_budget': settings.dailyBudget,
      'daily_calorie_goal': settings.dailyCalorieGoal,
      'daily_protein_goal': settings.dailyProteinGoal,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
