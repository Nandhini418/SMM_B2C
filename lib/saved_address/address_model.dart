class AddressModel {
  final String name;
  final String phone;
  final String pincode;
  final String city;
  final String state;
  final String locality;
  final String flatNo;
  final String landmark;
  final String type;
  final bool isDefault;

  AddressModel({
    required this.name,
    required this.phone,
    required this.pincode,
    required this.city,
    required this.state,
    required this.locality,
    required this.flatNo,
    this.landmark = '',
    required this.type,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? name,
    String? phone,
    String? pincode,
    String? city,
    String? state,
    String? locality,
    String? flatNo,
    String? landmark,
    String? type,
    bool? isDefault,
  }) =>
      AddressModel(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        pincode: pincode ?? this.pincode,
        city: city ?? this.city,
        state: state ?? this.state,
        locality: locality ?? this.locality,
        flatNo: flatNo ?? this.flatNo,
        landmark: landmark ?? this.landmark,
        type: type ?? this.type,
        isDefault: isDefault ?? this.isDefault,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'pincode': pincode,
    'city': city,
    'state': state,
    'locality': locality,
    'flatNo': flatNo,
    'landmark': landmark,
    'type': type,
    'isDefault': isDefault,
  };

  String _formatPincode(String pincode) {
    if (pincode.length == 6) {
      return '${pincode.substring(0, 3)} ${pincode.substring(3)}';
    }
    return pincode;
  }

  factory AddressModel.fromJson(Map<String, dynamic> j) => AddressModel(
    name: j['name'],
    phone: j['phone'],
    pincode: j['pincode'],
    city: j['city'],
    state: j['state'],
    locality: j['locality'],
    flatNo: j['flatNo'],
    landmark: j['landmark'] ?? '',
    type: j['type'],
    isDefault: j['isDefault'] ?? false,
  );

  String get shortAddress =>
      '$locality, $city - ${_formatPincode(pincode)}.';
}