class MealLog {
  final int? id;
  final int foodId;
  final String foodName;
  final String mealType;
  final double servings;
  final double pricePaid;
  final DateTime dateEaten;

  MealLog({
    this.id,
    required this.foodId,
    required this.foodName,
    required this.mealType,
    required this.servings,
    required this.pricePaid,
    required this.dateEaten,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_id': foodId,
      'food_name': foodName,
      'meal_type': mealType,
      'servings': servings,
      'price_paid': pricePaid,
      'date_eaten': dateEaten.toIso8601String(),
    };
  }

  factory MealLog.fromMap(Map<String, dynamic> map) {
    return MealLog(
      id: map['id'] as int?,
      foodId: map['food_id'] as int,
      foodName: map['food_name'] as String,
      mealType: map['meal_type'] as String,
      servings: (map['servings'] as num).toDouble(),
      pricePaid: (map['price_paid'] as num).toDouble(),
      dateEaten: DateTime.parse(map['date_eaten'] as String),
    );
  }
}
