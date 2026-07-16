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

  static Future<List<dynamic>> deleteSelf() async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/auth/delete_self.php'),
        headers: headers,
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Could not delete account'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> forgotPassword(String email) async {
    try {
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/auth/forgot_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, j['message'] ?? 'ok'];
      }
      return [0, j['message'] ?? 'Something went wrong'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/auth/reset_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'new_password': newPassword,
        }),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Could not reset password'];
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
        return "ERR:status_fail:$respStr";
    } catch (e) {
        return "ERR:$e";
    }
  }
}

class ByBugChannel {
  static Future<List<dynamic>> createChannel({
    required String name,
    String description = '',
  }) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_create.php'),
        headers: headers,
        body: jsonEncode({'name': name, 'description': description}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, j['channel']];
      }
      return [0, j['message'] ?? 'Kanal olusturulamadi', j['suggestions'] ?? []];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> updateAvatar({
    required String channelId,
    required String filePath,
  }) async {
    try {
      final uploadResult = await ByBugStorage.uploadFile(filePath);
      if (uploadResult == null || uploadResult.startsWith('ERR:')) {
        return [0, 'Gorsel yuklenemedi'];
      }

      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_update_avatar.php'),
        headers: headers,
        body: jsonEncode({'channel_id': channelId, 'avatar_url': uploadResult}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, j['channel']];
      }
      return [0, j['message'] ?? 'Kanal resmi guncellenemedi'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> deleteChannel(String channelId) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_delete.php'),
        headers: headers,
        body: jsonEncode({'channel_id': channelId}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1];
      }
      return [0, j['message'] ?? 'Kanal silinemedi'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> postToChannel({
    required String channelId,
    required String content,
    String type = 'text',
  }) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_post.php'),
        headers: headers,
        body: jsonEncode({'channel_id': channelId, 'content': content, 'type': type}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, j['post']];
      }
      return [0, j['message'] ?? 'Paylasim yapilamadi'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> getFeed(String channelId, {String afterId = '0'}) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.get(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_feed.php?channel_id=$channelId&after_id=$afterId'),
        headers: headers,
      );
      final decoded = jsonDecode(resp.body);
      if (decoded is! List) return [0, []];
      return [1, decoded];
    } catch (e) {
      return [0, []];
    }

  static Future<List<dynamic>> subscribeToChannel(String channelId) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_subscribe.php'),
        headers: headers,
        body: jsonEncode({'channel_id': channelId}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1];
      }
      return [0, j['message'] ?? 'Katilinamadi'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> unsubscribeFromChannel(String channelId) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_unsubscribe.php'),
        headers: headers,
        body: jsonEncode({'channel_id': channelId}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1];
      }
      return [0, j['message'] ?? 'Ayrilinamadi'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> getChannelMembers(String channelId) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.get(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_members.php?channel_id=$channelId'),
        headers: headers,
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, j['members'] ?? [], j['count'] ?? 0, j['is_subscribed'] == true];
      }
      return [0, [], 0, false];
    } catch (e) {
      return [0, [], 0, false];
    }
  }
  }

  static Future<List<dynamic>> updateChannel({
    required String channelId,
    required String name,
    String description = '',
  }) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_update.php'),
        headers: headers,
        body: jsonEncode({
          'channel_id': channelId,
          'name': name,
          'description': description,
        }),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, j['channel']];
      }
      return [0, j['message'] ?? 'Kanal guncellenemedi'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> addAdmin({
    required String channelId,
    required String targetUid,
  }) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_add_admin.php'),
        headers: headers,
        body: jsonEncode({'channel_id': channelId, 'target_uid': targetUid}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, j['channel']];
      }
      return [0, j['message'] ?? 'Yonetici atanamadi'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> removeAdmin({
    required String channelId,
    required String targetUid,
  }) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.post(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_remove_admin.php'),
        headers: headers,
        body: jsonEncode({'channel_id': channelId, 'target_uid': targetUid}),
      );
      final j = jsonDecode(resp.body);
      if (j['status'] == 1) {
        return [1, j['channel']];
      }
      return [0, j['message'] ?? 'Yonetici kaldirilamadi'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static StreamSubscription<String>? _sseSub;

  static Future<void> streamChannel({
    required String channelId,
    required Function(Map<String, dynamic> post) onPost,
    String afterId = '0',
  }) async {
    await _sseSub?.cancel();
    final token = await ByBugAuth._getToken();
    final client = http.Client();

    Future<void> connect(String lastId) async {
      final uri = Uri.parse(
        '${ByBugDB.apiBaseUrl}/db/channel_stream.php?channel_id=$channelId&after_id=$lastId&token=${token ?? ''}',
      );
      final request = http.Request('GET', uri);
      final response = await client.send(request);

      String currentLastId = lastId;
      _sseSub = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          try {
            final data = jsonDecode(jsonStr);
            if (data is Map && data.containsKey('id')) {
              currentLastId = data['id'].toString();
              onPost(Map<String, dynamic>.from(data));
            }
          } catch (_) {}
        }
      }, onDone: () {
        connect(currentLastId);
      }, onError: (_) {
        Future.delayed(const Duration(seconds: 3), () => connect(currentLastId));
      });
    }

    await connect(afterId);
  }

  static void stopStream() {
    _sseSub?.cancel();
    _sseSub = null;
  }
}

extension ByBugChannelList on ByBugChannel {
  static Future<List<dynamic>> listChannels() async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http.get(
        Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_list.php'),
        headers: headers,
      );
      final decoded = jsonDecode(resp.body);
      if (decoded is! List) return [0, []];
      return [1, decoded];
    } catch (e) {
      return [0, []];
    }
  }
}
