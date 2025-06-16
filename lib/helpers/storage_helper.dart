import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/project.dart';

class StorageHelper {
  static const _key = 'projects_data';

  static Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final data = projects.map((p) => p.toMap()).toList();
    prefs.setString(_key, jsonEncode(data));
  }

  static Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_key);
    if (dataString == null) return [];
    final dataList = jsonDecode(dataString) as List;
    return dataList.map((e) => Project.fromMap(e)).toList();
  }
}
