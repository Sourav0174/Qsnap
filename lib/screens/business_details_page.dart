import 'package:flutter/material.dart';
import 'package:quotation_generator/core/constants/colors.dart';

import 'package:quotation_generator/features/quotation/model/business_details.dart';
import '../services/business_details_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// Adjust path if needed

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = BusinessDetailsService();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  String _logoPath = '';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final details = await _service.loadBusinessDetails();
    if (details != null) {
      setState(() {
        _name.text = details.businessName;
        _address.text = details.address;
        _phone.text = details.phone;
        _email.text = details.email;
        _logoPath = details.logoPath;
      });
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _logoPath = result.files.single.path ?? '';
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final details = BusinessDetails(
        businessName: _name.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        logoPath: _logoPath,
      );
      await _service.saveBusinessDetails(details);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Business details saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Business Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  _buildTextField(_name, 'Business Name', validator: true),
                  _buildTextField(_address, 'Address'),
                  _buildTextField(_phone, 'Phone'),
                  _buildTextField(_email, 'Email'),
                  const SizedBox(height: 16),

                  Text(
                    'Business Logo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickLogo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Pick Logo'),
                      ),
                      const SizedBox(width: 12),
                      if (_logoPath.isNotEmpty)
                        Expanded(child: Text(_logoPath.split('/').last)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_logoPath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(_logoPath),
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool validator = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.background.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator ? (v) => v!.isEmpty ? 'Required' : null : null,
      ),
    );
  }
}
