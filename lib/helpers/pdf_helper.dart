import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/project.dart';

/// Helper class for generating and saving PDF documents related to projects.
class PdfHelper {
  /// Generates a PDF cutting sheet for the given [project] and saves it to external storage.
  /// Also opens the share dialog for the generated PDF.
  static Future<void> generateAndSave(Project project) async {
    final pdf = pw.Document(); // Create a new PDF document instance

    // Add a single page to the document
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // Build the page content as a vertical column
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title text with project name
              pw.Text(
                'Cutting Sheet for: ${project.name}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              // Location text
              pw.Text('Location: ${project.location}'),
              pw.SizedBox(height: 20), // Spacer

              // Table with cutting sheet data
              pw.Table(
                border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: pw.FlexColumnWidth(0.5),
                  1: pw.FlexColumnWidth(1.5),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                  4: pw.FlexColumnWidth(3),
                },
                children: [
                  // Header row for the table
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _tableCell('#', isHeader: true),
                      _tableCell('Window Type', isHeader: true),
                      _tableCell('Width', isHeader: true),
                      _tableCell('Height', isHeader: true),
                      _tableCell('Cutting', isHeader: true),
                    ],
                  ),
                  // Data rows: one for each item in the project
                  ...List<pw.TableRow>.generate(
                    project.items.length,
                    (index) {
                      final item = project.items[index];
                      return pw.TableRow(
                        children: [
                          // Row number
                          _tableCell((index + 1).toString()),
                          // Window type
                          _tableCell(item.windowType),
                          // Width (rounded)
                          _tableCell(item.width.toStringAsFixed(0)),
                          // Height (rounded)
                          _tableCell(item.height.toStringAsFixed(0)),
                          // Cutting details, now as: section : size (qty)
                          _tableCell(
                            item.cuttingResult
                                .map((e) => '${e['section']} : ${_formatSize(e['size'])} (${e['qty']})')
                                .join('\n'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Get the external storage directory to save the PDF file
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/CuttingSheet_${project.name}.pdf';

    // Save the PDF file to the specified path
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the share dialog so the user can share the generated PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'CuttingSheet_${project.name}.pdf');
  }

  /// Helper method to create a table cell with padding and optional bold text for headers.
  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Formats the [size] value as a rounded string if numeric, otherwise as a plain string.
  static String _formatSize(dynamic size) {
    if (size is num) {
      return size.toStringAsFixed(0);
    }
    return size.toString();
  }
}