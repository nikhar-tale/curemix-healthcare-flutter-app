import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

import '../../core/utils/responsive_helper.dart';
import '../../core/constants/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final File pdfFile;
  final String productName;

  const PdfViewerScreen({
    super.key,
    required this.pdfFile,
    required this.productName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 0;
  bool _showToolbar = true;

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade800,

      // ─── App Bar ───────────────────────────────────────────────────────
      appBar: _showToolbar
          ? AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Product Brochure',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.productName,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 10,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                // Zoom Out
                IconButton(
                  icon: Icon(Icons.zoom_out_rounded, size: isTablet ? 28 : 24),
                  tooltip: 'Zoom Out',
                  onPressed: () => _pdfController.zoomLevel =
                      (_pdfController.zoomLevel - 0.25).clamp(0.75, 4.0),
                ),
                // Zoom In
                IconButton(
                  icon: Icon(Icons.zoom_in_rounded, size: isTablet ? 28 : 24),
                  tooltip: 'Zoom In',
                  onPressed: () => _pdfController.zoomLevel =
                      (_pdfController.zoomLevel + 0.25).clamp(0.75, 4.0),
                ),
                // Print
                IconButton(
                  icon: Icon(Icons.print_rounded, size: isTablet ? 28 : 24),
                  tooltip: 'Print',
                  onPressed: _printPdf,
                ),
                // Share
                IconButton(
                  icon: Icon(Icons.share_rounded, size: isTablet ? 28 : 24),
                  tooltip: 'Share PDF',
                  onPressed: _sharePdf,
                ),
                SizedBox(width: isTablet ? 12 : 4),
              ],
            )
          : null,

      // ─── PDF Viewer ────────────────────────────────────────────────────
      body: GestureDetector(
        onTap: () => setState(() => _showToolbar = !_showToolbar),
        child: SfPdfViewer.file(
          widget.pdfFile,
          key: _pdfViewerKey,
          controller: _pdfController,
          // Native pinch-to-zoom, double-tap zoom, smooth scroll
          enableDoubleTapZooming: true,
          pageLayoutMode: PdfPageLayoutMode.continuous,
          scrollDirection: PdfScrollDirection.vertical,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          canShowPaginationDialog: true,
          onDocumentLoaded: (details) {
            setState(() {
              _totalPages = details.document.pages.count;
            });
          },
          onPageChanged: (details) {
            setState(() {
              _currentPage = details.newPageNumber;
            });
          },
        ),
      ),

      // ─── Bottom Nav Bar  (Page counter + quick nav) ────────────────────
      bottomNavigationBar: _showToolbar
          ? Container(
              color: Colors.grey.shade900,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous Page
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: isTablet ? 24 : 18),
                      onPressed: _currentPage > 1
                          ? () => _pdfController.previousPage()
                          : null,
                    ),

                    SizedBox(width: isTablet ? 24 : 16),

                    // Page Counter with tap-to-jump
                    GestureDetector(
                      onTap: _showPageJumpDialog,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 16, vertical: isTablet ? 10 : 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.6)),
                        ),
                        child: Text(
                          _totalPages > 0
                              ? 'Page $_currentPage of $_totalPages'
                              : 'Loading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 17 : 13,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: isTablet ? 24 : 16),

                    // Next Page
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: isTablet ? 24 : 18),
                      onPressed: _currentPage < _totalPages
                          ? () => _pdfController.nextPage()
                          : null,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // ─── Page Jump Dialog ──────────────────────────────────────────────────
  void _showPageJumpDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1 – $_totalPages',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Go', style: TextStyle(color: Colors.white)),
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                _pdfController.jumpToPage(page);
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  // ─── Share ────────────────────────────────────────────────────────────
  Future<void> _sharePdf() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(widget.pdfFile.path, mimeType: 'application/pdf')],
          text: 'Check out this product brochure from Curemix Healthcare!',
          subject: '${widget.productName} - Curemix Brochure',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not share PDF. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Print ───────────────────────────────────────────────────────────
  Future<void> _printPdf() async {
    await Printing.layoutPdf(
      onLayout: (_) async => widget.pdfFile.readAsBytes(),
      name: '${widget.productName} - Curemix Brochure',
    );
  }
}
