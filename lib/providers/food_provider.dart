import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../models/food.dart';
import '../services/meal_suggestion_service.dart';

class FoodProvider extends ChangeNotifier {
  final AppDatabase _database = AppDatabase.instance;
  final MealSuggestionService _suggestionService = MealSuggestionService();

  List<Food> _foods = [];
  List<Food> _suggestions = [];

  bool _isLoading = false;
  String? _errorMessage;

  double _budget = 50.0;
  String _establishment = 'canteen';

  List<Food> get foods => _foods;
  List<Food> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get budget => _budget;
  String get establishment => _establishment;

  // Load food records from the local database.
  Future<void> loadFoods() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _foods = await _database.getFoods();
      updateSuggestions();
    } catch (error) {
      _errorMessage = 'Unable to load foods: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change the user's available budget.
  void setBudget(double newBudget) {
    if (newBudget < 0) return;

    _budget = newBudget;
    updateSuggestions();
    notifyListeners();
  }

  // Change where the user plans to buy food.
  void setEstablishment(String newEstablishment) {
    _establishment = newEstablishment;
    updateSuggestions();
    notifyListeners();
  }

  // Refresh the list of affordable food suggestions.
  void updateSuggestions() {
    _suggestions = _suggestionService.getAffordableFoods(
      foods: _foods,
      budget: _budget,
      establishment: _establishment,
    );
  }

  // Add a new food to the database.
  Future<void> addFood(Food food) async {
    await _database.insertFood(food);
    await loadFoods();
  }
}
