import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/color.dart';

Widget h1(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
  );
}

Widget h2(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 25,
    ),
  );
}

Widget h3(
  String text, {
  int? maxLines,
  TextOverflow? overflow,
  double? size,
  Color? color,
  TextAlign? textAlign,
  FontWeight? fontWeight,
}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    style: GoogleFonts.poppins(
      height: 0.98,
      color: color ?? textColor,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: size ?? 20,
    ),
  );
}

Widget h4(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  );
}

Widget h5(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );
}

Widget p(
  String text, {
  int? maxLines,
  Color? color,
  TextOverflow? overflow,
  TextAlign? textAlign,
  double? size,
}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    style: GoogleFonts.poppins(color: color ?? textColor, fontSize: size ?? 14),
  );
}

Widget subP(
  String text, {
  int? maxLines,
  Color? color,
  TextOverflow? overflow,
  double? size,
  TextAlign? textAlign,
  FontWeight? fontWeight,
}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    style: GoogleFonts.poppins(
      color: color ?? textColor,
      fontSize: size ?? 12,
      fontWeight: fontWeight,
    ),
  );
}

Widget subPName(
  String text, {
  int? maxLines,
  Color? color,
  TextOverflow? overflow,
  double? size,
  TextAlign? textAlign,
  FontWeight? fontWeight,
}) {
  return Text(
    text.length > 8 ? text.substring(0, 8) : text,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    style: GoogleFonts.poppins(
      color: color ?? textColor,
      fontSize: size ?? 12,
      fontWeight: fontWeight,
    ),
  );
}

Widget bold(
  String text, {
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
  double? size,
  Color? color,
}) {
  return Text(
    text,
    overflow: overflow,
    textAlign: textAlign,
    maxLines: maxLines,
    style: GoogleFonts.poppins(
      color: color ?? textColor,
      fontWeight: FontWeight.bold,
      fontSize: size ?? 14,
    ),
  );
}

Widget italic(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: textColor,
      fontStyle: FontStyle.italic,
      fontSize: 14,
    ),
  );
}

Widget h1Dark(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: bg,
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
  );
}

Widget h2Dark(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: bg,
      fontWeight: FontWeight.bold,
      fontSize: 25,
    ),
  );
}

Widget h3Dark(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: bg,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  );
}

Widget h4Dark(
  String text, {
  int? maxLines,
  TextOverflow? overflow,
  Color? color,
}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    style: GoogleFonts.poppins(
      color: color ?? bg,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  );
}

Widget h5Dark(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: bg,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );
}

Widget pDark(
  String text, {
  int? maxLines,
  TextOverflow? overflow,
  double? size,
}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    style: GoogleFonts.poppins(color: bg, fontSize: size ?? 14),
  );
}

Widget subPDark(String text) {
  return Text(text, style: GoogleFonts.poppins(color: bg, fontSize: 12));
}

Widget boldDark(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: bg,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  );
}

Widget italicDark(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: bg,
      fontStyle: FontStyle.italic,
      fontSize: 14,
    ),
  );
}
