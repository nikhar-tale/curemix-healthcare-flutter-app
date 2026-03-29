import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey.shade800,

      // ─── App Bar ───────────────────────────────────────────────────────
      appBar: _showToolbar
          ? AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Brochure',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.productName,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                // Zoom Out
                IconButton(
                  icon: const Icon(Icons.zoom_out_rounded),
                  tooltip: 'Zoom Out',
                  onPressed: () => _pdfController.zoomLevel =
                      (_pdfController.zoomLevel - 0.25).clamp(0.75, 4.0),
                ),
                // Zoom In
                IconButton(
                  icon: const Icon(Icons.zoom_in_rounded),
                  tooltip: 'Zoom In',
                  onPressed: () => _pdfController.zoomLevel =
                      (_pdfController.zoomLevel + 0.25).clamp(0.75, 4.0),
                ),
                // Print
                IconButton(
                  icon: const Icon(Icons.print_rounded),
                  tooltip: 'Print',
                  onPressed: _printPdf,
                ),
                // Share
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  tooltip: 'Share PDF',
                  onPressed: _sharePdf,
                ),
                const SizedBox(width: 4),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Page
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                      onPressed: _currentPage > 1
                          ? () => _pdfController.previousPage()
                          : null,
                    ),

                    // Page Counter with tap-to-jump
                    GestureDetector(
                      onTap: _showPageJumpDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    // Next Page
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 18),
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
