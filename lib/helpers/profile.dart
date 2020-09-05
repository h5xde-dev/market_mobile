import 'package:shared_preferences/shared_preferences.dart';

class ProfileHelper {

  static Future select(int id, String type) async
  {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile', id);
    await prefs.setString('profileType', type);

  }

  static Future<int> getSelectedProfile() async
  {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    int selectedProfile = prefs.getInt('profile');

    return selectedProfile;
  }

  static Future<String> getProfileType(int profileId) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    String selectedProfile = prefs.getString('profileType');

    return selectedProfile;
  }
}