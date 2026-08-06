import re

def simplify(path, data_class, extra_field=""):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # try/catch sarmali bloğu bul (varsa) veya duz blogu bul, ikisini de basit hale getir
    pattern = re.compile(
        r'([ \t]*)(?:try \{\s*\n)?'
        r'\s*var cryptoPoolRaw.*?profileCrypto\.notifyListeners\(\);\s*\n?'
        r'(?:\s*\} catch \(e\) \{.*?profileCrypto\.notifyListeners\(\);\s*\n?\s*\})?',
        re.DOTALL,
    )
    m = pattern.search(content)
    if not m:
        print(f"HATA: {path} icinde beklenen blok bulunamadi")
        return

    indent = m.group(1)
    simple_block = (
        f'{indent}profileCrypto.value.clear();\n'
        f'{indent}for (var element in {data_class}.cripto()) {{\n'
        f'{indent}  profileCrypto.value.add(\n'
        f'{indent}    CryptoWidget(\n'
        f'{indent}      {extra_field}id: "id",\n'
        f'{indent}      photo: element["image"],\n'
        f'{indent}      name: element["name"],\n'
        f'{indent}      details: element["details"],\n'
        f'{indent}    ),\n'
        f'{indent}  );\n'
        f'{indent}}}\n'
        f'{indent}profileCrypto.notifyListeners();'
    )
    content = content[:m.start()] + simple_block + content[m.end():]
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"OK: {path} basitlestirildi")

simplify("/data/data/com.termux/files/home/Airdroptour-/lib/page/profile.dart", "MyProfileData")
simplify("/data/data/com.termux/files/home/Airdroptour-/lib/page/youprofile.dart", "YouProfileData", "readOnly: true,\n      ")
