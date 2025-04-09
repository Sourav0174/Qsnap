import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TemplateStorage {
  static const String _key = 'saved_templates';

  static Future<List<Map<String, dynamic>>> getTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> saveTemplate(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    final updated = [
      ...existing,
      jsonEncode({
        "items": items,
        "timestamp": DateTime.now().toIso8601String(),
      }),
    ];
    await prefs.setStringList(_key, updated);
  }

  static Future<void> deleteTemplate(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.removeAt(index);
    await prefs.setStringList(_key, existing);
  }
}
