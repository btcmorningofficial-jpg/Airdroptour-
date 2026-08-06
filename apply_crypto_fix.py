import sys

def patch(path, old, new, label):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    count = content.count(old)
    if count != 1:
        print(f"HATA [{label}]: eslesme sayisi {count} (1 olmali). Dosya degistirilmedi: {path}")
        sys.exit(1)
    content = content.replace(old, new)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"OK: {label}")

base = "/data/data/com.termux/files/home/Airdroptour-/lib"

# 1) services/profile.dart -- helper fonksiyonu dosya sonuna ekle
svc_path = f"{base}/services/profile.dart"
with open(svc_path, 'r', encoding='utf-8') as f:
    svc_content = f.read()
if "fillToThreeCryptos" in svc_content:
    print("OK: fillToThreeCryptos zaten mevcut, atlaniyor")
else:
    helper = '''
List<Map<String, dynamic>> fillToThreeCryptos(
  List raw,
  List<Map<String, dynamic>> pool,
) {
  List<Map<String, dynamic>> result = [];
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
  return result;
}
'''
    with open(svc_path, 'a', encoding='utf-8') as f:
        f.write(helper)
    print("OK: fillToThreeCryptos eklendi")

# 2) page/profile.dart -- kendi profilim
p_path = f"{base}/page/profile.dart"
p_old = '''      profileCrypto.value.clear();
      for (var element in MyProfileData.cripto()) {
        if (true) {
          profileCrypto.value.add(
            CryptoWidget(
              id: "id",
              photo: element["image"],
              name: element["name"],
              details: element["details"],
            ),
          );
        }
      }
      profileCrypto.notifyListeners();'''
p_new = '''      var cryptoPoolRaw = await ByBugDatabase.getAll("crypto");
      List<Map<String, dynamic>> cryptoPool = [];
      for (var element in cryptoPoolRaw) {
        Map<String, dynamic> val = Map<String, dynamic>.from(
          element["value"] ?? {},
        );
        if ((val["name"] ?? "").toString().isEmpty) continue;
        cryptoPool.add(val);
      }
      var finalCryptos = fillToThreeCryptos(
        MyProfileData.cripto(),
        cryptoPool,
      );
      profileCrypto.value.clear();
      for (var element in finalCryptos) {
        profileCrypto.value.add(
          CryptoWidget(
            id: "id",
            photo: element["image"],
            name: element["name"],
            details: element["details"],
          ),
        );
      }
      profileCrypto.notifyListeners();'''
patch(p_path, p_old, p_new, "profile.dart (kendi profilim)")

# 3) page/youprofile.dart -- baskasinin profili
y_path = f"{base}/page/youprofile.dart"
y_old = '''      profileCrypto.value.clear();
      for (var element in YouProfileData.cripto()) {
        if (true) {
          profileCrypto.value.add(
            CryptoWidget(
              readOnly: true,
              id: "id",
              photo: element["image"],
              name: element["name"],
              details: element["details"],
            ),
          );
        }
      }
      profileCrypto.notifyListeners();'''
y_new = '''      var cryptoPoolRaw = await ByBugDatabase.getAll("crypto");
      List<Map<String, dynamic>> cryptoPool = [];
      for (var element in cryptoPoolRaw) {
        Map<String, dynamic> val = Map<String, dynamic>.from(
          element["value"] ?? {},
        );
        if ((val["name"] ?? "").toString().isEmpty) continue;
        cryptoPool.add(val);
      }
      var finalCryptos = fillToThreeCryptos(
        YouProfileData.cripto(),
        cryptoPool,
      );
      profileCrypto.value.clear();
      for (var element in finalCryptos) {
        profileCrypto.value.add(
          CryptoWidget(
            readOnly: true,
            id: "id",
            photo: element["image"],
            name: element["name"],
            details: element["details"],
          ),
        );
      }
      profileCrypto.notifyListeners();'''
patch(y_path, y_old, y_new, "youprofile.dart (baskasinin profili)")

print("TAMAM: tum yamalar uygulandi")
