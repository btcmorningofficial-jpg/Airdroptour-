import re

def wrap(path, data_class):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    pattern = re.compile(
        r'([ \t]*)var cryptoPoolRaw = await ByBugDatabase\.getAll\("crypto"\);.*?'
        r'profileCrypto\.notifyListeners\(\);',
        re.DOTALL,
    )
    m = pattern.search(content)
    if not m:
        print(f"HATA: {path} icinde blok bulunamadi (zaten sarilmis olabilir)")
        return
    indent = m.group(1)
    inner = m.group(0)
    # inner'in ic satirlarina bir tab ekle
    inner_lines = inner.split('\n')
    indented_inner = '\n'.join(
        ('  ' + line if line.strip() else line) for line in inner_lines
    )
    wrapped = (
        f'{indent}try {{\n'
        f'{indented_inner}\n'
        f'{indent}}} catch (e) {{\n'
        f'{indent}  debugPrint("CRYPTO FILL ERROR: $e");\n'
        f'{indent}  profileCrypto.value.clear();\n'
        f'{indent}  for (var element in {data_class}.cripto()) {{\n'
        f'{indent}    if (element is Map) {{\n'
        f'{indent}      profileCrypto.value.add(\n'
        f'{indent}        CryptoWidget(\n'
        f'{indent}          id: "id",\n'
        f'{indent}          photo: element["image"],\n'
        f'{indent}          name: element["name"],\n'
        f'{indent}          details: element["details"],\n'
        f'{indent}        ),\n'
        f'{indent}      );\n'
        f'{indent}    }}\n'
        f'{indent}  }}\n'
        f'{indent}  profileCrypto.notifyListeners();\n'
        f'{indent}}}'
    )
    content = content[:m.start()] + wrapped + content[m.end():]
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"OK: {path} try/catch ile sarmalandi")

wrap("/data/data/com.termux/files/home/Airdroptour-/lib/page/profile.dart", "MyProfileData")
wrap("/data/data/com.termux/files/home/Airdroptour-/lib/page/youprofile.dart", "YouProfileData")
