import 'package:shared_preferences/shared_preferences.dart';

class UserHelper {

  static Future <void> setRoles(List<String> roles) async
  {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('user_roles', roles);
  }

  static Future <List<String>> getRoles() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    List<String> userRoles = prefs.getStringList('user_roles');

    return userRoles;
  }
}