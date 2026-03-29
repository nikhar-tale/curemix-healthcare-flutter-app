import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../core/constants/app_colors.dart';
import '../product_details/product_details_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/product_shimmer.dart';

// Dashboard Imports
import 'widgets/home_sliver_app_bar.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/category_quick_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController(); 

  @override
  void initState() {
    super.initState();
    // Fetch products on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(context: context);
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final pixels = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;

    // Load when 80% scrolled
    if (pixels >= maxScroll * 0.8) {
      final provider = context.read<ProductProvider>();

      if (!provider.isLoading && provider.hasMoreProducts) {
        provider.fetchProducts(context: context, loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().refreshProducts(context: context);
  }

  void _navigateToProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              cacheExtent: 1000,
              slivers: [
                // 1. Branding Header
                const HomeSliverAppBar(),

                // 2. Dashboard Widgets (Carousel & Categories)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 8),
                      HeroCarousel(),
                      SizedBox(height: 8),
                      CategoryQuickChips(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          'Our Products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Dynamic Products Body
                _buildSliverBody(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverBody(ProductProvider provider) {
    // Loading State
    if (provider.isLoading && !provider.hasProducts) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ProductGridShimmer(),
        ),
      );
    }

    // Error State
    if (provider.hasError && !provider.hasProducts) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage ?? 'Something went wrong',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => provider.fetchProducts(context: context),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty State
    if (!provider.hasProducts) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No products available',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // Products Grid
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Show loading indicator at bottom for pagination
            if (index >= provider.products.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final Product product = provider.products[index];
            return ProductCard(
              key: ValueKey(product.id),
              product: product,
              onTap: () => _navigateToProductDetails(product),
            );
          },
          childCount: provider.products.length +
              (provider.isLoading && provider.hasProducts ? 2 : 0),
        ),
      ),
    );
  }
}
