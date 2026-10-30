import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/food_provider.dart';
import 'providers/meal_log_provider.dart';
import 'screens/meal_logging_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()..loadFoods()),
        ChangeNotifierProvider(
          create: (_) => MealLogProvider()..loadMealLogs(),
        ),
      ],
      child: const KainCheckApp(),
    ),
  );
}

class KainCheckApp extends StatelessWidget {
  const KainCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KAIN CHECK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeNavigationPage(),
    );
  }
}

class HomeNavigationPage extends StatefulWidget {
  const HomeNavigationPage({super.key});

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [FoodSuggestionPage(), MealLoggingPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Food Suggestions',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Meal Logging',
          ),
        ],
      ),
    );
  }
}

class FoodSuggestionPage extends StatelessWidget {
  const FoodSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KAIN CHECK')),
      body: Consumer<FoodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ano ang Kakainin?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Text('Budget: ₱${provider.budget.toStringAsFixed(0)}'),

                Slider(
                  value: provider.budget.clamp(0, 500).toDouble(),
                  min: 0,
                  max: 500,
                  divisions: 50,
                  label: '₱${provider.budget.toStringAsFixed(0)}',
                  onChanged: provider.setBudget,
                ),

                const SizedBox(height: 10),

                const Text('Where will you buy your food?'),

                DropdownButton<String>(
                  value: provider.establishment,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'canteen', child: Text('Canteen')),
                    DropdownMenuItem(
                      value: 'carinderia',
                      child: Text('Carinderia'),
                    ),
                    DropdownMenuItem(
                      value: 'restaurant',
                      child: Text('Small Restaurant'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setEstablishment(value);
                    }
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Affordable Food Suggestions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                Expanded(
                  child: provider.suggestions.isEmpty
                      ? const Center(
                          child: Text(
                            'No food suggestions yet. '
                            'Food data may not have been added.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.suggestions.length,
                          itemBuilder: (context, index) {
                            final food = provider.suggestions[index];

                            return ListTile(
                              leading: const Icon(Icons.restaurant),
                              title: Text(food.name),
                              subtitle: Text(food.category),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
