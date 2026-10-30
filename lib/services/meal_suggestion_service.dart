import '../models/food.dart';

class MealSuggestionService {
  // Get the food price based on the selected establishment.
  int getFoodPrice(Food food, String establishment) {
    switch (establishment.toLowerCase()) {
      case 'canteen':
        return food.canteenPrice;

      case 'carinderia':
        return food.carinderiaPrice;

      case 'restaurant':
        return ((food.restaurantMinPrice + food.restaurantMaxPrice) / 2)
            .round();

      default:
        return food.canteenPrice;
    }
  }

  // Find foods that fit within the user's budget.
  List<Food> getAffordableFoods({
    required List<Food> foods,
    required double budget,
    required String establishment,
  }) {
    final affordableFoods = foods.where((food) {
      final price = getFoodPrice(food, establishment);
      return price <= budget;
    }).toList();

    // Show the most affordable foods first.
    affordableFoods.sort((a, b) {
      return getFoodPrice(
        a,
        establishment,
      ).compareTo(getFoodPrice(b, establishment));
    });

    return affordableFoods;
  }
}
