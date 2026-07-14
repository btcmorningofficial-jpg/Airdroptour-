path = "lib/page/channel_detail_page.dart"
with open(path, "r") as f:
    lines = f.readlines()

def check(idx, expected):
    actual = lines[idx].strip()
    if actual != expected:
        raise SystemExit(f"UYUŞMAZLIK satır {idx+1}:\n  beklenen: {expected!r}\n  gerçek:   {actual!r}")

# --- Edit A: Text branch (satır 236-239) -> hashtag render eden widget çağrısı ---
check(235, ": Text(")
check(236, "post['content']?.toString() ?? '',")
check(237, "style: TextStyle(color: textColor),")
check(238, "),")
new_a = "                          : _buildPostText(post, textColor),\n"
lines[235:239] = [new_a]

# --- Edit B: children: [ satırından sonra tag filtre barı ekle (satır 192) ---
check(191, "children: [")
lines.insert(192, "              _buildTagFilterBar(),\n")

# --- Edit C: AppBar'a kartvizit butonu ekle (satır 187-190) ---
check(186, "appBar: AppBar(")
check(187, "backgroundColor: bg,")
check(188, "title: h1(widget.channel['name'] ?? 'Channel'),")
check(189, "),")
new_c = '''      appBar: AppBar(
        backgroundColor: bg,
        title: h1(widget.channel['name'] ?? 'Channel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showChannelCard,
          ),
        ],
      ),
'''
lines[186:190] = [new_c]

# --- Edit D: state değişkenleri + helper metodlar (satır 35-43) ---
check(34, "String? _playingPostId;")
check(35, "")
check(36, "bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;")
check(37, "")
check(38, "List<Map<String, dynamic>> get _sortedPosts {")
check(39, "final pinned = _posts.where((p) => p['pinned'] == true).toList();")
check(40, "final rest = _posts.where((p) => p['pinned'] != true).toList();")
check(41, "return [...pinned, ...rest];")
check(42, "}")

new_d = '''  String? _playingPostId;
  String? _activeTag;

  bool get _isOwner => widget.channel['owner_id'] == widget.currentUid;

  List<String> get _allTags {
    final tagSet = <String>{};
    final reg = RegExp(r'#(\\w+)');
    for (final p in _posts) {
      final text = p['content']?.toString() ?? '';
      for (final m in reg.allMatches(


python3 - << 'PYEOF'
path = "pubspec.yaml"
with open(path) as f:
    content = f.read()
marker = "path_provider: ^2.1.4"
assert marker in content, "marker bulunamadı, pubspec değişmiş olabilir"
addition = "\n  qr_flutter: ^4.1.0\n  share_plus: ^10.1.3"
content = content.replace(marker, marker + addition, 1)
with open(path, "w") as f:
    f.write(content)
print("pubspec güncellendi")
