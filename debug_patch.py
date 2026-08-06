path = "lib/page/profile.dart"
old = 'child: h3("•", color: textColor.withOpacity(0.5)),'
new = 'child: h3("COUNT: ${profileCrypto.value.length}", color: textColor.withOpacity(0.5)),'
c = open(path, encoding="utf-8").read()
n = c.count(old)
print("matches:", n)
if n == 1:
    c = c.replace(old, new)
    open(path, "w", encoding="utf-8").write(c)
    print("OK patched")
