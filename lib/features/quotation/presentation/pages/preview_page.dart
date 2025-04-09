import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quotation_generator/core/constants/colors.dart';
import 'package:quotation_generator/features/quotation/data/template_storage.dart';
import 'package:quotation_generator/screens/business_details_page.dart';
import 'package:quotation_generator/core/services/business_details_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
// <-- make sure this is the correct path to AppColors

class PreviewPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ScreenshotController _screenshotController = ScreenshotController();

  PreviewPage({super.key, required this.items});

  double calculateGST(double price, double gstPercent) {
    return (price * gstPercent) / 100;
  }

  double calculateTotalWithGST(Map<String, dynamic> item) {
    double baseTotal = item['price'] * item['qty'];
    double gstAmount = calculateGST(baseTotal, item['gst']);
    return baseTotal + gstAmount;
  }

  double getGrandTotal() {
    return items.fold(0, (sum, item) => sum + calculateTotalWithGST(item));
  }

  void exportToPDF() async {
    final pdfDoc = pw.Document();
    final businessDetails =
        await BusinessDetailsService().loadBusinessDetails();

    final logoImage =
        (businessDetails?.logoPath.isNotEmpty ?? false)
            ? pw.MemoryImage(File(businessDetails!.logoPath).readAsBytesSync())
            : null;

    pdfDoc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Business Info and Logo
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Business Info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          businessDetails?.businessName ?? "Your Business Name",
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(businessDetails?.address ?? "Address"),
                        pw.Text("Phone: ${businessDetails?.phone ?? 'Phone'}"),
                        pw.Text("Email: ${businessDetails?.email ?? 'Email'}"),
                      ],
                    ),
                  ),

                  // Right: Logo
                  if (logoImage != null)
                    pw.Container(
                      width: 160,
                      // height: 160,
                      alignment: pw.Alignment.topRight,
                      child: pw.Image(logoImage),
                    ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                "Quotation Summary",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),

              // Table with products
              pw.Table.fromTextArray(
                headers: [
                  'Product',
                  'Qty',
                  'Price',
                  'GST %',
                  'Total (with GST)',
                ],
                data:
                    items.map((item) {
                      final total = calculateTotalWithGST(item);
                      return [
                        item['name'],
                        item['qty'].toString(),
                        '${item['price']}',
                        '${item['gst']}%',
                        '${total.toStringAsFixed(2)}',
                      ];
                    }).toList(),
              ),

              pw.SizedBox(height: 12),

              // Grand total
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Grand Total: ${getGrandTotal().toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdfDoc.save());
  }

  void exportToPNG() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      await Printing.layoutPdf(
        onLayout: (format) async {
          final pdf = pw.Document();
          final pwImage = pw.MemoryImage(image);
          pdf.addPage(
            pw.Page(build: (context) => pw.Center(child: pw.Image(pwImage))),
          );
          return pdf.save();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text("Quotation Preview"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Screenshot(
          controller: _screenshotController,
          child: Column(
            children: [
              Text(
                "Quotation Summary",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        AppColors.primary.withOpacity(0.1),
                      ),
                      columns: const [
                        DataColumn(label: Text("Product")),
                        DataColumn(label: Text("Qty")),
                        DataColumn(label: Text("Price")),
                        DataColumn(label: Text("GST %")),
                        DataColumn(label: Text("Total (with GST)")),
                      ],
                      rows:
                          items.map((item) {
                            double total = calculateTotalWithGST(item);
                            return DataRow(
                              cells: [
                                DataCell(Text(item['name'])),
                                DataCell(Text(item['qty'].toString())),
                                DataCell(Text(currency.format(item['price']))),
                                DataCell(Text('${item['gst']}%')),
                                DataCell(Text(currency.format(total))),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Grand Total: ${currency.format(getGrandTotal())}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: "Export PDF",
                    onPressed: exportToPDF,
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.image,
                    label: "Export PNG",
                    onPressed: exportToPNG,
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.business,
                    label: "Business Details",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessDetailsPage(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.save,
                    label: "Save Template",
                    onPressed: () async {
                      await TemplateStorage.saveTemplate(items);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Template saved!")),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.edit,
                    label: "Edit Items",
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
