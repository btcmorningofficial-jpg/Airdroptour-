import 'dart:io';
import 'package:airdrop/page/loading.dart';
import 'package:airdrop/page/login.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_links/app_links.dart';

// 🔥 HATALARI TELEFONA KAYDEDEN FONKSİYON
void _hatayiKaydet(String mesaj) {
  try {
    final dosya = File('/storage/emulated/0/Download/airdrop_hata.txt');
    dosya.writeAsStringSync('$mesaj\n', mode: FileMode.append);
  } catch (e) {
    // Sessizce geç
  }
}


final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _handleIncomingLink(Uri uri) async {
  if (uri.host != 'join') return;
  final channelId = uri.queryParameters['c'];
  final inviterUid = uri.queryParameters['u'];
  if (channelId == null || inviterUid == null) return;

  final signedIn = await ByBugAuth.isSignedIn();
  if (!signedIn) return;

  final result = await ByBugChannel.redeemChannelInvite(
    channelId: channelId,
    inviterUid: inviterUid,
  );

  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;

  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(
        result[0] == 1
            ? 'You joined the channel!'
            : (result[1]?.toString() ?? 'Could not join channel'),
      ),
    ),
  );
}
void main() async {
  // 🔥 TÜM FLUTTER HATALARINI YAKALA
  FlutterError.onError = (FlutterErrorDetails detay) {
    String msg = "🔥 FLUTTER HATA: ${detay.exception}\nSTACK: ${detay.stack}\n";
    _hatayiKaydet(msg);
    debugPrint(msg);
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Release modda da hatayı ekranda göster
    ErrorWidget.builder = (details) => Material(
          color: Colors.black,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                details.exceptionAsString(),
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );

    await initializeDateFormatting('en', null);

    // 🔥 API'yi başlat
    ByBugDB.initialize(
      url: "https://appairdroptour.yurtdisiisilanlari.com.tr",
      authToken: "",
    );

  AppLinks().uriLinkStream.listen((uri) {
    _handleIncomingLink(uri);
  });

    bool isSignedIn = false;
    String? startupError;

    try {
      isSignedIn = await ByBugAuth.isSignedIn();
      if (isSignedIn) {
        try {
          await MyProfileData.getMyProfile();
        } catch (e) {
          _hatayiKaydet("PROFİL YÜKLEME HATASI: $e");
          isSignedIn = true;
        }
      }
    } catch (e, s) {
      _hatayiKaydet("AUTH HATASI: $e\n$s");
      await Future.delayed(const Duration(seconds: 2));
      try {
        isSignedIn = await ByBugAuth.isSignedIn();
        if (isSignedIn) {
          try {
            await MyProfileData.getMyProfile();
          } catch (e) {
            _hatayiKaydet("PROFİL YÜKLEME HATASI (retry): $e");
            isSignedIn = true;
          }
        }
      } catch (e2, s2) {
        _hatayiKaydet("AUTH HATASI (retry): $e2\n$s2");
        startupError = e2.toString();
        isSignedIn = false;
      }
    }

    runApp(MyApp(isSignedIn: isSignedIn, startupError: startupError));
  }, (error, stack) {
    _hatayiKaydet("🔥 ZONED HATA: $error\nSTACK: $stack");
    debugPrint("🔥 ZONED HATA: $error");
  });
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;
  final String? startupError;
  const MyApp({super.key, required this.isSignedIn, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Airdroptour',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: defaultColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: navColor,
          foregroundColor: textColor,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor.withOpacity(0.7)),
          bodySmall: TextStyle(color: textColor.withOpacity(0.6)),
          titleLarge: TextStyle(color: textColor),
          titleMedium: TextStyle(color: textColor),
          titleSmall: TextStyle(color: textColor),
          labelLarge: TextStyle(color: textColor),
          labelMedium: TextStyle(color: textColor),
        ),
        dialogBackgroundColor: cColor,
        dialogTheme: DialogThemeData(
          titleTextStyle: TextStyle(color: textColor, fontSize: 20),
          contentTextStyle: TextStyle(color: textColor.withOpacity(0.7)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: defaultColor,
          contentTextStyle: TextStyle(color: textColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: defaultColor,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: isSignedIn
          ? LoadingPage()
          : Builder(
              builder: (context) {
                if (startupError != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: navColor,
                        title: const Text(
                          'Başlangıç Hatası',
                          style: TextStyle(color: Colors.red),
                        ),
                        content: SingleChildScrollView(
                          child: Text(
                            startupError!,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Kapat'),
                          ),
                        ],
                      ),
                    );
                  });
                }
                return LoginPage();
              },
            ),
    );
  }
}