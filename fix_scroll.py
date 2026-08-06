import re

# 1) profile.dart: SingleChildScrollView -> AutoScrollCryptoRow (otomatik kaysın)
p_path = "/data/data/com.termux/files/home/Airdroptour-/lib/page/profile.dart"
with open(p_path, 'r', encoding='utf-8') as f:
    p = f.read()

old_scroll = re.compile(
    r'SizedBox\(\s*height:\s*80,\s*child:\s*SingleChildScrollView\(\s*'
    r'scrollDirection:\s*Axis\.horizontal,\s*'
    r'child:\s*Row\(children:\s*profileCrypto\.value\),\s*\),\s*\)',
)
m = old_scroll.search(p)
if not m:
    print("HATA: profile.dart'ta beklenen SingleChildScrollView bloğu bulunamadı")
else:
    new_block = 'AutoScrollCryptoRow(\n            children: profileCrypto.value,\n          )'
    p = p[:m.start()] + new_block + p[m.end():]
    if "widget/auto_scroll_crypto_row.dart" not in p:
        p = p.replace(
            "import 'package:airdrop/widget/text.dart';",
            "import 'package:airdrop/widget/text.dart';\nimport 'package:airdrop/widget/auto_scroll_crypto_row.dart';",
        )
    with open(p_path, 'w', encoding='utf-8') as f:
        f.write(p)
    print("OK: profile.dart -> AutoScrollCryptoRow'a donduruldu")

# 2) youprofile.dart: AutoScrollCryptoRow'u genislik sinirli bir SizedBox icine al
y_path = "/data/data/com.termux/files/home/Airdroptour-/lib/page/youprofile.dart"
with open(y_path, 'r', encoding='utf-8') as f:
    y = f.read()

old_row = re.compile(
    r'AutoScrollCryptoRow\(\s*children:\s*profileCrypto\.value,\s*\),',
)
m2 = old_row.search(y)
if not m2:
    print("HATA: youprofile.dart'ta AutoScrollCryptoRow bloğu bulunamadı")
else:
    new_row = (
        'SizedBox(\n'
        '                  width: double.infinity,\n'
        '                  child: AutoScrollCryptoRow(\n'
        '                    children: profileCrypto.value,\n'
        '                  ),\n'
        '                ),'
    )
    y = y[:m2.start()] + new_row + y[m2.end():]
    with open(y_path, 'w', encoding='utf-8') as f:
        f.write(y)
    print("OK: youprofile.dart -> AutoScrollCryptoRow genislik ile sarmalandi")
