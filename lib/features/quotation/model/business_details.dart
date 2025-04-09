class BusinessDetails {
  final String businessName;
  final String address;
  final String phone;
  final String email;
  final String logoPath;

  BusinessDetails({
    required this.businessName,
    required this.address,
    required this.phone,
    required this.email,
    required this.logoPath,
  });

  Map<String, String> toMap() => {
    'businessName': businessName,
    'address': address,
    'phone': phone,
    'email': email,
    'logoPath': logoPath,
  };

  factory BusinessDetails.fromMap(Map<String, String> map) => BusinessDetails(
    businessName: map['businessName'] ?? '',
    address: map['address'] ?? '',
    phone: map['phone'] ?? '',
    email: map['email'] ?? '',
    logoPath: map['logoPath'] ?? '',
  );
}
