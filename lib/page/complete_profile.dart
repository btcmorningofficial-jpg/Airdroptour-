import 'package:airdrop/page/home.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/tools/navigator.dart';
import 'package:airdrop/widget/image.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/snack.dart';
import 'package:airdrop/widget/text.dart';
import 'package:flutter/material.dart';

// Kayıt sonrası zorunlu profil tamamlama ekranı.
// Fotoğraf + cinsiyet + en az 3 kripto seçilmeden geçilemez.
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final ValueNotifier<String> imageController = ValueNotifier("");
  final ValueNotifier<String?> genderController = ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>> availableCryptos =
      ValueNotifier([]);
  final ValueNotifier<List<String>> selectedCryptos = ValueNotifier([]);
  bool loading = false;
  bool loadingCryptos = true;

  @override
  void initState() {
    super.initState();
    _loadCryptos();
  }

  Future<void> _loadCryptos() async {
    var crypto = await ByBugDatabase.getAll("crypto");
    List<Map<String, dynamic>> temp = [];
    for (var element in crypto) {
      Map<String, dynamic> val = Map<String, dynamic>.from(
        element["value"] ?? {},
      );
      if ((val["name"] ?? "").toString().isEmpty) continue;
      temp.add(val);
    }
    if (!mounted) return;
    setState(() {
      availableCryptos.value = temp;
      loadingCryptos = false;
    });
  }

  bool get _hasPhoto => imageController.value.startsWith("http");
  bool get _hasGender => genderController.value != null;
  bool get _hasThreeCoins => selectedCryptos.value.length >= 3;
  bool get canContinue => _hasPhoto && _hasGender && _hasThreeCoins;

  Future<void> _finish() async {
    if (!canContinue) {
      String missing = "";
      if (!_hasPhoto) missing = "profil fotoğrafı";
      if (!_hasGender) {
        missing = missing.isEmpty ? "cinsiyet" : "$missing, cinsiyet";
      }
      if (!_hasThreeCoins) {
        missing = missing.isEmpty ? "en az 3 kripto" : "$missing, en az 3 kripto";
      }
      getErrorSnack(context, "Devam etmek için gerekli: $missing");
      return;
    }

    setState(() => loading = true);

    List cripto = [];
    for (var name in selectedCryptos.value) {
      final match = availableCryptos.value.firstWhere(
        (e) => e["name"] == name,
        orElse: () => {},
      );
      if (match.isEmpty) continue;
      cripto.add({
        "image": match["image"] ?? "",
        "details": match["details"] ?? "",
        "name": match["name"] ?? "",
      });
    }

    await MyProfileData.setProfile(
      photo: imageController.value,
      gender: genderController.value,
      cripto: cripto,
      profileCompleted: true,
    );

    if (!mounted) return;
    push(context, HomePage());
  }

  Widget _genderButton(String value, String label) {
    final selected = genderController.value == value;
    return GestureDetector(
      onTap: () {
        genderController.value = value;
        genderController.notifyListeners();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? defaultColor : navColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: h5(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([
              imageController,
              genderController,
              availableCryptos,
              selectedCryptos,
            ]),
            builder: (context, child) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    h1("Profilini Tamamla"),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: subP(
                        "Devam etmeden önce birkaç bilgiyi tamamlaman gerekiyor.",
                      ),
                    ),
                    SizedBox(height: 24),

                    // Profil fotoğrafı
                    GestureDetector(
                      onTap: () async {
                        String? image = await pickImage();
                        if (image == null) return;
                        String? uploaded = await ByBugStorage.uploadFile(
                          image,
                        );
                        if (uploaded == null) return;
                        imageController.value = uploaded;
                        imageController.notifyListeners();
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: AirdroptourImage(
                          _hasPhoto
                              ? imageController.value
                              : "assets/img/user.png",
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    subP("Profil Fotoğrafı (zorunlu)"),
                    SizedBox(height: 28),

                    // Cinsiyet
                    bold("Cinsiyet"),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _genderButton("male", "Erkek"),
                        SizedBox(width: 12),
                        _genderButton("female", "Kadın"),
                      ],
                    ),
                    SizedBox(height: 28),

                    // Kripto seçimi
                    bold(
                      "En Az 3 Kripto Seç (${selectedCryptos.value.length}/3)",
                    ),
                    SizedBox(height: 12),
                    if (loadingCryptos)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: defaultColor),
                      )
                    else if (availableCryptos.value.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: subP(
                          "Şu anda seçilebilecek kripto varlığı bulunamadı.",
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: availableCryptos.value.map((c) {
                            final name = c["name"] ?? "";
                            final selected = selectedCryptos.value.contains(
                              name,
                            );
                            return GestureDetector(
                              onTap: () {
                                List<String> temp = List<String>.from(
                                  selectedCryptos.value,
                                );
                                if (selected) {
                                  temp.remove(name);
                                } else {
                                  temp.add(name);
                                }
                                selectedCryptos.value = temp;
                                selectedCryptos.notifyListeners();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected ? defaultColor : navColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: h5(name),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(height: 32),

                    GestureDetector(
                      onTap: loading ? null : _finish,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        width: widthSizer(context),
                        decoration: BoxDecoration(
                          color: canContinue ? defaultColor : navColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: h5(loading ? "Kaydediliyor..." : "Devam Et"),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
