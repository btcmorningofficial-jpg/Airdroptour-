import 'package:airdrop/services/admin.dart';
import 'package:airdrop/widget/image.dart';
import 'package:flutter/material.dart';

// Match kartlarında (kaydırmalı eşleşme ekranı) kullanıcının favori
// kripto paralarını göstermek için kompakt, renkli ve hafif "glow"
// efektli bir rozet (chip). CryptoWidget tam boy bir kart olduğu için
// burada onun yerine bu hafif versiyon kullanılıyor - taşma olmuyor.
// Tıklanınca CryptoWidget ile aynı detay penceresi açılır.
class MatchCryptoChip extends StatelessWidget {
  final String photo;
  final String name;
  final String details;
  const MatchCryptoChip({
    super.key,
    required this.photo,
    required this.name,
    this.details = "",
  });

  // İsme göre sabit ama farklı bir renk üretir, her coin kendine
  // özgü bir tonda görünsün diye.
  Color _accentColor() {
    const colors = [
      Color(0xFFF7931A), // bitcoin turuncu
      Color(0xFF627EEA), // ethereum mor-mavi
      Color(0xFF26A17B), // yeşil
      Color(0xFFF3BA2F), // sarı
      Color(0xFFE84142), // kırmızı
      Color(0xFF8247E5), // mor
      Color(0xFF2775CA), // mavi
    ];
    final idx = name.codeUnits.fold<int>(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = _accentColor();
    return GestureDetector(
      onTap: () {
        CryptoWidget.showDetailDialog(
          context,
          photo: photo,
          name: name,
          details: details,
        );
      },
      child: Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.55),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: AirdroptourImage(
                photo,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      ),
    );
  }
}
