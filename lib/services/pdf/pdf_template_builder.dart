import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/product_model.dart';
import 'pdf_text_utils.dart';

class PdfTemplateBuilder {

  static pw.Widget buildProductPage(Product product, List<pw.ImageProvider> images, {pw.Font? icons, pw.Font? fontRegular, pw.Font? fontBold}) {
    final mainImage = images.isNotEmpty ? images.first : null;
    final String headlineInfo = product.sku != null ? 'SKU: ${product.sku} | ${product.stockStatus.toUpperCase()}' : product.stockStatus.toUpperCase();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 1. Title & Header
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                PdfTextUtils.clean(product.name),
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                PdfTextUtils.clean(headlineInfo),
                style: pw.TextStyle(
                  font: fontBold,
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
                        style: pw.TextStyle(font: fontRegular, color: PdfColors.grey),
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
                      PdfTextUtils.clean('PRODUCT DETAILS'),
                      style: pw.TextStyle(
                        font: fontBold,
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
                        _buildTableRow('Category', PdfTextUtils.clean(product.category!), font: fontRegular),
                      _buildTableRow(
                        'Availability',
                        product.isInStock ? 'In Stock' : 'Out of Stock',
                        font: fontRegular,
                        valueColor: product.isInStock ? PdfColors.green700 : PdfColors.red700,
                      ),
                      if (product.price > 0)
                        _buildTableRow('Price', 'Rs. ${product.price}', font: fontBold, isHighlight: true),
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
                    font: fontBold,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900, // Teal Match
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Paragraph(
                text: PdfTextUtils.clean(product.displayDescription),
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 11,
                  lineSpacing: 1.8,
                  color: PdfColors.blueGrey800,
                ),
              ),
            ],
          ),
        ),
      ],

      // Gallery Section
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
              font: fontBold,
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
      ], // Close the if-spread list
    ], // Close the Column children list
  );
}

  static pw.TableRow _buildTableRow(String label, String value, {pw.Font? font, PdfColor? valueColor, bool isHighlight = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
              fontWeight: isHighlight ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: valueColor ?? (isHighlight ? PdfColors.blue900 : PdfColors.black),
            ),
          ),
        ),
      ],
    );
  }
}
