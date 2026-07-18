import 'package:airdrop/page/loading.dart';
import 'package:airdrop/page/login.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) => Material(color: Colors.white, child: Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(details.exceptionAsString(), style: const TextStyle(color: Colors.red, fontSize: 12)))));
  await initializeDateFormatting('en', null);
  ByBugDB.initialize(
    // Kendi sunucumuzdaki PHP + MySQL backend adresi
    url: "https://appairdroptour.yurtdisiisilanlari.com.tr",
    authToken: "",
  );
  final bool isSignedIn = await ByBugAuth.isSignedIn();
  if (isSignedIn) {
    await MyProfileData.getMyProfile();
  }
  runZonedGuarded(() {
    runApp(MyApp(isSignedIn: isSignedIn));
  }, (error, stack) {
    debugPrint('CAUGHT ERROR: $error');
  });
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;
  const MyApp({super.key, required this.isSignedIn});

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
      home: isSignedIn ? LoadingPage() : LoginPage(),
    );
  }
}
