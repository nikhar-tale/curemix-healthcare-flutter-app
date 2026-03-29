import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../core/constants/app_colors.dart';
import '../product_details/product_details_screen.dart';
import '../home/widgets/product_card.dart';
import '../home/widgets/product_list_tile.dart';
import '../../widgets/custom_app_bar.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  bool _isListView = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _searchController.text = widget.initialQuery!;
        context.read<ProductProvider>().searchProducts(widget.initialQuery!);
      } else {
        context.read<ProductProvider>().clearSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

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

  List<Product> _applyLocalFilters(List<Product> products) {
    if (_selectedFilter == 'All') return products;
    // Match against any of the product's categories
    return products.where((p) {
      return p.allCategoryNames.any(
        (catName) => catName.toLowerCase() == _selectedFilter.toLowerCase(),
      );
    }).toList();
  }

  List<String> _buildDynamicFilters(List<Product> products) {
    final Set<String> cats = {'All'};
    for (final product in products) {
      for (final catName in product.allCategoryNames) {
        if (catName.isNotEmpty) cats.add(catName);
      }
    }
    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final dynamicFilters = _buildDynamicFilters(
            _searchController.text.isEmpty ? provider.products : provider.searchResults,
          );
          return Column(
            children: [
              // 1. Search Bar
              _buildSearchBar(),
              
              // 2. Filter Pills
              _buildFilterPills(dynamicFilters),

              // 3. Search Results
              Expanded(
                child: _buildSearchResults(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Search by formulation or brand...',
           hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearSearch,
                ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Barcode scanner coming soon!')),
                  );
                },
              ),
            ],
          ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
        onChanged: (value) {
          setState(() {}); 
          _onSearchChanged(value);
        },
      ),
    );
  }

  Widget _buildFilterPills(List<String> filters) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? filter : 'All';
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.1),
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(ProductProvider provider) {
    if (provider.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching databases...',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (provider.searchError != null && _searchController.text.isNotEmpty) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Search Failed',
        message: provider.searchError!,
      );
    }

    // Default to the full catalog if no query is entered
    final List<Product> sourceList = _searchController.text.isEmpty 
        ? provider.products 
        : provider.searchResults;

    final filteredResults = _applyLocalFilters(sourceList);

    if (filteredResults.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return _buildEmptyState(
          icon: Icons.search_off,
          title: 'No Results Found',
          message: 'No products matched your search and filters.',
        );
      } else {
        return _buildEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Empty Catalog',
          message: 'No products available to display.',
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                'Found ${filteredResults.length} product${filteredResults.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Grid vs List Toggle
              IconButton(
                icon: Icon(
                  _isListView ? Icons.grid_view : Icons.view_list,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isListView = !_isListView;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Dynamic List or Grid
        Expanded(
          child: _isListView
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final product = filteredResults[index];
                    return ProductListTile(
                      key: ValueKey(product.id),
                      product: product,
                      onTap: () => _navigateToProductDetails(product),
                    );
                  },
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final product = filteredResults[index];
                    return ProductCard(
                      key: ValueKey(product.id),
                      product: product,
                      onTap: () => _navigateToProductDetails(product),
                    );
                  },
                ),
        ),
      ],
    );
  }

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