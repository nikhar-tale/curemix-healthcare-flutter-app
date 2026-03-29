import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/product_model.dart';

class PdfTemplateBuilder {


  static List<pw.Widget> buildProductPage(
    Product product,
    List<pw.ImageProvider> images,
  ) {
    final mainImage = images.isNotEmpty ? images.first : null;
    final String headlineInfo = product.category != null
        ? product.category!.toUpperCase()
        : 'Premium Healthcare Product';

    return [
      // Title Section
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.only(bottom: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              product.name,
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              headlineInfo,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),

      // Main Section (2 Columns)
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left: Main Image
          pw.Expanded(
            flex: 5,
            child: mainImage != null
                ? pw.Container(
                    height: 240,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                      color: PdfColors.white,
                    ),
                    child: pw.Center(
                      child: pw.Image(mainImage, fit: pw.BoxFit.contain),
                    ),
                  )
                : pw.Container(
                    height: 240,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        "Image Not Available",
                        style: const pw.TextStyle(color: PdfColors.grey),
                      ),
                    ),
                  ),
          ),
          pw.SizedBox(width: 25),

          // Right: Specs Block
          pw.Expanded(
            flex: 5,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100, // Light Gray Container
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColor.fromHex('#FF9800'), width: 2), // Orange Accent
                      ),
                    ),
                    child: pw.Text(
                      'PRODUCT DETAILS',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900, // Teal/Blue Header Match
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(3),
                    },
                    children: [
                      if (product.category != null && product.category!.isNotEmpty)
                        _buildTableRow('Category', product.category!),
                      _buildTableRow(
                        'Availability',
                        product.isInStock ? 'In Stock' : 'Out of Stock',
                        valueColor: product.isInStock ? PdfColors.green700 : PdfColors.red700,
                      ),
                      if (product.price > 0)
                        _buildTableRow('Price', 'Rs. ${product.price}', isHighlight: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 35),

      // Medical Information Section
      if (product.displayDescription.isNotEmpty) ...[
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100, // Light Gray Container
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColor.fromHex('#FF9800'), width: 2), // Orange Accent
                  ),
                ),
                child: pw.Text(
                  'MEDICAL INFORMATION / INDICATIONS',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900, // Teal Match
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Paragraph(
                text: _cleanHtmlText(product.displayDescription),
                style: const pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 1.8,
                  color: PdfColors.blueGrey800,
                ),
              ),
            ],
          ),
        ),
      ],

      // Gallery Section (Automatically breaks if needed by MultiPage, but attempts to pack on Page 1)
      if (images.length > 1) ...[
        pw.SizedBox(height: 25),
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColor.fromHex('#FF9800'), width: 2), // Orange Accent
            ),
          ),
          child: pw.Text(
            'PRODUCT GALLERY',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900, // Teal Match
            ),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: images.sublist(1).take(3).map((img) {
            return pw.Expanded(
              child: pw.Container(
                height: 120,
                margin: const pw.EdgeInsets.only(right: 15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                padding: const pw.EdgeInsets.all(6),
                child: pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain)),
              ),
            );
          }).toList(),
        ),
      ],
    ];
  }

  static pw.TableRow _buildTableRow(
    String label,
    String value, {
    bool isHighlight = false,
    PdfColor valueColor = PdfColors.black,
  }) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
              fontSize: 11,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              color: isHighlight ? PdfColors.green800 : valueColor,
              fontSize: 11,
              fontWeight: isHighlight
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  static String _cleanHtmlText(String htmlText) {
    String text = htmlText.replaceAll(
      RegExp(r'</p>|<br>|<br\s*/>', caseSensitive: false),
      '\n\n',
    );
    text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<li>', caseSensitive: false), '• ');
    text = text.replaceAll(
      RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true),
      '',
    );
    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#8217;', "'");
    text = text.replaceAll('&#8211;', "-");
    text = text.replaceAll('&#8212;', "--");
    text = text.replaceAll('&#8220;', '"');
    text = text.replaceAll('&#8221;', '"');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }
}
