import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const CustomAppBar({Key? key, this.height = 70}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      title: Image.asset(
        'assets/images/curemix_logo.webp',
        height: 45,
        fit: BoxFit.contain,
      ),
    );
  }
}
