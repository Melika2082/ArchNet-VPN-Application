import 'package:hive/hive.dart';

class UserPreferences {
  Future<bool> saveUserEmail(String email) async {
    var box = await Hive.openBox('userBox');

    box.put('email', email);

    return true;
  }

  Future<String> getUserEmail() async {
    var box = await Hive.openBox('userBox');

    return box.get('email') ?? '';
  }
}
