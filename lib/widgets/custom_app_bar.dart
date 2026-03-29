import 'package:flutter/material.dart';
import '../core/utils/responsive_helper.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);
  
  @override
  Size get preferredSize => const Size.fromHeight(80); // We handle constraints inside build

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveHelper.isTablet(context);
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      toolbarHeight: isTablet ? 80 : 56,
      title: Image.asset(
        'assets/images/curemix_logo.webp',
        height: isTablet ? 60 : 45,
        fit: BoxFit.contain,
      ),
    );
  }
}
