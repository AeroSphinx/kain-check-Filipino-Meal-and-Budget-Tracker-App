class UserSettings {
  final int? id;
  final double dailyBudget;
  final double dailyCalorieGoal;
  final double dailyProteinGoal;

  UserSettings({
    this.id,
    required this.dailyBudget,
    required this.dailyCalorieGoal,
    required this.dailyProteinGoal,
  });

  // Convert user settings into a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_budget': dailyBudget,
      'daily_calorie_goal': dailyCalorieGoal,
      'daily_protein_goal': dailyProteinGoal,
    };
  }

  // Convert database information into a UserSettings object.
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as int?,
      dailyBudget: (map['daily_budget'] as num).toDouble(),
      dailyCalorieGoal: (map['daily_calorie_goal'] as num).toDouble(),
      dailyProteinGoal: (map['daily_protein_goal'] as num).toDouble(),
    );
  }
}
