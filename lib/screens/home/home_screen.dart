import 'package:curemix_healtcare_flutter_app/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../product_details/product_details_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/product_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController(); // ✅ Add this

  @override
  void initState() {
    super.initState();
    // Fetch products on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(context: context,);
    });

    // ✅ Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  // ✅ Add this method
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final pixels = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;

    if (kDebugMode) {
      print('📜 pixels: $pixels, max: $maxScroll');
    }

    // Load when 80% scrolled
    if (pixels >= maxScroll * 0.8) {
      final provider = context.read<ProductProvider>();

      if (kDebugMode) {
        print(
        '📜 Near bottom! isLoading: ${provider.isLoading}, hasMore: ${provider.hasMoreProducts}',
      );
      }

      if (!provider.isLoading && provider.hasMoreProducts) {
        if (kDebugMode) {
          print('📜 Loading more...');
        }
        provider.fetchProducts(context: context, loadMore: true);
      }
    }
  }

  // ✅ Add dispose to clean up
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().refreshProducts(context: context,);
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
      // appBar: 
      // AppBar(
      //   title: const Text(AppStrings.appName),
      //   actions: [
      //     // Cart Icon (for future use)
      //     // IconButton(
      //     //   icon: const Icon(Icons.shopping_cart_outlined),
      //     //   onPressed: () {
      //     //     // TODO: Navigate to cart
      //     //   },
      //     // ),
      //   ],
      // ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          // Loading State
          if (provider.isLoading && !provider.hasProducts) {
            return const ProductGridShimmer();
          }

          // Error State
          if (provider.hasError && !provider.hasProducts) {
            return Center(
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
                    onPressed: () => provider.fetchProducts(context: context,),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty State
          if (!provider.hasProducts) {
            return Center(
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
            );
          }

          // Products Grid
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: GridView.builder(
              controller: _scrollController, // ✅ Add this line

              cacheExtent: 1000, // ✅ Pre-render items for smoother scroll
              addAutomaticKeepAlives: true, // ✅ Keep widgets alive
              addRepaintBoundaries: true, // ✅ Optimize repaints
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount:
                  provider.products.length +
                  (provider.isLoading && provider.hasProducts
                      ? 2
                      : 0), // ✅ Add space for loader
              itemBuilder: (context, index) {
                // ✅ Show loading indicator at bottom
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
                  product: product,
                  onTap: () => _navigateToProductDetails(product),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
