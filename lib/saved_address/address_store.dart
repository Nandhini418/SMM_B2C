import 'address_model.dart';

class AddressStore {
  AddressStore._();
  static final AddressStore instance = AddressStore._();

  List<AddressModel> addresses = [];

  // No load() needed — memory only
  Future<void> load() async {}  // keep this so existing call sites don't break

  Future<void> add(AddressModel addr) async {
    if (addresses.isEmpty) {
      addresses.add(addr.copyWith(isDefault: true));
    } else {
      addresses.add(addr);
    }
  }

  Future<void> delete(int index) async {
    addresses.removeAt(index);
    if (addresses.isNotEmpty && !addresses.any((a) => a.isDefault)) {
      addresses[0] = addresses[0].copyWith(isDefault: true);
    }
  }

  Future<void> update(int index, AddressModel updated) async {
    addresses[index] = updated.copyWith(isDefault: addresses[index].isDefault);
  }

  Future<void> markDefault(int index) async {
    for (int i = 0; i < addresses.length; i++) {
      addresses[i] = addresses[i].copyWith(isDefault: i == index);
    }
  }
}