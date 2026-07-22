import re

path = "/data/data/com.termux/files/home/Airdroptour-/lib/page/profile.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

pattern = re.compile(
    r'([ \t]*)profileCrypto\.value\.clear\(\);\s*\n'
    r'\s*for \(var element in MyProfileData\.cripto\(\)\) \{.*?\n'
    r'\s*profileCrypto\.notifyListeners\(\);',
    re.DOTALL,
)

m = pattern.search(content)
if not m:
    print("HATA: desen bulunamadi. profile.dart'ta beklenen blok yok.")
    raise SystemExit(1)

indent = m.group(1)
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
    f'{indent}  MyProfileData.cripto(),\n'
    f'{indent}  cryptoPool,\n'
    f'{indent});\n'
    f'{indent}profileCrypto.value.clear();\n'
    f'{indent}for (var element in finalCryptos) {{\n'
    f'{indent}  profileCrypto.value.add(\n'
    f'{indent}    CryptoWidget(\n'
    f'{indent}      id: "id",\n'
    f'{indent}      photo: element["image"],\n'
    f'{indent}      name: element["name"],\n'
    f'{indent}      details: element["details"],\n'
    f'{indent}    ),\n'
    f'{indent}  );\n'
    f'{indent}}}\n'
    f'{indent}profileCrypto.notifyListeners();'
)

content = content[:m.start()] + new_block + content[m.end():]
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("OK: profile.dart yamandi")
