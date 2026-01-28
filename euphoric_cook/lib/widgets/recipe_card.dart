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
      child: Card(
        elevation: mode.isDark ? 3 : 2,
        color: mode.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area – takes most of the space
            Expanded(
              flex: 5, // give more space to image, less to text
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

            // Details area – limited height + overflow protection
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recipe name – auto-adjust font size if too long
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: mode.textColor,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Conditional info
                    if (mode.isFood) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (totalTimeMinutes != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_outlined,
                                    size: 14, color: mode.textColor.withOpacity(0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  '$totalTimeMinutes min',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: mode.textColor.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          if (servings != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 14, color: mode.textColor.withOpacity(0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  '$servings servings',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: mode.textColor.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ] else ...[
                      // Drink mode
                      Row(
                        children: [
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
                                  const SizedBox(width: 4),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: color,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}