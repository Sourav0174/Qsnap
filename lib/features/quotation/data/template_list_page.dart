import 'package:flutter/material.dart';
import 'package:quotation_generator/features/quotation/data/template_storage.dart';
import 'package:quotation_generator/features/quotation/presentation/pages/preview_page.dart';

class TemplateListPage extends StatefulWidget {
  const TemplateListPage({super.key});

  @override
  State<TemplateListPage> createState() => _TemplateListPageState();
}

class _TemplateListPageState extends State<TemplateListPage> {
  List<Map<String, dynamic>> templates = [];

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  void loadTemplates() async {
    final data = await TemplateStorage.getTemplates();
    setState(() {
      templates = data;
    });
  }

  void deleteTemplate(int index) async {
    await TemplateStorage.deleteTemplate(index);
    loadTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Templates")),
      body: ListView.builder(
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          final timestamp = DateTime.tryParse(template['timestamp'] ?? '');

          return Card(
            child: ListTile(
              title: Text("Template #${index + 1}"),
              subtitle: Text(
                "Saved on: ${timestamp != null ? timestamp.toLocal().toString() : "N/A"}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteTemplate(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      final items = List<Map<String, dynamic>>.from(
                        template['items'],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PreviewPage(items: items),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
