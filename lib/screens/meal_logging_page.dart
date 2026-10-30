import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal_log.dart';
import '../providers/food_provider.dart';
import '../providers/meal_log_provider.dart';

class MealLoggingPage extends StatefulWidget {
  const MealLoggingPage({super.key});

  @override
  State<MealLoggingPage> createState() => _MealLoggingPageState();
}

class _MealLoggingPageState extends State<MealLoggingPage> {
  int? selectedFoodId;
  String selectedMealType = 'Breakfast';

  final servingsController = TextEditingController(text: '1');
  final priceController = TextEditingController();

  @override
  void dispose() {
    servingsController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveMeal() async {
    final foodProvider = context.read<FoodProvider>();
    final mealProvider = context.read<MealLogProvider>();

    final servings = double.tryParse(servingsController.text);
    final price = double.tryParse(priceController.text);

    if (selectedFoodId == null ||
        servings == null ||
        servings <= 0 ||
        price == null ||
        price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid meal information.')),
      );
      return;
    }

    final selectedFood = foodProvider.foods.firstWhere(
      (food) => food.id == selectedFoodId,
    );

    final meal = MealLog(
      foodId: selectedFood.id!,
      foodName: selectedFood.name,
      mealType: selectedMealType,
      servings: servings,
      pricePaid: price,
      dateEaten: DateTime.now(),
    );

    await mealProvider.addMealLog(meal);

    if (!mounted) return;

    if (mealProvider.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mealProvider.errorMessage!)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Meal saved successfully!')));

    servingsController.text = '1';
    priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final mealProvider = context.watch<MealLogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Logging')),
      body: foodProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text(
                    'Record Your Meal',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Food'),
                  DropdownButtonFormField<int>(
                    initialValue: selectedFoodId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Choose a food',
                    ),
                    items: foodProvider.foods.map((food) {
                      return DropdownMenuItem<int>(
                        value: food.id,
                        child: Text(food.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedFoodId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Meal Type'),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMealType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Breakfast',
                        child: Text('Breakfast'),
                      ),
                      DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                      DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                      DropdownMenuItem(value: 'Snack', child: Text('Snack')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedMealType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Number of Servings'),
                  TextField(
                    controller: servingsController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Example: 1 or 1.5',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Price Paid (₱)'),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter amount paid',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: mealProvider.isLoading ? null : saveMeal,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Meal'),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Today's Meal History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (mealProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (mealProvider.mealLogs.isEmpty)
                    const Text('No meals recorded today yet.')
                  else
                    ...mealProvider.mealLogs.map((meal) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.restaurant),
                          title: Text(meal.foodName),
                          subtitle: Text(
                            '${meal.mealType} • ${meal.servings} serving(s)',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₱${meal.pricePaid.toStringAsFixed(2)}'),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  mealProvider.deleteMealLog(meal.id!);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
