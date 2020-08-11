import 'package:shared_preferences/shared_preferences.dart';

class ProfileHelper {

  static Future select(int id) async
  {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile', id);

  }

  static Future getSelectedProfile() async
  {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    int selectedProfile = prefs.getInt('profile');

    return selectedProfile;
  }
}