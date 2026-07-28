import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:flutter/material.dart';

class MyProfileData extends ChangeNotifier {
  static ValueNotifier<Map<String, dynamic>> data = ValueNotifier({});
  static String bucket = "usersDatabaseByBugDatabase135153";
  
  // setProfile ayni anda birden fazla kez cagrilirsa (hizli favori
  // ekle/cikar gibi), her cagri sirayla calissin diye kullanilan kuyruk.
  // Boylece "oku -> degistir -> yaz" adimlari arasinda baska bir yazma
  // araya girip degisikligi silemez (race condition onlenir).
  static Future<void> _writeQueue = Future.value();
  
  // 🔥 KRİTİK: getMyProfile tamamen yeniden yazıldı - ÇÖKMEYİ ÖNLEMEK İÇİN!
  static Future<void> getMyProfile() async {
    try {
      // API başlatılmış mı kontrol et
      if (ByBugDB.apiBaseUrl.isEmpty) {
        debugPrint("❌ API başlatılmamış! Varsayılan profil kullanılıyor");
        _setDefaultProfile();
        return;
      }
      
      String? myUID = await ByBugAuth.getUID();
      if (myUID == null || myUID.trim().isEmpty) {
        debugPrint("❌ UID boş, varsayılan profil kullanılıyor");
        _setDefaultProfile();
        return;
      }
      
      debugPrint("✅ Profil yükleniyor: $myUID");
      var datas = await ByBugDatabase.get(bucket, myUID);
      
      if (datas == null) {
        debugPrint("❌ Veritabanı null döndü");
        _setDefaultProfile();
        return;
      }
      
      final newValue = datas["value"];
      debugPrint("✅ Veri alındı: $newValue");
      
      if (newValue is Map && newValue.isNotEmpty) {
        data.value = Map<String, dynamic>.from(newValue);
        data.notifyListeners();
        debugPrint("✅ Profil başarıyla yüklendi");
      } else {
        debugPrint("⚠️ Profil verisi boş veya geçersiz, varsayılan kullanılıyor");
        _setDefaultProfile();
      }
    } catch (e, stacktrace) {
      debugPrint("❌❌❌ PROFİL ÇÖKTÜ! ❌❌❌");
      debugPrint("Hata: $e");
      debugPrint("Stacktrace: $stacktrace");
      _setDefaultProfile();
    }
  }

  // 🔥 YENİ: Varsayılan profil fonksiyonu (çökme durumunda kullanılır)
  static void _setDefaultProfile() {
    data.value = {
      "name": "Kullanıcı",
      "photo": "",
      "uid": "",
      "data": {
        "status": "active",
        "follower": [],
        "cripto": [],
        "social": {},
        "bio": "Merhaba! 👋",
        "verify": false,
        "isAdmin": false,
        "profileCompleted": true
      }
    };
    data.notifyListeners();
    debugPrint("✅ Varsayılan profil ayarlandı");
  }

  static Future<Map<String, dynamic>> getProfile(String uid) async {
    try {
      var datas = await ByBugDatabase.get(bucket, uid);
      return datas["value"] ?? {};
    } catch (e) {
      debugPrint("getProfile hatası: $e");
      return {};
    }
  }

  static String name() {
    try {
      return data.value["name"] ?? "Kullanıcı";
    } catch (e) {
      return "Kullanıcı";
    }
  }

  static String status() {
    try {
      return data.value["data"]?["status"] ?? "active";
    } catch (e) {
      return "active";
    }
  }

  static String uid() {
    try {
      return data.value["uid"] ?? "";
    } catch (e) {
      return "";
    }
  }

  static String photo() {
    try {
      return data.value["photo"] ?? "";
    } catch (e) {
      return "";
    }
  }

  static List follower() {
    try {
      final raw = data.value["data"]?["follower"];
      if (raw is List) return raw;
      return [];
    } catch (e) {
      return [];
    }
  }

  static bool isAdmin() {
    try {
      return data.value["data"]?["isAdmin"] == true;
    } catch (e) {
      return false;
    }
  }

  static bool premium() {
    try {
      return data.value["data"]?["verify"] == true;
    } catch (e) {
      return false;
    }
  }

  static List cripto() {
    try {
      final raw = data.value["data"]?["cripto"];
      if (raw is List) return raw;
      return [];
    } catch (e) {
      return [];
    }
  }

  static Map<String, dynamic> social() {
    try {
      final raw = data.value["data"]?["social"];
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return {};
    } catch (e) {
      return {};
    }
  }

  static String bio() {
    try {
      return data.value["data"]?["bio"] ?? "Merhaba! 👋";
    } catch (e) {
      return "Merhaba! 👋";
    }
  }

  static String? gender() {
    try {
      return data.value["data"]?["gender"];
    } catch (e) {
      return null;
    }
  }

  // Eski kullanıcılar bu alana sahip değil; onlar için varsayılan olarak
  // "tamamlanmış" say (mevcut kullanıcıları zorunlu ekrana düşürme).
  static bool profileCompleted() {
    try {
      final v = data.value["data"]?["profileCompleted"];
      if (v == null) return true;
      return v == true;
    } catch (e) {
      return true;
    }
  }

  static Future<void> addFavorite(
    String image,
    String details,
    String name, {
    String? website,
  }) {
    return setProfile(
      criptoMutator: (current) {
        current.add({
          "image": image,
          "details": details,
          "name": name,
          if (website != null && website.isNotEmpty) "website": website,
        });
        return current;
      },
    );
  }

  static bool hasFavorite(String name) {
    try {
      List c = cripto();
      for (var element in c) {
        if (element["name"] == name) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> removeFavorite(String name) {
    return setProfile(
      criptoMutator: (current) {
        current.removeWhere((element) => element["name"] == name);
        return current;
      },
    );
  }

  static Future<void> setProfile({
    String? name,
    String? uidss,
    String? status,
    String? photo,
    String? bio,
    String? gender,
    bool? verify,
    bool? isAdmin,
    bool? profileCompleted,
    Map<String, dynamic>? social,
    List? follower,
    List? cripto,
    List Function(List current)? criptoMutator,
  }) {
    final future = _writeQueue.then((_) async {
      try {
        String? myUID = uidss ?? await ByBugAuth.getUID();
        if (myUID == null) return;
        if (myUID.trim().isEmpty) return;
        var datas = await ByBugDatabase.get(bucket, myUID);
        datas["value"] ??= <String, dynamic>{};
        datas["value"]["data"] ??= <String, dynamic>{};
        if (photo != null) datas["value"]["photo"] = photo;
        if (name != null) datas["value"]["name"] = name;
        if (bio != null) datas["value"]["data"]["bio"] = bio;
        if (gender != null) datas["value"]["data"]["gender"] = gender;
        if (verify != null) datas["value"]["data"]["verify"] = verify;
        if (status != null) datas["value"]["data"]["status"] = status;
        if (isAdmin != null) datas["value"]["data"]["isAdmin"] = isAdmin;
        if (profileCompleted != null) {
          datas["value"]["data"]["profileCompleted"] = profileCompleted;
        }
        if (social != null) datas["value"]["data"]["social"] = social;
        if (criptoMutator != null) {
          List current = List.from(datas["value"]["data"]["cripto"] ?? []);
          datas["value"]["data"]["cripto"] = criptoMutator(current);
        } else if (cripto != null) {
          datas["value"]["data"]["cripto"] = cripto;
        }
        await ByBugDatabase.update(bucket, myUID, datas["value"]);
        data.value = datas["value"];
        data.notifyListeners();
      } catch (e) {
        debugPrint("setProfile hatası: $e");
      }
    });
    _writeQueue = future.catchError((_) {});
    return future;
  }
}

class YouProfileData extends ChangeNotifier {
  static ValueNotifier<Map<String, dynamic>> data = ValueNotifier({});
  static String bucket = "usersDatabaseByBugDatabase135153";
  
  static Future<void> getMyProfile(String myUID) async {
    try {
      if (myUID.trim().isEmpty) return;
      var datas = await ByBugDatabase.get(bucket, myUID);
      data.value = datas["value"] ?? {};
      data.notifyListeners();
    } catch (e) {
      debugPrint("YouProfileData getMyProfile hatası: $e");
      data.value = {};
      data.notifyListeners();
    }
  }

  static Future<Map<String, dynamic>> getProfile(String uid) async {
    try {
      var datas = await ByBugDatabase.get(bucket, uid);
      return datas["value"] ?? {};
    } catch (e) {
      return {};
    }
  }

  static String name() {
    try {
      return data.value["name"] ?? "";
    } catch (e) {
      return "";
    }
  }

  static String uid() {
    try {
      return data.value["uid"] ?? "";
    } catch (e) {
      return "";
    }
  }

  static String photo() {
    try {
      return data.value["photo"] ?? "";
    } catch (e) {
      return "";
    }
  }

  static List follower() {
    try {
      final raw = data.value["data"]?["follower"];
      if (raw is List) return raw;
      return [];
    } catch (e) {
      return [];
    }
  }

  static bool isAdmin() {
    try {
      return data.value["data"]?["isAdmin"] == true;
    } catch (e) {
      return false;
    }
  }

  static List cripto() {
    try {
      final raw = data.value["data"]?["cripto"];
      if (raw is List) return raw;
      return [];
    } catch (e) {
      return [];
    }
  }

  static Map<String, dynamic> social() {
    try {
      final raw = data.value["data"]?["social"];
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return {};
    } catch (e) {
      return {};
    }
  }

  static String bio() {
    try {
      return data.value["data"]?["bio"] ?? "";
    } catch (e) {
      return "";
    }
  }

  static bool premium() {
    try {
      return data.value["data"]?["verify"] == true;
    } catch (e) {
      return false;
    }
  }

  static String status() {
    try {
      return data.value["data"]?["status"] ?? "active";
    } catch (e) {
      return "active";
    }
  }
}

List<Map<String, dynamic>> fillToThreeCryptos(
  List raw,
  List<Map<String, dynamic>> pool,
) {
  List<Map<String, dynamic>> result = [];
  try {
    for (var element in raw) {
      if (element is Map) {
        result.add(Map<String, dynamic>.from(element));
      }
    }
    if (result.length > 3) {
      result = result.sublist(0, 3);
    } else if (result.length < 3) {
      final usedNames = result.map((e) => e["name"]).toSet();
      final candidates = pool
          .where((c) => !usedNames.contains(c["name"]))
          .toList();
      candidates.shuffle();
      for (var c in candidates) {
        if (result.length >= 3) break;
        result.add({
          "image": c["image"],
          "name": c["name"],
          "details": c["details"],
        });
      }
    }
  } catch (e) {
    debugPrint("fillToThreeCryptos hatası: $e");
  }
  return result;
}