import re

files = ["lib/page/profile.dart", "lib/page/youprofile.dart"]

PATTERN = re.compile(
    r"([ \t]*)profileCrypto\.value\.clear\(\);\s*\n"
    r"\s*for\s*\(\s*var element in finalCryptos\s*\)\s*\{.*?"
    r"profileCrypto\.notifyListeners\(\);",
    re.DOTALL,
)

def build_block(indent):
    return (
        f'{indent}profileCrypto.value.clear();\n'
        f'{indent}for (var element in finalCryptos) {{\n'
        f'{indent}  profileCrypto.value.add(\n'
        f'{indent}    Container(\n'
        f'{indent}      width: 70,\n'
        f'{indent}      height: 70,\n'
        f'{indent}      margin: const EdgeInsets.symmetric(horizontal: 6),\n'
        f'{indent}      decoration: BoxDecoration(\n'
        f'{indent}        color: Colors.orange,\n'
        f'{indent}        borderRadius: BorderRadius.circular(35),\n'
        f'{indent}      ),\n'
        f'{indent}      alignment: Alignment.center,\n'
        f'{indent}      child: Text(\n'
        f'{indent}        (element["name"] ?? "?").toString(),\n'
        f'{indent}        style: const TextStyle(\n'
        f'{indent}          fontSize: 12,\n'
        f'{indent}          color: Colors.black,\n'
        f'{indent}          fontWeight: FontWeight.bold,\n'
        f'{indent}        ),\n'
        f'{indent}        textAlign: TextAlign.center,\n'
        f'{indent}        maxLines: 2,\n'
        f'{indent}        overflow: TextOverflow.ellipsis,\n'
        f'{indent}      ),\n'
        f'{indent}    ),\n'
        f'{indent}  );\n'
        f'{indent}}}\n'
        f'{indent}profileCrypto.notifyListeners();'
    )

for path in files:
    c = open(path, encoding="utf-8").read()
    m = PATTERN.search(c)
    if not m:
        print("HATA:", path, "- blok bulunamadi")
        continue
    indent = m.group(1)
    c = c[: m.start()] + build_block(indent) + c[m.end() :]
    open(path, "w", encoding="utf-8").write(c)
    print("OK:", path, "guncellendi")
