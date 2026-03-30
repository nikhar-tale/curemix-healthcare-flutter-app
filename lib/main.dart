import 'dart:math';
import 'package:curemix_healtcare_flutter_app/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/splash/splash_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'providers/product_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ProductImageAdapter());
  Hive.registerAdapter(ProductCategoryAdapter());
  Hive.registerAdapter(ProductAdapter());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const OrientationController(child: CuremixApp()));
}

/// A widget that handles setting preferred orientations after the app starts.
/// This is more reliable in release mode than setting it in main().
class OrientationController extends StatefulWidget {
  final Widget child;
  const OrientationController({super.key, required this.child});

  @override
  State<OrientationController> createState() => _OrientationControllerState();
}

class _OrientationControllerState extends State<OrientationController> {
  @override
  void initState() {
    super.initState();
    // Use a post frame callback to ensure the view is initialized and ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _setOrientations());
  }

  void _setOrientations() {
    // Get logical size
    final view = View.of(context);
    final size = view.physicalSize / view.devicePixelRatio;
    
    // logic: if longest side >= 600, it's a tablet
    final bool isTablet = max(size.width, size.height) >= 600;

    if (isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class CuremixApp extends StatelessWidget {
  const CuremixApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProvider())],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: messengerKey,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            background: AppColors.background,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
