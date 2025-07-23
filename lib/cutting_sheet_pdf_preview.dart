import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/project.dart';

/// A screen to preview, name, and print/share the PDF document for a cutting sheet.
class CuttingSheetPdfPreview extends StatefulWidget {
  final Project project;

  const CuttingSheetPdfPreview({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<CuttingSheetPdfPreview> createState() => _CuttingSheetPdfPreviewState();
}

class _CuttingSheetPdfPreviewState extends State<CuttingSheetPdfPreview> {
  late TextEditingController _filenameController;

  @override
  void initState() {
    super.initState();
    String defaultName = widget.project.name.trim().isNotEmpty
        ? '${widget.project.name.replaceAll(RegExp(r"[^\w]+"), "_")}_cutting_sheet.pdf'
        : 'Project_${DateTime.now().millisecondsSinceEpoch}.pdf';
    _filenameController = TextEditingController(text: defaultName);
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  /// Builds the PDF document as bytes.
  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                'Cutting Sheet',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Project: ${widget.project.name}', style: pw.TextStyle(fontSize: 12)),
              pw.Text('Location: ${widget.project.location}', style: pw.TextStyle(fontSize: 12)),
              pw.Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 18),
              ...widget.project.items.map((item) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${item.windowType.toUpperCase()} | Width: ${item.width} | Height: ${item.height}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: pw.FlexColumnWidth(2),
                        1: pw.FlexColumnWidth(1),
                        2: pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.grey300),
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text('Section', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text('Size', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            ),
                          ],
                        ),
                        ...item.cuttingResult.map<pw.TableRow>((part) {
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text(part['section'].toString(), style: pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text(part['qty'].toString(), style: pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text(part['size'].toString(), style: pw.TextStyle(fontSize: 10)),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    pw.SizedBox(height: 18),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutting Sheet PDF Preview'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _filenameController,
              decoration: InputDecoration(
                labelText: 'PDF Filename',
                suffixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: PdfPreview(
              build: _buildPdf,
              canChangePageFormat: false,
              pdfFileName: _filenameController.text,
            ),
          ),
        ],
      ),
    );
  }
}