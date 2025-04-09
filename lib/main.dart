import 'package:flutter/material.dart';
import 'features/quotation/presentation/pages/item_entry_page.dart';

void main() {
  runApp(const QuotationApp());
}

class QuotationApp extends StatelessWidget {
  const QuotationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotation Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ItemEntryPage(),
    );
  }
}
