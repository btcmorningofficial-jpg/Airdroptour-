path = "/data/data/com.termux/files/home/Airdroptour-/lib/page/profile.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

marker = 'Expanded(\n                    child: AutoScrollCryptoRow(\n                      children: profileCrypto.value,\n                    ),\n                  ),'
if marker not in content:
    import re
    pattern = re.compile(r'Expanded\(\s*child:\s*AutoScrollCryptoRow\(\s*children:\s*profileCrypto\.value,\s*\),\s*\),')
    m = pattern.search(content)
    if not m:
        print("HATA: blok bulunamadı")
        raise SystemExit(1)
    marker = m.group(0)

replacement = marker + '\n                Text(\n                  "DEBUG cripto=${MyProfileData.cripto().length} profileCrypto=${profileCrypto.value.length}",\n                  style: const TextStyle(color: Colors.red, fontSize: 12),\n                ),'
content = content.replace(marker, replacement, 1)
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("OK: debug metni eklendi")
