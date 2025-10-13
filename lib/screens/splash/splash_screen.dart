import 'package:curemix_healtcare_flutter_app/providers/product_provider.dart';
import 'package:curemix_healtcare_flutter_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pre-cache logo for smooth fade-in
    // precacheImage(const AssetImage('assets/images/curemix_logo.png'), context);

    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.dark,
    //   ),
    // );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    // _navigateToMainScreen();
    // Start loading Hive + animation together
    _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/curemix_logo.webp'), context);
  }

  Future<void> _initializeApp() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    // Open Hive while animation is running
    await provider.init();

    // Add a very short delay only if needed (for smooth transition)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Curemix Logo
                Image.asset(
                  'assets/images/curemix_logo.webp',
                  width: 150,
                  height: 250,
                ),

                const SizedBox(height: 24),

                // Brand Name
                // const Text(
                //   AppStrings.appName,
                //   style: TextStyle(
                //     fontSize: 28,
                //     fontWeight: FontWeight.bold,
                //     color: AppColors.textPrimary,
                //     letterSpacing: 0.5,
                //   ),
                // ),
                // const SizedBox(height: 8),

                // Tagline
                Text(
                  AppStrings.tagline,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
