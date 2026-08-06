import re

BASE = "/data/data/com.termux/files/home/Airdroptour-/lib"


def read(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


# 1) services/profile.dart -- havuzdan tamamlama fonksiyonu var mi kontrol et, yoksa ekle
svc_path = f"{BASE}/services/profile.dart"
svc = read(svc_path)

if "fillToThreeCryptos" in svc:
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
    write(svc_path, svc + helper)
    print("OK: fillToThreeCryptos eklendi")

# Su an dosyalarda calisan "basit" blogu yakala (havuz mantigi olmadan sadece
# kullanicinin kendi kripto listesini gosteren surum)
SIMPLE_BLOCK_RE = re.compile(
    r"([ \t]*)profileCrypto\.value\.clear\(\);\s*\n"
    r"\s*for\s*\(\s*var element in (MyProfileData|YouProfileData)\.cripto\(\)\s*\)\s*\{.*?"
    r"profileCrypto\.notifyListeners\(\);",
    re.DOTALL,
)

ALREADY_POOLED_RE = re.compile(r"var\s+cryptoPoolRaw")


def patch_page(path, data_class, read_only):
    content = read(path)

    if ALREADY_POOLED_RE.search(content):
        print(f"OK: {path} zaten havuz tabanli, degisiklik gerekmiyor")
        return

    m = SIMPLE_BLOCK_RE.search(content)
    if not m:
        print(f"HATA: {path} icinde beklenen blok bulunamadi, elle kontrol et")
        return

    indent = m.group(1)
    ro = f'readOnly: true,\n{indent}      ' if read_only else ""

    new_block = (
        f'{indent}var cryptoPoolRaw = await ByBugDatabase.getAll("crypto");\n'
        f'{indent}List<Map<String, dynamic>> cryptoPool = [];\n'
        f'{indent}for (var element in cryptoPoolRaw) {{\n'
        f'{indent}  Map<String, dynamic> val = Map<String, dynamic>.from(\n'
        f'{indent}    element["value"] ?? {{}},\n'
        f'{indent}  );\n'
        f'{indent}  if ((val["name"] ?? "").toString().isEmpty) continue;\n'
        f'{indent}  cryptoPool.add(val);\n'
        f'{indent}}}\n'
        f'{indent}var finalCryptos = fillToThreeCryptos(\n'
        f'{indent}  {data_class}.cripto(),\n'
        f'{indent}  cryptoPool,\n'
        f'{indent});\n'
        f'{indent}profileCrypto.value.clear();\n'
        f'{indent}for (var element in finalCryptos) {{\n'
        f'{indent}  profileCrypto.value.add(\n'
        f'{indent}    CryptoWidget(\n'
        f'{indent}      {ro}id: "id",\n'
        f'{indent}      photo: element["image"],\n'
        f'{indent}      name: element["name"],\n'
        f'{indent}      details: element["details"],\n'
        f'{indent}    ),\n'
        f'{indent}  );\n'
        f'{indent}}}\n'
        f'{indent}profileCrypto.notifyListeners();'
    )

    content = content[: m.start()] + new_block + content[m.end() :]
    write(path, content)
    print(f"OK: {path} guncellendi (havuzdan tamamlama eklendi)")


patch_page(f"{BASE}/page/profile.dart", "MyProfileData", read_only=False)
patch_page(f"{BASE}/page/youprofile.dart", "YouProfileData", read_only=True)

print("TAMAM: kripto ikonlari artik bos profillerde de havuzdan tamamlanarak gozukecek")
