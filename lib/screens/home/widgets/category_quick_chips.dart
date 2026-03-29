import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../search/search_screen.dart';

class CategoryQuickChips extends StatelessWidget {
  const CategoryQuickChips({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Tablets', 'icon': Icons.medication, 'color': Colors.blue},
    {'name': 'Syrups', 'icon': Icons.local_drink, 'color': AppColors.primary},
    {'name': 'Injections', 'icon': Icons.vaccines, 'color': Colors.red},
    {'name': 'Creams', 'icon': Icons.clean_hands, 'color': Colors.orange},
    {'name': 'Drops', 'icon': Icons.water_drop, 'color': Colors.lightBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Quick Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return buildCategoryItem(context, category);
            },
          ),
        ),
      ],
    );
  }

  Widget buildCategoryItem(BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(initialQuery: category['name']),
          ),
        );
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: category['color'].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                category['icon'],
                color: category['color'],
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
