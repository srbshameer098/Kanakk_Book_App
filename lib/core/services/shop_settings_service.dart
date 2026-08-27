import 'package:shared_preferences/shared_preferences.dart';

class ShopSettingsService {
  static const String _kShopName = 'shop_name';
  static const String _kOwnerName = 'owner_name';
  static const String _kPhoneNumber = 'phone_number';
  static const String _kAddress = 'address';
  
  static Future<String> getShopName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kShopName) ?? 'My Shop';
  }

  static Future<void> setShopName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kShopName, name);
  }

  static Future<String> getOwnerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kOwnerName) ?? '';
  }

  static Future<void> setOwnerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOwnerName, name);
  }

  static Future<String> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPhoneNumber) ?? '';
  }

  static Future<void> setPhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPhoneNumber, phone);
  }

  static Future<String> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAddress) ?? '';
  }

  static Future<void> setAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAddress, address);
  }
}
