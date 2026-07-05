import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:flutter/material.dart';

class MyProfileData extends ChangeNotifier {
  static ValueNotifier<Map<String, dynamic>> data = ValueNotifier({});
  static String bucket = "usersDatabaseByBugDatabase135153";
  static Future<void> getMyProfile() async {
    String? myUID = await ByBugAuth.getUID();
    if (myUID == null) return;
    if (myUID.trim().isEmpty) return;
    var datas = await ByBugDatabase.get(bucket, myUID);
    data.value = datas["value"];
    data.notifyListeners();
  }

  static Future<Map<String, dynamic>> getProfile(String uid) async {
    var datas = await ByBugDatabase.get(bucket, uid);
    return datas["value"];
  }

  static String name() {
    return data.value["name"] ?? "";
  }

  static String status() {
    return data.value["data"]?["status"] ?? "active";
  }

  static String uid() {
    return data.value["uid"] ?? "";
  }

  static String photo() {
    return data.value["photo"] ?? "";
  }

  static List follower() {
    final raw = data.value["data"]?["follower"];
    if (raw is List) return raw;
    return [];
  }

  static bool isAdmin() {
    return data.value["data"]?["isAdmin"] == true;
  }

  static bool premium() {
    return data.value["data"]?["verify"] == true;
  }

  static List cripto() {
    final raw = data.value["data"]?["cripto"];
    if (raw is List) return raw;
    return [];
  }

  static Map<String, dynamic> social() {
    final raw = data.value["data"]?["social"];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  static String bio() {
    return data.value["data"]?["bio"] ?? "";
  }

  static Future<void> addFavorite(
    String image,
    String details,
    String name,
  ) async {
    List c = cripto();
    c.add({"image": image, "details": details, "name": name});
    await setProfile(cripto: c);
  }

  static bool hasFavorite(String name) {
    List c = cripto();
    for (var element in c) {
      if (element["name"] == name) {
        return true;
      }
    }
    return false;
  }

  static Future<void> removeFavorite(String name) async {
    List c = cripto();
    dynamic el;
    for (var element in c) {
      if (element["name"] == name) {
        el = element;
      }
    }
    c.remove(el);
    await setProfile(cripto: c);
  }

  static Future<void> setProfile({
    String? name,
    String? uidss,
    String? status,
    String? photo,
    String? bio,
    bool? verify,
    bool? isAdmin,
    Map<String, dynamic>? social,
    List? follower,
    List? cripto,
  }) async {
    String? myUID = uidss ?? await ByBugAuth.getUID();
    if (myUID == null) return;
    if (myUID.trim().isEmpty) return;
    var datas = await ByBugDatabase.get(bucket, myUID);
    if (photo != null) datas["value"]["photo"] = photo;
    if (name != null) datas["value"]["name"] = name;
    if (bio != null) datas["value"]["data"]["bio"] = bio;
    if (verify != null) datas["value"]["data"]["verify"] = verify;
    if (status != null) datas["value"]["data"]["status"] = status;
    if (isAdmin != null) datas["value"]["data"]["isAdmin"] = isAdmin;
    if (social != null) datas["value"]["data"]["social"] = social;
    if (cripto != null) datas["value"]["data"]["cripto"] = cripto;
    await ByBugDatabase.update(bucket, myUID, datas["value"]);
    data.value = datas["value"];
    data.notifyListeners();
  }
}

class YouProfileData extends ChangeNotifier {
  static ValueNotifier<Map<String, dynamic>> data = ValueNotifier({});
  static String bucket = "usersDatabaseByBugDatabase135153";
  static Future<void> getMyProfile(String myUID) async {
    if (myUID.trim().isEmpty) return;
    var datas = await ByBugDatabase.get(bucket, myUID);
    data.value = datas["value"];
    data.notifyListeners();
  }

  static Future<Map<String, dynamic>> getProfile(String uid) async {
    var datas = await ByBugDatabase.get(bucket, uid);
    return datas["value"];
  }

  static String name() {
    return data.value["name"] ?? "";
  }

  static String uid() {
    return data.value["uid"] ?? "";
  }

  static String photo() {
    return data.value["photo"] ?? "";
  }

  static List follower() {
    final raw = data.value["data"]?["follower"];
    if (raw is List) return raw;
    return [];
  }

  static bool isAdmin() {
    return data.value["data"]?["isAdmin"] == true;
  }

  static List cripto() {
    final raw = data.value["data"]?["cripto"];
    if (raw is List) return raw;
    return [];
  }

  static Map<String, dynamic> social() {
    final raw = data.value["data"]?["social"];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  static String bio() {
    return data.value["data"]?["bio"] ?? "";
  }

  static bool premium() {
    return data.value["data"]?["verify"] == true;
  }

  static String status() {
    return data.value["data"]?["status"] ?? "active";
  }
}
