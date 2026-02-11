import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// =====================
// Models
// =====================
class Meal {
  final String id;
  final String name;
  final List<String> ingredients;
  final int calories;
  bool eaten;

  Meal({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.calories,
    this.eaten = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'calories': calories,
      'eaten': eaten,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      ingredients: List<String>.from(map['ingredients']),
      calories: map['calories'],
      eaten: map['eaten'] ?? false,
    );
  }
}

class PantryItem {
  final String name;
  final int caloriesPerUnit;
  final String unit;

  PantryItem({
    required this.name,
    required this.caloriesPerUnit,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'caloriesPerUnit': caloriesPerUnit,
    'unit': unit,
  };

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      name: map['name'],
      caloriesPerUnit: map['caloriesPerUnit'],
      unit: map['unit'],
    );
  }
}

// =====================
// Main Page
// =====================
class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({Key? key}) : super(key: key);

  @override
  _MealPlannerPageState createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  Map<String, Map<String, Meal?>> weeklyPlanner = {
    "Monday": {"Breakfast": null, "Lunch": null, "Dinner": null},
    "Tuesday": {"Breakfast": null, "Lunch": null, "Dinner": null},
    "Wednesday": {"Breakfast": null, "Lunch": null, "Dinner": null},
    "Thursday": {"Breakfast": null, "Lunch": null, "Dinner": null},
    "Friday": {"Breakfast": null, "Lunch": null, "Dinner": null},
    "Saturday": {"Breakfast": null, "Lunch": null, "Dinner": null},
    "Sunday": {"Breakfast": null, "Lunch": null, "Dinner": null},
  };

  List<PantryItem> pantry = [];
  List<Meal> customMeals = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // =====================
  // Local Storage
  // =====================
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load planner
    for (var day in weeklyPlanner.keys) {
      for (var mealType in weeklyPlanner[day]!.keys) {
        final mealJson = prefs.getString('$day-$mealType');
        if (mealJson != null) {
          weeklyPlanner[day]![mealType] =
              Meal.fromMap(jsonDecode(mealJson));
        }
      }
    }

    // Load pantry
    final pantryJson = prefs.getStringList('pantry') ?? [];
    pantry = pantryJson
        .map((e) => PantryItem.fromMap(jsonDecode(e)))
        .toList();

    // Load custom meals
    final customJson = prefs.getStringList('customMeals') ?? [];
    customMeals = customJson.map((e) => Meal.fromMap(jsonDecode(e))).toList();

    setState(() {});
  }

  Future<void> _saveMeal(String day, String mealType, Meal meal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('$day-$mealType', jsonEncode(meal.toMap()));
  }

  Future<void> _savePantry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'pantry', pantry.map((e) => jsonEncode(e.toMap())).toList());
  }

  Future<void> _saveCustomMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'customMeals', customMeals.map((e) => jsonEncode(e.toMap())).toList());
  }

  // =====================
  // Open Food Facts fetch
  // =====================
  Future<int> fetchCalories(String product) async {
    final url =
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$product&search_simple=1&json=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null && data['products'].isNotEmpty) {
          final nutriments = data['products'][0]['nutriments'];
          if (nutriments != null && nutriments['energy-kcal_100g'] != null) {
            return (nutriments['energy-kcal_100g'] as num).round();
          }
        }
      }
    } catch (e) {
      print('Error fetching calories: $e');
    }
    return 100; // fallback
  }

  // =====================
  // Generate Meal
  // =====================
  Future<Meal> generateMealRandom(String mealType) async {
    String name;
    List<String> ingredients = [];
    int calories = 0;

    // Use pantry if available
    if (pantry.isNotEmpty) {
      final random = Random();
      final chosen = pantry[random.nextInt(pantry.length)];
      name = "${mealType}: ${chosen.name}";
      ingredients.add(chosen.name);
      calories = chosen.caloriesPerUnit;
    } else if (customMeals.isNotEmpty) {
      final random = Random();
      final chosen = customMeals[random.nextInt(customMeals.length)];
      name = chosen.name;
      ingredients = chosen.ingredients;
      calories = chosen.calories;
    } else {
      name = "Random $mealType";
      ingredients.add("Ingredient");
      calories = 200;
    }

    return Meal(
        id: "${DateTime.now().millisecondsSinceEpoch}",
        name: name,
        ingredients: ingredients,
        calories: calories);
  }

  Future<void> _generateMeal(String day, String mealType) async {
    setState(() => loading = true);
    final meal = await generateMealRandom(mealType);
    setState(() {
      weeklyPlanner[day]![mealType] = meal;
      loading = false;
    });
    _saveMeal(day, mealType, meal);
  }

  // =====================
  // Toggle eaten
  // =====================
  void _toggleEaten(String day, String mealType) {
    final meal = weeklyPlanner[day]![mealType];
    if (meal != null) {
      setState(() {
        meal.eaten = !meal.eaten;
      });
      _saveMeal(day, mealType, meal);
    }
  }

  // =====================
  // UI Widgets
  // =====================
  Widget _buildMealCard(String day, String mealType) {
    final meal = weeklyPlanner[day]![mealType];

    return Card(
      color: meal?.eaten ?? false ? Colors.green[100] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(meal?.name ?? "Tap to generate $mealType"),
        subtitle: Text(meal != null
            ? "${meal.calories} kcal | ${meal.ingredients.join(', ')}"
            : mealType),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _toggleEaten(day, mealType),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _generateMeal(day, mealType),
          ),
        ]),
      ),
    );
  }

  int _getCaloriesForDay(String day) {
    return weeklyPlanner[day]!.values
        .where((m) => m != null && m.eaten)
        .fold(0, (sum, m) => sum + (m?.calories ?? 0));
  }

  int _getCaloriesForWeek() {
    return weeklyPlanner.keys
        .fold(0, (sum, day) => sum + _getCaloriesForDay(day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Planner & Tracker"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text("Week Calories: ${_getCaloriesForWeek()} kcal",
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...weeklyPlanner.keys.map((day) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  ...['Breakfast', 'Lunch', 'Dinner']
                      .map((mealType) => _buildMealCard(day, mealType))
                      .toList(),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Example: Add a custom meal
          final meal = Meal(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: "My Custom Meal",
              ingredients: ["Ingredient1", "Ingredient2"],
              calories: 300);
          setState(() {
            customMeals.add(meal);
          });
          _saveCustomMeals();
        },
      ),
    );
  }
}
