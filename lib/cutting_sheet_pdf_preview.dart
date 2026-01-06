import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/project.dart';

/// A screen to preview, name, and print/share the PDF document for a cutting sheet.
class CuttingSheetPdfPreview extends StatefulWidget {
  final Project project;

  const CuttingSheetPdfPreview({Key? key, required this.project})
    : super(key: key);

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
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(16),

        /// ✅ PAGE FOOTER (PAGE NUMBERS)
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        },

        build: (pw.Context context) {
          return [
            pw.Text(
              'Cutting Sheet',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Project: ${widget.project.name}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Location: ${widget.project.location}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 18),

            /// ✅ ITEM NUMBERING
            ...widget.project.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${index + 1}. ${item.windowType.toUpperCase()} '
                    '| Width: ${item.width.toStringAsFixed(0)} '
                    '| Height: ${item.height.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _headerCell('Section'),
                          _headerCell('Size'),
                          _headerCell('Qty'),
                        ],
                      ),
                      ...item.cuttingResult.map<pw.TableRow>((part) {
                        return pw.TableRow(
                          children: [
                            _bodyCell(part['section'].toString()),
                            _bodyCell(part['size'].toString()),
                            _bodyCell(part['qty'].toString()),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 18),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  static pw.Widget _bodyCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cutting Sheet PDF Preview')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _filenameController,
              decoration: const InputDecoration(
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
