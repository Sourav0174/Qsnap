import 'package:quotation_generator/features/quotation/model/business_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessDetailsService {
  static const _key = 'business_details';

  Future<void> saveBusinessDetails(BusinessDetails details) async {
    final prefs = await SharedPreferences.getInstance();
    details.toMap().forEach((key, value) {
      prefs.setString('$_key.$key', value);
    });
  }

  Future<BusinessDetails?> loadBusinessDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, String>{};

    for (final field in [
      'businessName',
      'address',
      'phone',
      'email',
      'logoPath',
    ]) {
      final value = prefs.getString('$_key.$field') ?? '';
      map[field] = value;
    }

    if (map.values.any((v) => v.isNotEmpty)) {
      return BusinessDetails.fromMap(map);
    }
    return null;
  }
}
