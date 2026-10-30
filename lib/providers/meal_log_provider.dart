import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../models/meal_log.dart';

class MealLogProvider extends ChangeNotifier {
  final AppDatabase _database = AppDatabase.instance;

  List<MealLog> _mealLogs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MealLog> get mealLogs => _mealLogs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMealLogs([DateTime? date]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mealLogs = await _database.getMealLogsByDate(date ?? DateTime.now());
    } catch (error) {
      _errorMessage = 'Unable to load meal logs: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMealLog(MealLog meal) async {
    try {
      await _database.insertMealLog(meal);
      await loadMealLogs(meal.dateEaten);
    } catch (error) {
      _errorMessage = 'Unable to save meal: $error';
      notifyListeners();
    }
  }

  Future<void> deleteMealLog(int id) async {
    try {
      await _database.deleteMealLog(id);
      await loadMealLogs();
    } catch (error) {
      _errorMessage = 'Unable to delete meal: $error';
      notifyListeners();
    }
  }
}
