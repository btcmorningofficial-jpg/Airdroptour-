// bybugdb paketinin yerine geçen köprü (bridge) katmanı.
// Amaç: ByBugDB / ByBugAuth / ByBugDatabase / ByBugStorage sınıflarını
// AYNI isim ve AYNI kullanım şekliyle burada yeniden yazmak, böylece
// projenin geri kalanında (auth.dart, profile.dart, post.dart vb.)
// hiçbir değişiklik yapmaya gerek kalmıyor - sadece import satırı değişiyor.
//
// Gerçek veri artık kendi PHP + MySQL backend'imizden geliyor.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ByBugDB {
  static String apiBaseUrl = '';
  // Eski kodda (widget/image.dart) ByBugDB.token kullanılıyor,
  // uyumluluk için burada duruyor ama artık kullanılmıyor.
  static String token = '';

  static void initialize({required String url, String authToken = ''}) {
    // Sondaki "/" varsa temizle, tüm istekler bunun üstüne eklenecek.
    apiBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    token = authToken;
  }
}

class ByBugAuth {
  static const _tokenKey = 'bb_auth_token';
  static const _uidKey = 'bb_auth_uid';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveSession(String token, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_uidKey, uid);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final t = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  // Dönüş: [1, "ok"] başarılı, [0, "hata mesajı"] başarısız
  static Future<List<dynamic>> register(
    String email,
    String password, {
    String language = 'tr-Tr',
    required String name,
    Map<String, dynamic>? data,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/auth/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'data': data ?? {},
        }),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        await _saveSession(j['token'], j['uid']);
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Registration failed'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> login(String email, String password) async {
    try {
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        await _saveSession(j['token'], j['uid']);
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Login failed'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> loginWithGoogle(String idToken) async {
    try {
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/auth/google_login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        await _saveSession(j['token'], j['uid']);
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Google login failed'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> deleteUser(String targetUid) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/auth/delete_user.php'),
        headers: headers,
        body: jsonEncode({'uid': targetUid}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Could not delete user'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_uidKey);
    ByBugDatabase.stopAllListeners();
  }

  static Future<bool> isSignedIn() async {
    final t = await _getToken();
    return t != null && t.isNotEmpty;
  }

  static Future<String?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }
}

class ByBugDatabase {
  static final Map<String, Timer> _pollTimers = {};
  static final Map<String, int> _lastIds = {};

  static Future<Map<String, dynamic>> get(String bucket, String tag) async {
    final headers = await ByBugAuth._authHeaders();
    final resp = await http.get(
      Uri.parse(
        '${ByBugDB.apiBaseUrl}/db/get.php?bucket=${Uri.encodeComponent(bucket)}&tag=${Uri.encodeComponent(tag)}',
      ),
      headers: headers,
    );
    final j = jsonDecode(resp.body);
    if (j['status'] != 1) {
      return {'tag': tag, 'value': <String, dynamic>{}};
    }
    return {'tag': j['tag'], 'value': j['value'] ?? {}};
  }

  static Future<List<dynamic>> getAll(String bucket) async {
    final headers = await ByBugAuth._authHeaders();
    final resp = await http.get(
      Uri.parse(
        '${ByBugDB.apiBaseUrl}/db/get_all.php?bucket=${Uri.encodeComponent(bucket)}',
      ),
      headers: headers,
    );
    final decoded = jsonDecode(resp.body);
    if (decoded is! List) return [];
    return decoded;
  }

  static Future<void> add(
    String bucket,
    String tag,
    Map<String, dynamic> value,
  ) async {
    final headers = await ByBugAuth._authHeaders();
    await http.post(
      Uri.parse('${ByBugDB.apiBaseUrl}/db/add.php'),
      headers: headers,
      body: jsonEncode({'bucket': bucket, 'tag': tag, 'value': value}),
    );
  }

  static Future<void> update(
    String bucket,
    String tag,
    Map<String, dynamic> value,
  ) async {
    final headers = await ByBugAuth._authHeaders();
    await http.post(
      Uri.parse('${ByBugDB.apiBaseUrl}/db/update.php'),
      headers: headers,
      body: jsonEncode({'bucket': bucket, 'tag': tag, 'value': value}),
    );
  }

  static Future<void> remove(String bucket, String tag) async {
    final headers = await ByBugAuth._authHeaders();
    await http.post(
      Uri.parse('${ByBugDB.apiBaseUrl}/db/remove.php'),
      headers: headers,
      body: jsonEncode({'bucket': bucket, 'tag': tag}),
    );
  }

  // Gerçek zamanlı (real-time) davranışı taklit etmek için kısa aralıklarla
  // sunucuyu yokluyoruz (polling). Chat mesajları için yeterli.
  static void listenAll(
    String bucket, {
    required Function(String tag, String id, Map<String, dynamic> value)
    onAdd,
  }) {
    _pollTimers[bucket]?.cancel();

    Future<void> initThenPoll() async {
      // Dinlemeye başladığımız andaki en büyük id'yi baz al,
      // eski kayıtları "yeni mesaj" gibi tekrar göndermeyelim.
      if (!_lastIds.containsKey(bucket)) {
        final all = await getAll(bucket);
        int maxId = 0;
        for (final item in all) {
          final id = item['id'];
          if (id is int && id > maxId) maxId = id;
        }
        _lastIds[bucket] = maxId;
      }

      _pollTimers[bucket] = Timer.periodic(const Duration(seconds: 3), (
        timer,
      ) async {
        try {
          final headers = await ByBugAuth._authHeaders();
          final resp = await http.get(
            Uri.parse(
              '${ByBugDB.apiBaseUrl}/db/poll.php?bucket=${Uri.encodeComponent(bucket)}&after_id=${_lastIds[bucket]}',
            ),
            headers: headers,
          );
          final decoded = jsonDecode(resp.body);
          if (decoded is! List) return;
          for (final item in decoded) {
            final id = item['id'];
            if (id is int && id > (_lastIds[bucket] ?? 0)) {
              _lastIds[bucket] = id;
            }
            onAdd(
              item['tag'],
              item['tag'],
              Map<String, dynamic>.from(item['value'] ?? {}),
            );
          }
        } catch (_) {
          // sessizce yut, bir sonraki turda tekrar dener
        }
      });
    }

    initThenPoll();
  }

  static void stopAllListeners() {
    for (final timer in _pollTimers.values) {
      timer.cancel();
    }
    _pollTimers.clear();
    _lastIds.clear();
  }
}

class ByBugStorage {
  static Future<String?> uploadFile(String filePath) async {
    try {
      final token = await ByBugAuth._getToken();
      final uri = Uri.parse('${ByBugDB.apiBaseUrl}/storage/upload.php');
      final request = http.MultipartRequest('POST', uri);
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamed = await request.send();
      final respStr = await streamed.stream.bytesToString();
      final j = jsonDecode(respStr);
      if (j['status'] == 1) return j['url'];
      return null;
    } catch (e) {
      return null;
    }
  }
}
