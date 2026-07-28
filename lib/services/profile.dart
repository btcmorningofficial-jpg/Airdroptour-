import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:flutter/material.dart';

class MyProfileData extends ChangeNotifier {
  static ValueNotifier<Map<String, dynamic>> data = ValueNotifier({});
  static String bucket = "usersDatabaseByBugDatabase135153";
  static Future<void> _writeQueue = Future.value();

  static Future<void> getMyProfile() async {
    try {
      if (ByBugDB.apiBaseUrl.isEmpty) {
        debugPrint("❌ API not initialized! Using default profile.");
        _setDefaultProfile();
        return;
      }

      String? myUID = await ByBugAuth.getUID();
      if (myUID == null || myUID.trim().isEmpty) {
        debugPrint("❌ UID is empty! Using default profile.");
        _setDefaultProfile();
        return;
      }

      debugPrint("✅ Loading profile: $myUID");
      var datas = await ByBugDatabase.get(bucket, myUID);

      if (datas == null) {
        debugPrint("❌ Database returned null! Using default profile.");
        _setDefaultProfile();
        return;
      }

      final newValue = datas["value"];

      if (newValue is Map && newValue.isNotEmpty) {
        data.value = Map<String, dynamic>.from(newValue);
        data.notifyListeners();
        debugPrint("✅ Profile loaded successfully.");
      } else {
        debugPrint("⚠️ Profile data is empty or invalid. Using default profile.");
        _setDefaultProfile();
      }
    } catch (e, stacktrace) {
      debugPrint("❌❌❌ PROFILE CRASH! ❌❌❌");
      debugPrint("Error: $e");
      debugPrint("Stacktrace: $stacktrace");
      _setDefaultProfile();
    }
  }

  static void _setDefaultProfile() {
    data.value = {
      "name": "User",
      "photo": "",
      "uid": "",
      "data": {
        "status": "active",
        "follower": [],
        "cripto": [],
        "social": {},
        "bio": "Hello! 👋",
        "verify": false,
        "isAdmin": false,
        "profileCompleted": true
      }
    };
    data.notifyListeners();
    debugPrint("✅ Default profile set.");
  }

  static Future<Map<String, dynamic>> getProfile(String uid) async {
    try {
      var datas = await ByBugDatabase.get(bucket, uid);
      return datas["value"] ?? {};
    } catch (e) {
      debugPrint("getProfile error: $e");
      return {};
    }
  }

  static String name() {
    try {
      return data.value["name"] ?? "User";
    } catch (e) {
      return "User";
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
      return data.value["data"]?["bio"] ?? "Hello! 👋";
    } catch (e) {
      return "Hello! 👋";
    }
  }

  static String? gender() {
    try {
      return data.value["data"]?["gender"];
    } catch (e) {
      return null;
    }
  }

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
        debugPrint("setProfile error: $e");
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
      debugPrint("YouProfileData getMyProfile error: $e");
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

// ✅ FIXED: fillToThreeCryptos - NEVER CRASHES!
List<Map<String, dynamic>> fillToThreeCryptos(
  List raw,
  List<Map<String, dynamic>> pool,
) {
  List<Map<String, dynamic>> result = [];

  try {
    // 🔥 1. Get user's selected coins
    if (raw != null && raw.isNotEmpty) {
      for (var element in raw) {
        try {
          if (element == null) continue;
          Map<String, dynamic> coin;
          if (element is Map) {
            coin = Map<String, dynamic>.from(element);
          } else {
            continue;
          }

          String name = coin["name"]?.toString() ?? "";
          if (name.isEmpty) continue;

          // Fill missing fields (for display)
          if (coin["image"] == null || coin["image"].toString().isEmpty) {
            coin["image"] = _getDefaultImageForCoin(name);
          }
          if (coin["details"] == null || coin["details"].toString().isEmpty) {
            coin["details"] = "$name cryptocurrency";
          }

          result.add(coin);
        } catch (e) {
          debugPrint("⚠️ Favorite coin conversion error: $e");
          continue;
        }
      }
    }

    debugPrint("✅ User favorite coins: ${result.length}");

    // 🔥 2. If user has NO favorites, select 3 random coins from pool (registration moment)
    if (result.isEmpty) {
      debugPrint("⚠️ No user favorites found, selecting from pool...");
      
      if (pool != null && pool.isNotEmpty) {
        // Shuffle pool and take 3 coins
        List<Map<String, dynamic>> shuffledPool = List.from(pool);
        shuffledPool.shuffle();
        
        for (var coin in shuffledPool) {
          if (result.length >= 3) break;
          try {
            if (coin == null) continue;
            String name = coin["name"]?.toString() ?? "";
            if (name.isEmpty) continue;

            Map<String, dynamic> newCoin = Map<String, dynamic>.from(coin);

            if (newCoin["image"] == null || newCoin["image"].toString().isEmpty) {
              newCoin["image"] = _getDefaultImageForCoin(name);
            }
            if (newCoin["details"] == null || newCoin["details"].toString().isEmpty) {
              newCoin["details"] = "$name cryptocurrency";
            }

            result.add(newCoin);
          } catch (e) {
            debugPrint("⚠️ Pool coin selection error: $e");
            continue;
          }
        }
      }
    }

    // 🔥 3. If still empty (pool is also empty), show default 3 coins
    if (result.isEmpty) {
      debugPrint("⚠️ Pool is empty, showing DEFAULT coins");
      result = _getDefaultCryptos();
    }

    // 🔥 4. If more than 3, trim
    if (result.length > 3) {
      result = result.sublist(0, 3);
    }

    debugPrint("✅ Displayed coins: ${result.length}");
    return result;

  } catch (e) {
    debugPrint("❌ fillToThreeCryptos CRASHED: $e");
    return _getDefaultCryptos();
  }
}

// ✅ Default image for coin names
String _getDefaultImageForCoin(String name) {
  String lowerName = name.toLowerCase();
  if (lowerName.contains("bitcoin") || lowerName.contains("btc")) {
    return "https://cryptologos.cc/logos/bitcoin-btc-logo.png";
  } else if (lowerName.contains("ethereum") || lowerName.contains("eth")) {
    return "https://cryptologos.cc/logos/ethereum-eth-logo.png";
  } else if (lowerName.contains("bnb")) {
    return "https://cryptologos.cc/logos/bnb-bnb-logo.png";
  } else if (lowerName.contains("solana") || lowerName.contains("sol")) {
    return "https://cryptologos.cc/logos/solana-sol-logo.png";
  } else if (lowerName.contains("cardano") || lowerName.contains("ada")) {
    return "https://cryptologos.cc/logos/cardano-ada-logo.png";
  } else if (lowerName.contains("ripple") || lowerName.contains("xrp")) {
    return "https://cryptologos.cc/logos/xrp-xrp-logo.png";
  } else if (lowerName.contains("dogecoin") || lowerName.contains("doge")) {
    return "https://cryptologos.cc/logos/dogecoin-doge-logo.png";
  } else if (lowerName.contains("polkadot") || lowerName.contains("dot")) {
    return "https://cryptologos.cc/logos/polkadot-dot-logo.png";
  } else {
    return "https://cryptologos.cc/logos/bitcoin-btc-logo.png";
  }
}

// ✅ DEFAULT coins (only shown if database and pool are empty)
List<Map<String, dynamic>> _getDefaultCryptos() {
  return [
    {
      "image": "https://cryptologos.cc/logos/bitcoin-btc-logo.png",
      "name": "Bitcoin",
      "details": "The world's most popular cryptocurrency"
    },
    {
      "image": "https://cryptologos.cc/logos/ethereum-eth-logo.png",
      "name": "Ethereum",
      "details": "Smart contract platform"
    },
    {
      "image": "https://cryptologos.cc/logos/bnb-bnb-logo.png",
      "name": "BNB",
      "details": "Binance Coin"
    }
  ];
}