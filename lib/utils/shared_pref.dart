

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
   static const CURRENT_UID="com.c4coding.currentUID";
  static Future<String> getCurrentUID()async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    return preferences.getString(CURRENT_UID);
  }

  static Future<void> setCurrentUID(String currentUID) async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    preferences.setString(CURRENT_UID, currentUID);
  }
}