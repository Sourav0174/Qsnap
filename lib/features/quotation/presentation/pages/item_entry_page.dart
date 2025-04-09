import 'package:flutter/material.dart';

import 'package:quotation_generator/core/constants/colors.dart';
import 'package:quotation_generator/features/quotation/data/template_list_page.dart';
import 'package:quotation_generator/features/quotation/presentation/pages/preview_page.dart';

class ItemEntryPage extends StatefulWidget {
  const ItemEntryPage({super.key});

  @override
  State<ItemEntryPage> createState() => _ItemEntryPageState();
}

class _ItemEntryPageState extends State<ItemEntryPage> {
  final List<Map<String, dynamic>> items = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController gstController = TextEditingController(text: '12');

  void addItem() {
    final String name = nameController.text.trim();
    final int? qty = int.tryParse(qtyController.text);
    final double? price = double.tryParse(priceController.text);
    final double? gst = double.tryParse(gstController.text);

    if (name.isEmpty || qty == null || price == null || gst == null) return;

    items.add({'name': name, 'qty': qty, 'price': price, 'gst': gst});

    nameController.clear();
    qtyController.clear();
    priceController.clear();
    gstController.text = '12';

    setState(() {});
  }

  void goToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewPage(items: items)),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.darkBlue),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.secondary, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Add Quotation Items",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.primary, // Lighter blue maybe
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(label: "Product Name", controller: nameController),
            _buildTextField(
              label: "Quantity",
              controller: qtyController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              label: "Price (without GST)",
              controller: priceController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              label: "GST %",
              controller: gstController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: addItem,
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary, // Brighter color
                foregroundColor: Colors.white,
                elevation: 3,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child:
                  items.isEmpty
                      ? const Center(
                        child: Text(
                          "No items added yet.",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, index) {
                          final item = items[index];
                          return Card(
                            elevation: 4, // subtle shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color:
                                AppColors
                                    .background, // light background for card
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              title: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              subtitle: Text(
                                "Qty: ${item['qty']} | Price: ₹${item['price']} | GST: ${item['gst']}%",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() => items.removeAt(index));
                                },
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: items.isNotEmpty ? goToPreview : null,
                    icon: const Icon(Icons.preview),
                    label: const Text("Preview & Export"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TemplateListPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.folder),
                  label: const Text("Saved"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
