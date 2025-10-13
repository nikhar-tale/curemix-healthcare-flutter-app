import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../core/constants/app_colors.dart';
import '../product_details/product_details_screen.dart';
import '../home/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Clear search when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Wait 500ms after user stops typing before searching
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        context.read<ProductProvider>().searchProducts(query.trim());
      } else {
        context.read<ProductProvider>().clearSearch();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProductProvider>().clearSearch();
    setState(() {});
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
      // appBar: AppBar(
      //   title: const Text('Search Products'),
      // ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Search Results
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return _buildSearchResults(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Search for products...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() {}); // Rebuild to show/hide clear button
          _onSearchChanged(value);
        },
      ),
    );
  }

  // Search Results Widget
  Widget _buildSearchResults(ProductProvider provider) {
    // Initial State - No search yet
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        title: 'Start Searching',
        message: 'Search for medicines, supplements, and healthcare products',
      );
    }

    // Loading State
    if (provider.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Error State
    if (provider.searchError != null) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Search Failed',
        message: provider.searchError!,
      );
    }

    // No Results Found
    if (provider.searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        message: 'Try searching with different keywords',
      );
    }

    // Results Found
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Found ${provider.searchResults.length} product${provider.searchResults.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _onSearchChanged(_searchController.text),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),

        // Results Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final product = provider.searchResults[index];
              return ProductCard(
                product: product,
                onTap: () => _navigateToProductDetails(product),
              );
            },
          ),
        ),
      ],
    );
  }

  // Empty State Widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}