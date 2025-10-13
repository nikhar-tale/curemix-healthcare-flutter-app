import 'package:flutter/material.dart';
import '../../widgets/product_image_gallery.dart';

class ImageFullscreenViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageFullscreenViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ProductImageGallery(
            imageUrls: imageUrls,
            initialIndex: initialIndex,
            isFullscreen: true,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
