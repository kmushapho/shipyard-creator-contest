import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mode_provider.dart';
import '../../providers/user_provider.dart';
import '../onboarding/auth_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: mode.bgColor,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: mode.bgColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _UserHeader(user: user, mode: mode),
          const SizedBox(height: 20),
          _PremiumCard(accent: mode.accentColor),
          const SizedBox(height: 30),
          _PreferencesSection(user: user, mode: mode),
          const SizedBox(height: 20),
          _TagsSection(user: user),
          const SizedBox(height: 24),
          _FoodsToAvoidSection(user: user),
          const SizedBox(height: 20),
          _PantrySection(user: user),
          const SizedBox(height: 30),
          if (!user.isGuest)
            Center(
              child: OutlinedButton.icon(
                onPressed: user.logoutToGuest,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final dynamic mode;
  final UserProvider user;
  const _UserHeader({required this.user, required this.mode});

  @override
  Widget build(BuildContext context) {
    final accent = mode.accentColor;
    final textColor = mode.textPrimary;

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: accent.withOpacity(0.15),
          child: Icon(Icons.person, color: accent, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (user.isGuest) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                  );
                }
              },
              child: Text(
                user.isGuest ? "Sign in to sync your data" : "Logged in",
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.6),
                  decoration: user.isGuest ? TextDecoration.underline : null,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Color accent;
  const _PremiumCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Euphoric Cook Premium",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Unlimited meal plans, no ads, advanced features & more",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 14),
          Center(
            child: Text(
              "Upgrade Now",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  final dynamic mode;
  final UserProvider user;
  const _PreferencesSection({required this.user, required this.mode});

  @override
  Widget build(BuildContext context) {
    final accent = mode.accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section("Preferences"),
        _tile(
          icon: Icons.dark_mode,
          title: "Switch to Dark Mode",
          trailing: Switch(
            value: mode.isDark,
            onChanged: (_) => mode.toggleTheme(),
            activeColor: accent,
          ),
        ),
        _tile(
          icon: Icons.straighten,
          title: "Units: ${user.isMetric ? 'Metric' : 'Imperial'}",
          trailing: Switch(
            value: user.isMetric,
            onChanged: (v) => user.setMetric(v),
            activeColor: accent,
          ),
        ),
        _tile(icon: Icons.notifications, title: "Notifications"),
      ],
    );
  }
}

class _TagsSection extends StatelessWidget {
  final UserProvider user;
  const _TagsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MultiSelectDropdown(title: "Dietary Restrictions", items: [
          "Vegetarian",
          "Vegan",
          "Gluten-Free",
          "Dairy-Free",
          "Kosher",
          "Halal",
          "Paleo",
          "Pescatarian",
        ], user: user),
        const SizedBox(height: 20),
        _MultiSelectDropdown(title: "Nutritional & Health Tags", items: [
          "Healthy",
          "Low Calorie",
          "Low Carb",
          "Low Fat",
          "Low Sodium",
          "Low Sugar",
          "Low Cholesterol",
          "High Fiber",
          "Kidney Friendly",
        ], user: user),
        const SizedBox(height: 20),
        _MultiSelectDropdown(title: "Allergy-Specific Tags", items: [
          "Peanut Free",
          "Soy Free",
          "Tree Nut Free",
          "Shellfish Free",
        ], user: user),
      ],
    );
  }
}

class _FoodsToAvoidSection extends StatefulWidget {
  final UserProvider user;
  const _FoodsToAvoidSection({required this.user});

  @override
  State<_FoodsToAvoidSection> createState() => _FoodsToAvoidSectionState();
}

class _FoodsToAvoidSectionState extends State<_FoodsToAvoidSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section("Foods to Avoid"),
        Wrap(
          spacing: 10,
          children: widget.user.foodsToAvoid
              .map((f) => Chip(
            label: Text(f),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () {
              setState(() {
                widget.user.removeFoodToAvoid(f);
              });
            },
          ))
              .toList(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showDialog(),
          icon: const Icon(Icons.add),
          label: const Text("Add food to avoid"),
        ),
      ],
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Food to Avoid"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "e.g. peanuts"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                setState(() {
                  widget.user.addFoodToAvoid(text);
                });
                _controller.clear();
                Navigator.pop(context);
              },
              child: const Text("Add")),
        ],
      ),
    );
  }
}

class _PantrySection extends StatefulWidget {
  final UserProvider user;
  const _PantrySection({required this.user});

  @override
  State<_PantrySection> createState() => _PantrySectionState();
}

class _PantrySectionState extends State<_PantrySection> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section("Pantry Items"),
        Wrap(
          spacing: 10,
          children: widget.user.pantryItems
              .map((f) => Chip(
            label: Text(f),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () {
              setState(() {
                widget.user.removePantryItem(f);
              });
            },
          ))
              .toList(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showDialog(),
          icon: const Icon(Icons.add),
          label: const Text("Add pantry item"),
        ),
      ],
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Pantry Item"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "e.g. rice"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                setState(() {
                  widget.user.addPantryItem(text);
                });
                _controller.clear();
                Navigator.pop(context);
              },
              child: const Text("Add")),
        ],
      ),
    );
  }
}

// ─── UTILITY WIDGETS ─────────────────────
Widget _section(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    title.toUpperCase(),
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey,
    ),
  ),
);

Widget _tile({required IconData icon, required String title, Widget? trailing}) =>
    ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );

class _MultiSelectDropdown extends StatelessWidget {
  final String title;
  final List<String> items;
  final UserProvider user;

  const _MultiSelectDropdown({
    required this.title,
    required this.items,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: [
        SizedBox(
          height: items.length * 55, // fixed height for performance
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              return CheckboxListTile(
                title: Text(item),
                value: user.isTagSelected(item),
                onChanged: (_) => user.toggleTag(item),
              );
            },
          ),
        )
      ],
    );
  }
}
