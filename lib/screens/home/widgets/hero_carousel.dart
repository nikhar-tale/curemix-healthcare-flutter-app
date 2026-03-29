import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Placeholder premium promotional banners for B2B
  final List<Map<String, String>> _promotions = [
    {
      'title': 'New Arrivals in Cardiology',
      'subtitle': 'Stock up on premium quality generic medicines today.',
      'color': '0xFF008080', // Teal
      'icon': 'favorite',
    },
    {
      'title': 'High Margin Combos',
      'subtitle': 'Boost your branch revenue with exclusive seasonal kits.',
      'color': '0xFFFF9800', // Orange
      'icon': 'trending_up',
    },
    {
      'title': 'Same-Day Dispatch',
      'subtitle': 'Order before 2 PM for guaranteed immediate shipping.',
      'color': '0xFF374151', // Dark Gray
      'icon': 'local_shipping',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _promotions.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'trending_up':
        return Icons.trending_up;
      case 'local_shipping':
        return Icons.local_shipping;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveHelper.isTablet(context);
    
    return Column(
      children: [
        SizedBox(
          height: isTablet ? 180 : 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _promotions.length,
            itemBuilder: (context, index) {
              final promo = _promotions[index];
              final color = Color(int.parse(promo['color']!));
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.9),
                      color.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promo['title']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 24 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            promo['subtitle']!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isTablet ? 16 : 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(promo['icon']!),
                        color: Colors.white,
                        size: isTablet ? 48 : 32,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Pagination Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promotions.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
