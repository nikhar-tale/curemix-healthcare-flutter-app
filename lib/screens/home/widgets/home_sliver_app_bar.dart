import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_colors.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveHelper.isTablet(context);
    
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      forceElevated: true,
      pinned: true,
      floating: true,
      expandedHeight: isTablet ? 80.0 : 60.0,
      toolbarHeight: isTablet ? 80.0 : 56.0,
      centerTitle: true,
      leading: const SizedBox(),
      leadingWidth: isTablet ? 0 : 96, // On tablet we don't need to balance as much if sidebar is there, but for consistency let's match
      title: Image.asset(
        'assets/images/curemix_logo.webp',
        height: isTablet ? 60 : 45,
        fit: BoxFit.contain,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          onPressed: () {
            // Future feature: Notifications
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
