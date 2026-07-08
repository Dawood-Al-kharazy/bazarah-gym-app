import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member_model.dart';

class StorageService {
  static const String _key = 'gym_members';

  static Future<List<Member>> getMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => Member.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> saveMembers(List<Member> members) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(members.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  static Future<String?> exportDataAsJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> importDataFromJson(String jsonString) async {
    // Validate JSON before saving
    final List<dynamic> jsonList = jsonDecode(jsonString);
    jsonList.map((e) => Member.fromJson(e)).toList(); // Throws error if invalid format
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonString);
  }
}
