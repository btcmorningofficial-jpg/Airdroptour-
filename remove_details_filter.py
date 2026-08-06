files = ["lib/page/profile.dart", "lib/page/youprofile.dart"]
old = '''if ((val["name"] ?? "").toString().isEmpty) continue;
          if ((val["image"] ?? "").toString().isEmpty) continue;
          if ((val["details"] ?? "").toString().isEmpty) continue;'''
new = 'if ((val["name"] ?? "").toString().isEmpty) continue;\n          if ((val["image"] ?? "").toString().isEmpty) continue;'
for path in files:
    c = open(path, encoding="utf-8").read()
    n = c.count(old)
    print(path, "matches:", n)
    if n == 1:
        c = c.replace(old, new)
        open(path, "w", encoding="utf-8").write(c)
        print("OK patched:", path)
