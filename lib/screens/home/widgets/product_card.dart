import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';
import '../../../core/constants/app_colors.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ Keep widget alive when scrolling

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ Must call super when using AutomaticKeepAliveClientMixin
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget. product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      cacheKey: widget.  product.id, // ✅ Explicit cache key
                      memCacheWidth: 400, // ✅ Resize for memory efficiency
                      memCacheHeight: 400, // ✅ Resize for memory efficiency
                      fadeInDuration: const Duration(
                        milliseconds: 200,
                      ), // ✅ Faster fade
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.medical_services,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Discount Badge
                  if ( widget. product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${ widget. product.discountPercentage}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Prescription Required Badge
                  if ( widget. product.prescriptionRequired)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.note_alt_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // // Out of Stock Overlay
                  // if (!product.isInStock)
                  //   Positioned.fill(
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         color: Colors.black.withOpacity(0.6),
                  //         borderRadius: const BorderRadius.only(
                  //           topLeft: Radius.circular(12),
                  //           topRight: Radius.circular(12),
                  //         ),
                  //       ),
                  //       child: const Center(
                  //         child: Text(
                  //           'OUT OF STOCK',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 12,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                       widget. product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Category
                    if ( widget. product.category != null)
                      Text(
                         widget. product.category!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),

                    const Spacer(),

                    // // Price Row
                    // Row(
                    //   children: [
                    //     // Current Price
                    //     Text(
                    //       product.formattedPrice,
                    //       style: const TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //         color: AppColors.primary,
                    //       ),
                    //     ),

                    //     const SizedBox(width: 6),

                    //     // MRP (strikethrough)
                    //     if (product.mrp != null && product.hasDiscount)
                    //       Text(
                    //         product.formattedMrp,
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           decoration: TextDecoration.lineThrough,
                    //           color: Colors.grey.shade500,
                    //         ),
                    //       ),
                    //   ],
                    // ),

                    // Rating
                    if ( widget. product.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            widget.  product.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
