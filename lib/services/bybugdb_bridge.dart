// bybugdb paketinin yerine geçen köprü (bridge) katmanı.
// Amaç: ByBugDB / ByBugAuth / ByBugDatabase / ByBugStorage sınıflarını
// AYNI isim ve AYNI kullanım şekliyle burada yeniden yazmak, böylece
// projenin geri kalanında (auth.dart, profile.dart, post.dart vb.)
// hiçbir değişiklik yapmaya gerek kalmıyor - sadece import satırı değişiyor.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Duration _kDefaultTimeout = Duration(seconds: 15);
const Duration _kPollInterval = Duration(seconds: 3);
const Duration _kMaxBackoff = Duration(seconds: 60);

dynamic _safeDecode(http.Response resp) {
  if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
  if (resp.body.isEmpty) return null;
  try {
    return jsonDecode(resp.body);
  } catch (_) {
    return null;
  }
}

class ByBugDB {
  static String apiBaseUrl = '';
  static String token = '';

  static void initialize({required String url, String authToken = ''}) {
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
      if (t != null && t.isNotEmpty) 'Authorization': 'Bearer $t',
    };
  }

  static Future<List<dynamic>> register(
    String email,
    String password, {
    String language = 'tr-Tr',
    required String name,
    Map<String, dynamic>? data,
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/auth/register.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'name': name,
              'data': data ?? {},
            }),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) {
        await _saveSession(j['token'], j['uid']);
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Registration failed'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> login(String email, String password) async {
    try {
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/auth/login.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) {
        await _saveSession(j['token'], j['uid']);
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Login failed'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> loginWithGoogle(String idToken) async {
    try {
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/auth/google_login.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) {
        await _saveSession(j['token'], j['uid']);
        return [1, 'ok'];
      }
      return [0, j['message'] ?? 'Google login failed'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> deleteUser(String targetUid) async {
    try {
      final headers = await _authHeaders();
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/auth/delete_user.php'),
            headers: headers,
            body: jsonEncode({'uid': targetUid}),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, 'ok'];
      return [0, j['message'] ?? 'Could not delete user'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> deleteSelf() async {
    try {
      final headers = await _authHeaders();
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/auth/delete_self.php'),
            headers: headers,
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, 'ok'];
      return [0, j['message'] ?? 'Could not delete account'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<List<dynamic>> forgotPassword(String email) async {
    try {
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/auth/forgot_password.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, j['message'] ?? 'ok'];
      return [0, j['message'] ?? 'Something went wrong'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
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
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/auth/reset_password.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'code': code,
              'new_password': newPassword,
            }),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, 'ok'];
      return [0, j['message'] ?? 'Could not reset password'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Could not connect to server'];
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_uidKey);
    ByBugDatabase.stopAllListeners();
    ByBugChannel.stopStream();
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
  static final Map<String, int> _failCounts = {};

  static Future<Map<String, dynamic>> get(String bucket, String tag) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .get(
            Uri.parse(
              '${ByBugDB.apiBaseUrl}/db/get.php?bucket=${Uri.encodeComponent(bucket)}&tag=${Uri.encodeComponent(tag)}',
            ),
            headers: headers,
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null || j['status'] != 1) {
        return {'tag': tag, 'value': <String, dynamic>{}};
      }
      return {'tag': j['tag'], 'value': j['value'] ?? {}};
    } catch (_) {
      return {'tag': tag, 'value': <String, dynamic>{}};
    }
  }

  static Future<List<dynamic>> getFiltered(
    String bucket,
    String field,
    String value, {
    int limit = 200,
  }) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .get(
            Uri.parse(
              '${ByBugDB.apiBaseUrl}/db/get_filtered.php?bucket=${Uri.encodeComponent(bucket)}&field=$field&value=${Uri.encodeComponent(value)}&limit=$limit',
            ),
            headers: headers,
          )
          .timeout(_kDefaultTimeout);
      final decoded = _safeDecode(resp);
      if (decoded is! List) return [];
      return decoded;
    } catch (_) {
      return [];
    }
  }

  static Future<List<dynamic>> getAll(String bucket) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .get(
            Uri.parse(
              '${ByBugDB.apiBaseUrl}/db/get_all.php?bucket=${Uri.encodeComponent(bucket)}',
            ),
            headers: headers,
          )
          .timeout(_kDefaultTimeout);
      final decoded = _safeDecode(resp);
      if (decoded is! List) return [];
      return decoded;
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(
    String bucket,
    String tag,
    Map<String, dynamic> value,
  ) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/add.php'),
            headers: headers,
            body: jsonEncode({'bucket': bucket, 'tag': tag, 'value': value}),
          )
          .timeout(_kDefaultTimeout);
    } catch (_) {}
  }

  static Future<void> update(
    String bucket,
    String tag,
    Map<String, dynamic> value,
  ) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/update.php'),
            headers: headers,
            body: jsonEncode({'bucket': bucket, 'tag': tag, 'value': value}),
          )
          .timeout(_kDefaultTimeout);
    } catch (_) {}
  }

  static Future<void> remove(String bucket, String tag) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/remove.php'),
            headers: headers,
            body: jsonEncode({'bucket': bucket, 'tag': tag}),
          )
          .timeout(_kDefaultTimeout);
    } catch (_) {}
  }

  static void listenAll(
    String bucket, {
    String? pollKey,
    required Function(String tag, String id, Map<String, dynamic> value)
        onAdd,
  }) {
    final key = pollKey ?? bucket;
    _pollTimers[key]?.cancel();
    _failCounts[key] = 0;

    void scheduleNext(Future<void> Function() tick) {
      final fails = _failCounts[key] ?? 0;
      final backoffSeconds =
          (_kPollInterval.inSeconds * (1 << fails.clamp(0, 6)))
              .clamp(_kPollInterval.inSeconds, _kMaxBackoff.inSeconds);
      _pollTimers[key] = Timer(Duration(seconds: backoffSeconds), () async {
        await tick();
      });
    }

    Future<void> poll() async {
      try {
        final headers = await ByBugAuth._authHeaders();
        final resp = await http
            .get(
              Uri.parse(
                '${ByBugDB.apiBaseUrl}/db/poll.php?bucket=${Uri.encodeComponent(bucket)}&after_id=${_lastIds[key]}',
              ),
              headers: headers,
            )
            .timeout(_kDefaultTimeout);
        final decoded = _safeDecode(resp);
        if (decoded == null) {
          _failCounts[key] = (_failCounts[key] ?? 0) + 1;
        } else {
          _failCounts[key] = 0;
          if (decoded is List) {
            for (final item in decoded) {
              final id = item['id'];
              if (id is int && id > (_lastIds[key] ?? 0)) {
                _lastIds[key] = id;
              }
              onAdd(
                item['tag'],
                item['tag'],
                Map<String, dynamic>.from(item['value'] ?? {}),
              );
            }
          }
        }
      } catch (_) {
        _failCounts[key] = (_failCounts[key] ?? 0) + 1;
      }
      if (_pollTimers.containsKey(key)) {
        scheduleNext(poll);
      }
    }

    Future<void> initThenPoll() async {
      if (!_lastIds.containsKey(key)) {
        final all = await getAll(bucket);
        int maxId = 0;
        for (final item in all) {
          final id = item['id'];
          if (id is int && id > maxId) maxId = id;
        }
        _lastIds[key] = maxId;
      }
      _pollTimers[key] = Timer(Duration.zero, () async {
        await poll();
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
    _failCounts.clear();
  }
}

class ByBugStorage {
  static Future<String?> uploadFile(String filePath) async {
    try {
      final token = await ByBugAuth._getToken();
      final uri = Uri.parse('${ByBugDB.apiBaseUrl}/storage/upload.php');
      final request = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final respStr = await streamed.stream.bytesToString();
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        return 'ERR:http_${streamed.statusCode}';
      }
      Map<String, dynamic> j;
      try {
        j = jsonDecode(respStr);
      } catch (_) {
        return 'ERR:invalid_response';
      }
      if (j['status'] == 1) return j['url'];
      return 'ERR:status_fail:$respStr';
    } on TimeoutException {
      return 'ERR:timeout';
    } catch (e) {
      return 'ERR:$e';
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
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_create.php'),
            headers: headers,
            body: jsonEncode({'name': name, 'description': description}),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı', []];
      if (j['status'] == 1) return [1, j['channel']];
      return [
        0,
        j['message'] ?? 'Kanal olusturulamadi',
        j['suggestions'] ?? [],
      ];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> listChannels() async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .get(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_list.php'),
            headers: headers,
          )
          .timeout(_kDefaultTimeout);
      final decoded = jsonDecode(resp.body);
      if (decoded is! List) {
        return [0, 'Sunucudan gecersiz yanit alindi'];
      }
      return [1, decoded];
    } on TimeoutException {
      return [0, 'Sunucu yanit vermedi (zaman asimi)'];
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
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_update_avatar.php'),
            headers: headers,
            body: jsonEncode({
              'channel_id': channelId,
              'avatar_url': uploadResult,
            }),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, j['channel']];
      return [0, j['message'] ?? 'Failed to update channel photo'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> deleteChannel(String channelId) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_delete.php'),
            headers: headers,
            body: jsonEncode({'channel_id': channelId}),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1];
      return [0, j['message'] ?? 'Kanal silinemedi'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
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
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_post.php'),
            headers: headers,
            body: jsonEncode({
              'channel_id': channelId,
              'content': content,
              'type': type,
            }),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, j['post']];
      return [0, j['message'] ?? 'Paylasim yapilamadi'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> getFeed(
    String channelId, {
    String afterId = '0',
  }) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .get(
            Uri.parse(
              '${ByBugDB.apiBaseUrl}/db/channel_feed.php?channel_id=$channelId&after_id=$afterId',
            ),
            headers: headers,
          )
          .timeout(_kDefaultTimeout);
      final decoded = _safeDecode(resp);
      if (decoded is! List) return [0, []];
      return [1, decoded];
    } catch (_) {
      return [0, []];
    }
  }

  static Future<List<dynamic>> subscribeToChannel(String channelId) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_subscribe.php'),
            headers: headers,
            body: jsonEncode({'channel_id': channelId}),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1];
      return [0, j['message'] ?? 'Katilinamadi'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> unsubscribeFromChannel(String channelId) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_unsubscribe.php'),
            headers: headers,
            body: jsonEncode({'channel_id': channelId}),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1];
      return [0, j['message'] ?? 'Ayrilinamadi'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Future<List<dynamic>> getChannelMembers(String channelId) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .get(
            Uri.parse(
              '${ByBugDB.apiBaseUrl}/db/channel_members.php?channel_id=$channelId',
            ),
            headers: headers,
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, [], 0, false];
      if (j['status'] == 1) {
        return [
          1,
          j['members'] ?? [],
          j['count'] ?? 0,
          j['is_subscribed'] == true,
        ];
      }
      return [0, [], 0, false];
    } catch (_) {
      return [0, [], 0, false];
    }
  }

  static Future<List<dynamic>> updateChannel({
    required String channelId,
    required String name,
    String description = '',
  }) async {
    try {
      final headers = await ByBugAuth._authHeaders();
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_update.php'),
            headers: headers,
            body: jsonEncode({
              'channel_id': channelId,
              'name': name,
              'description': description,
            }),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, j['channel']];
      return [0, j['message'] ?? 'Failed to update channel'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
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
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_add_admin.php'),
            headers: headers,
            body: jsonEncode({
              'channel_id': channelId,
              'target_uid': targetUid,
            }),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, j['channel']];
      return [0, j['message'] ?? 'Failed to assign admin'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
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
      final resp = await http
          .post(
            Uri.parse('${ByBugDB.apiBaseUrl}/db/channel_remove_admin.php'),
            headers: headers,
            body: jsonEncode({
              'channel_id': channelId,
              'target_uid': targetUid,
            }),
          )
          .timeout(_kDefaultTimeout);
      final j = _safeDecode(resp);
      if (j == null) return [0, 'Sunucudan geçersiz yanıt alındı'];
      if (j['status'] == 1) return [1, j['channel']];
      return [0, j['message'] ?? 'Failed to remove admin'];
    } on TimeoutException {
      return [0, 'Sunucu yanıt vermedi (zaman aşımı)'];
    } catch (e) {
      return [0, 'Sunucuya baglanilamadi'];
    }
  }

  static Timer? _pollTimer;
  static String _lastPolledId = '0';
  static int _streamFailCount = 0;

  static Future<void> streamChannel({
    required String channelId,
    required Function(Map<String, dynamic> post) onPost,
    String afterId = '0',
  }) async {
    _pollTimer?.cancel();
    _lastPolledId = afterId;
    _streamFailCount = 0;

    Future<void> tick() async {
      try {
        final headers = await ByBugAuth._authHeaders();
        final resp = await http
            .get(
              Uri.parse(
                '${ByBugDB.apiBaseUrl}/db/channel_feed.php?channel_id=$channelId&after_id=$_lastPolledId',
              ),
              headers: headers,
            )
            .timeout(_kDefaultTimeout);
        final decoded = _safeDecode(resp);
        if (decoded == null) {
          _streamFailCount++;
        } else {
          _streamFailCount = 0;
          if (decoded is List) {
            for (final item in decoded) {
              if (item is Map && item.containsKey('id')) {
                _lastPolledId = item['id'].toString();
                onPost(Map<String, dynamic>.from(item));
              }
            }
          }
        }
      } catch (_) {
        _streamFailCount++;
      }
      if (_pollTimer != null) {
        final backoffSeconds =
            (_kPollInterval.inSeconds * (1 << _streamFailCount.clamp(0, 6)))
                .clamp(_kPollInterval.inSeconds, _kMaxBackoff.inSeconds);
        _pollTimer = Timer(Duration(seconds: backoffSeconds), tick);
      }
    }

    _pollTimer = Timer(Duration.zero, tick);
  }

  static void stopStream() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _lastPolledId = '0';
    _streamFailCount = 0;
  }
}