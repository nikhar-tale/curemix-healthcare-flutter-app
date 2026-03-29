import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/responsive_helper.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const HomeScreen(), const SearchScreen()];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = ResponsiveHelper.isTablet(context);

        if (isTablet) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  useIndicator: true,
                  indicatorColor: AppColors.primary.withOpacity(0.1),
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.primary,
                    size: 28,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Image.asset(
                      'assets/images/app_icon_v1.png',
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  trailing: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          color: Colors.grey.shade400,
                          tooltip: 'Logout',
                          onPressed: () {
                            // TODO: Implement Logout
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search_outlined),
                      selectedIcon: Icon(Icons.search_rounded),
                      label: Text('Search'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _screens),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
          ),
        );
      },
    );
  }
}
