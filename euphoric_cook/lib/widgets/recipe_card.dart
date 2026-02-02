import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';

class RecipeCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final int? servings;
  final int? totalTimeMinutes;
  final String? alcoholType;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.name,
    this.imageUrl,
    this.servings,
    this.totalTimeMinutes,
    this.alcoholType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.78,
        child: Card(
          elevation: mode.isDark ? 3 : 2,
          color: mode.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image section - takes remaining space
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: mode.accentColor.withOpacity(0.12),
                    image: imageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: imageUrl == null
                      ? Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 60,
                      color: mode.accentColor.withOpacity(0.4),
                    ),
                  )
                      : null,
                ),
              ),

              // Details section - fixed layout
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fixed-height single-line title with ellipsis (...)
                    SizedBox(
                      height: 22,  // fixed height - tune between 20-24 if needed
                      width: double.infinity,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: mode.textColor,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Food mode: time and servings on separate lines
                    if (mode.isFood) ...[
                      if (totalTimeMinutes != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: mode.textColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$totalTimeMinutes min',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mode.textColor.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (servings != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 14,
                              color: mode.textColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$servings servings',
                              style: TextStyle(
                                fontSize: 12,
                                color: mode.textColor.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                    ]

                    // Drink mode: alcohol type indicator
                    else ...[
                      Builder(
                        builder: (context) {
                          final type = (alcoholType ?? 'optional').toLowerCase();
                          IconData icon;
                          String label;
                          Color? color;

                          switch (type) {
                            case 'alcoholic':
                              icon = Icons.local_bar_rounded;
                              label = 'Alcoholic';
                              color = Colors.red.withOpacity(0.85);
                              break;
                            case 'non-alcoholic':
                              icon = Icons.no_drinks_rounded;
                              label = 'Non-alcoholic';
                              color = Colors.green.withOpacity(0.85);
                              break;
                            default:
                              icon = Icons.wine_bar_outlined;
                              label = 'Alcohol optional';
                              color = mode.textColor.withOpacity(0.7);
                          }

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 14, color: color),
                              const SizedBox(width: 5),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}