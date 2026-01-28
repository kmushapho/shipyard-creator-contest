import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mode_provider.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ModeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();

    return MaterialApp(
      title: 'SpryCook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mode.mainColor,
          primary: mode.mainColor,
          surface: mode.backgroundColor,
        ),
        scaffoldBackgroundColor: mode.backgroundColor,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with logo + toggle
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      "SpryCook",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: mode.mainColor,
                      ),
                    ),
                    const Spacer(),
                    _buildToggle(mode),
                  ],
                ),
              ),

              // Search bar (changes text when mode changes)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: SearchBar(
                    key: ValueKey(mode.current),
                    leading: const Icon(Icons.search),
                    hintText: mode.searchPlaceholder,
                    backgroundColor: WidgetStatePropertyAll(mode.lightColor),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Horizontal chips
              SizedBox(
                height: 48,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: mode.chipList.length,
                  itemBuilder: (context, index) {
                    final item = mode.chipList[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(item["text"]),
                        backgroundColor: mode.lightColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Fake featured recipes (you can replace later)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Featured Recipes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Simple grid of cards (2 columns)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Card(
                      color: mode.lightColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              color: mode.mainColor.withOpacity(0.1),
                              child: const Center(child: Icon(Icons.image, size: 50)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Recipe ${index + 1}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 100), // space so bottom nav doesn't cover content
            ],
          ),
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: NavigationBar(
        indicatorColor: mode.mainColor.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Cookbook'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.person), label: 'You'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {},
      ),
    );
  }

  Widget _buildToggle(ModeProvider mode) {
    return GestureDetector(
      onTap: mode.switchMode,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: mode.mainColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: mode.current == AppMode.food ? mode.mainColor : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "Food",
                style: TextStyle(
                  color: mode.current == AppMode.food ? Colors.white : mode.mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: mode.current == AppMode.drink ? mode.mainColor : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "Drink",
                style: TextStyle(
                  color: mode.current == AppMode.drink ? Colors.white : mode.mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}