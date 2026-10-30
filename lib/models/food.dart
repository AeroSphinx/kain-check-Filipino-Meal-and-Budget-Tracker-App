class Food {
  final int? id;
  final String category;
  final String name;
  final int canteenPrice;
  final int carinderiaPrice;
  final int restaurantMinPrice;
  final int restaurantMaxPrice;
  final String servingSizeNotes;

  Food({
    this.id,
    required this.category,
    required this.name,
    required this.canteenPrice,
    required this.carinderiaPrice,
    required this.restaurantMinPrice,
    required this.restaurantMaxPrice,
    required this.servingSizeNotes,
  });

  // Convert food information into a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'canteen_price': canteenPrice,
      'carinderia_price': carinderiaPrice,
      'restaurant_min_price': restaurantMinPrice,
      'restaurant_max_price': restaurantMaxPrice,
      'serving_size_notes': servingSizeNotes,
    };
  }

  // Convert database information into a Food object.
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] as int?,
      category: map['category'] as String,
      name: map['name'] as String,
      canteenPrice: map['canteen_price'] as int,
      carinderiaPrice: map['carinderia_price'] as int,
      restaurantMinPrice: map['restaurant_min_price'] as int,
      restaurantMaxPrice: map['restaurant_max_price'] as int,
      servingSizeNotes: map['serving_size_notes'] as String,
    );
  }
}
