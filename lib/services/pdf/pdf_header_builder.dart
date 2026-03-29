import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_constants.dart';
import 'pdf_text_utils.dart';

class PdfHeaderBuilder {
  static pw.Widget build(pw.MemoryImage? logo, {pw.Font? fontRegular, pw.Font? fontBold}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 25),
      padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#008080'), // Curemix Teal
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            children: [
              if (logo != null) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Image(logo, width: 38, height: 38, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 12),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Curemix Healthcare',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    PdfTextUtils.clean(PdfConstants.branchName),
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#E0F2F1'),
                    ),
                  ), // Light Teal
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                PdfTextUtils.clean('WhatsApp: +${PdfConstants.branchPhone}'),
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 11,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Email: ${PdfConstants.branchEmail}',
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 10,
                  color: PdfColor.fromHex('#E0F2F1'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
