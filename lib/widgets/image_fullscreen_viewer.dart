import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'product_image_gallery.dart';

class ImageFullscreenViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageFullscreenViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<ImageFullscreenViewer> createState() => _ImageFullscreenViewerState();
}

class _ImageFullscreenViewerState extends State<ImageFullscreenViewer> {
  late int _currentIndex;
  double _dragOffset = 0;
  double _dragOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(_dragOpacity),
      body: GestureDetector(
        // Swipe-down-to-dismiss
        onVerticalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dy;
            _dragOpacity = (1 - (_dragOffset.abs() / 400)).clamp(0.3, 1.0);
          });
        },
        onVerticalDragEnd: (details) {
          if (_dragOffset.abs() > 120) {
            Navigator.pop(context);
          } else {
            setState(() {
              _dragOffset = 0;
              _dragOpacity = 1.0;
            });
          }
        },
        child: Stack(
          children: [
            // Image gallery with vertical offset from drag
            AnimatedContainer(
              duration: _dragOffset == 0
                  ? const Duration(milliseconds: 200)
                  : Duration.zero,
              transform: Matrix4.translationValues(0, _dragOffset, 0),
              child: ProductImageGallery(
                imageUrls: widget.imageUrls,
                initialIndex: widget.initialIndex,
                isFullscreen: true,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),

            // Top bar: Close button + Page indicator
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator
                    if (widget.imageUrls.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // Top Right Actions
                    Row(
                      children: [
                        // Share Image
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share, color: Colors.white, size: 20),
                            onPressed: () async {
                              // Share the current image URL or file
                              await Share.share(
                                widget.imageUrls[_currentIndex],
                                subject: 'Product Image',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Close button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
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
