import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/project.dart';

class PdfHelper {
  static Future<void> generateAndPrint(Project project) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Cutting Sheet for: ${project.name}',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Location: ${project.location}'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['#', 'Window Type', 'Width', 'Height', 'Cutting'],
                data: List<List<String>>.generate(
                  project.items.length,
                  (index) {
                    final item = project.items[index];
                    return [
                      (index + 1).toString(),
                      item.windowType,
                      item.width.toStringAsFixed(0),
                      item.height.toStringAsFixed(0),
                      item.cuttingResult
                          .map((e) => '${e['section']}: ${e['qty']}x${_formatSize(e['size'])}')
                          .join(', '),
                    ];
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static String _formatSize(dynamic size) {
    if (size is num) {
      return size.toStringAsFixed(0);
    }
    return size.toString();
  }
}
