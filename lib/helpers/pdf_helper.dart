import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/project.dart';

class PdfHelper {
  static Future<void> generateAndSave(Project project) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Cutting Sheet for: ${project.name}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Location: ${project.location}'),
              pw.SizedBox(height: 20),
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
                  ...List<pw.TableRow>.generate(
                    project.items.length,
                    (index) {
                      final item = project.items[index];
                      return pw.TableRow(
                        children: [
                          _tableCell((index + 1).toString()),
                          _tableCell(item.windowType),
                          _tableCell(item.width.toStringAsFixed(0)),
                          _tableCell(item.height.toStringAsFixed(0)),
                          _tableCell(
                            item.cuttingResult
                                .map((e) => '${e['section']}: ${e['qty']}x${_formatSize(e['size'])}')
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

    // Get directory to save file
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/CuttingSheet_${project.name}.pdf';

    // Save PDF file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open share dialog
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'CuttingSheet_${project.name}.pdf');
  }

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

  static String _formatSize(dynamic size) {
    if (size is num) {
      return size.toStringAsFixed(0);
    }
    return size.toString();
  }
}
