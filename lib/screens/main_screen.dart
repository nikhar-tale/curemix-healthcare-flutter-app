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

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const Center(child: Text('Profile Screen')), // Placeholder for 3rd tab
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = ResponsiveHelper.isTablet(context);
        final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        
        // Only show sidebar on Tablet in Landscape mode
        final bool showSidebar = isTablet && isLandscape;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Content Area - Shifted slightly when sidebar is present to prevent overlap
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(left: showSidebar ? 84 : 0),
                  child: IndexedStack(index: _currentIndex, children: _screens),
                ),
              ),
              
              if (showSidebar)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      width: 68,
                      height: 380, // Slightly taller for 3 items
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: NavigationRail(
                        backgroundColor: Colors.white,
                        selectedIndex: _currentIndex,
                        onDestinationSelected: (index) => setState(() => _currentIndex = index),
                        labelType: NavigationRailLabelType.none,
                        groupAlignment: 0.0,
                        useIndicator: true,
                        indicatorColor: AppColors.primary.withOpacity(0.12),
                        selectedIconTheme: const IconThemeData(color: AppColors.primary, size: 28),
                        unselectedIconTheme: IconThemeData(color: Colors.grey.shade500, size: 24),
                        leading: Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 24),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade50,
                            radius: 20,
                            child: Image.asset(
                              'assets/images/app_icon_v1.png',
                              height: 24,
                              fit: BoxFit.contain,
                            ),
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
                          NavigationRailDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person_rounded),
                            label: Text('Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: !showSidebar
              ? Container(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 24),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: BottomNavigationBar(
                        currentIndex: _currentIndex,
                        onTap: (index) => setState(() => _currentIndex = index),
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        selectedItemColor: AppColors.primary,
                        unselectedItemColor: Colors.grey.shade500,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home_outlined, size: 26),
                            activeIcon: Icon(Icons.home_rounded, size: 26),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.search_outlined, size: 26),
                            activeIcon: Icon(Icons.search_rounded, size: 26),
                            label: 'Search',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.person_outline, size: 26),
                            activeIcon: Icon(Icons.person_rounded, size: 26),
                            label: 'Profile',
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
