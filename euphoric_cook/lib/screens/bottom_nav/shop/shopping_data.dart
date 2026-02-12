import 'shopping_model.dart';

class ShoppingData {
  // SINGLE INSTANCE (shared everywhere)
  static final ShoppingData instance = ShoppingData._internal();
  ShoppingData._internal();

  // SMART LISTS
  final SmartList foodList = SmartList(name: "Food Smart List");
  final SmartList drinkList = SmartList(name: "Drink Smart List");
  final SmartList foodDrinkList = SmartList(name: "Food & Drink");
  final SmartList mealPlanner = SmartList(name: "Meal Planner");

  // BY RECIPE
  final Map<String, SmartList> recipeLists = {};

  // MANUAL LISTS
  final List<ManualList> manualLists = [
    ManualList(
      name: "Groceries",
      createdAt: DateTime.now(),
      items: [],
    ),
  ];

  // ---------------- ADD METHODS ----------------

  void addItemToFood(String name) {
    foodList.items.add(ShoppingItem(name: name));
  }

  void addItemToDrink(String name) {
    drinkList.items.add(ShoppingItem(name: name));
  }

  void addItemToFoodDrink(String name) {
    foodDrinkList.items.add(ShoppingItem(name: name));
  }

  // ADD FROM RECIPE
  void addRecipe(String recipeName, List<String> ingredients) {
    if (!recipeLists.containsKey(recipeName)) {
      recipeLists[recipeName] = SmartList(name: recipeName);
    }

    for (var ingredient in ingredients) {
      recipeLists[recipeName]!.items.add(ShoppingItem(name: ingredient));
    }
  }
}
