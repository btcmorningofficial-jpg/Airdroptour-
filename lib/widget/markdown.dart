import 'package:airdrop/theme/color.dart';
import 'package:cosmos/cosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

Widget markdownText(String text) {
  return MarkdownBody(
    data: text,
    selectable: true,
    onTapLink: (text, href, title) async {
      await openUrl(href ?? "https://bybug.com.tr");
    },
    styleSheet: MarkdownStyleSheet(
      listBullet: TextStyle(color: defaultColor, fontSize: 18),
      listIndent: 24.0,
      listBulletPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      p: GoogleFonts.poppins(fontSize: 14, color: textColor),
      h1: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: defaultColor,
      ),
      h2: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      h3: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor.withOpacity(0.8),
      ),
      h4: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor.withOpacity(0.6),
      ),
      h5: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: textColor.withOpacity(0.4),
      ),
      blockquote: GoogleFonts.dmMono(
        fontStyle: FontStyle.italic,
        color: textColor.withOpacity(0.2),
      ),
      codeblockDecoration: BoxDecoration(
        color: textColor.withOpacity(0.02),
        borderRadius: BorderRadius.circular(10),
      ),
      code: GoogleFonts.sourceCodePro(
        fontSize: 12,
        color: textColor.withOpacity(0.7),
        backgroundColor: Colors.transparent,
      ),
      blockquoteDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: textColor.withOpacity(0.2)),
      ),
    ),
  );
}
