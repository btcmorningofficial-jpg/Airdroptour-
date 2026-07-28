import 'dart:io';
import 'package:airdrop/page/loading.dart';
import 'package:airdrop/page/login.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// 🔥 HATALARI TELEFONA KAYDEDEN FONKSİYON
void _hatayiKaydet(String mesaj) {
  try {
    final dosya = File('/storage/emulated/0/Download/airdrop_hata.txt');
    dosya.writeAsStringSync('$mesaj\n', mode: FileMode.append);
  } catch (e) {
    print("HATA KAYDEDİLEMEDİ: $e");
  }
}

void main() async {
  // 🔥 TÜM FLUTTER HATALARINI YAKALA
  FlutterError.onError = (FlutterErrorDetails detay) {
    String msg = "🔥 FLUTTER HATA: ${detay.exception}\nSTACK: ${detay.stack}\n";
    _hatayiKaydet(msg);
    print(msg);
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Release modda da hatayı ekranda göster (beyaz/boş ekran yerine)
    ErrorWidget.builder = (details) => Material(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                details.exceptionAsString(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
        );

    await initializeDateFormatting('en', null);

    ByBugDB.initialize(
      // Kendi sunucumuzdaki PHP + MySQL backend adresi
      url: "https://appairdroptour.yurtdisiisilanlari.com.tr",
      authToken: "",
    );

    bool isSignedIn = false;
    String? startupError;
    try {
      isSignedIn = await ByBugAuth.isSignedIn();
      if (isSignedIn) {
        try {
          await MyProfileData.getMyProfile();
        } catch (e) {
          String msg = "PROFİL YÜKLEME HATASI: $e";
          _hatayiKaydet(msg);
          debugPrint(msg);
          isSignedIn = true;
        }
      }
    } catch (e, s) {
      String msg = "AUTH HATASI: $e\n$s";
      _hatayiKaydet(msg);
      debugPrint(msg);
      await Future.delayed(const Duration(seconds: 2));
      try {
        isSignedIn = await ByBugAuth.isSignedIn();
        if (isSignedIn) {
          try {
            await MyProfileData.getMyProfile();
          } catch (e) {
            String msg2 = "PROFİL YÜKLEME HATASI (retry): $e";
            _hatayiKaydet(msg2);
            debugPrint(msg2);
            isSignedIn = true;
          }
        }
      } catch (e2, s2) {
        String msg2 = "AUTH HATASI (retry): $e2\n$s2";
        _hatayiKaydet(msg2);
        debugPrint(msg2);
        startupError = e2.toString();
        isSignedIn = false;
      }
    }

    runApp(MyApp(isSignedIn: isSignedIn, startupError: startupError));
  }, (error, stack) {
    String msg = "🔥 ZONED HATA: $error\nSTACK: $stack\n";
    _hatayiKaydet(msg);
    debugPrint(msg);
  });
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;
  final String? startupError;
  const MyApp({super.key, required this.isSignedIn, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                        title: const Text('Baslangic Hatasi'),
                        content: SingleChildScrollView(
                          child: Text(startupError!),
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