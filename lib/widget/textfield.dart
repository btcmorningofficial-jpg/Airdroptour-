import 'package:airdrop/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Container textfield({
  String? text,
  TextEditingController? textController,
  bool? obscureText,
  bool? readOnly,
  bool? nonMargin,
  List<TextInputFormatter>? inputFormatters,
  void Function()? onEditingComplete,
  void Function(String)? onChanged,
  
  int? maxLines = 1,
  TextInputType? keyboardType,
}) {
  return Container(
    padding: EdgeInsets.all(8),
    margin: nonMargin == true
        ? null
        : EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: navColor,
    ),
    child: TextField(
      readOnly: readOnly ?? false,
      controller: textController,
      inputFormatters: inputFormatters,
      onEditingComplete: onEditingComplete,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      cursorColor: defaultColor,
      style: GoogleFonts.poppins(color: textColor),
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: text,
        labelStyle: GoogleFonts.poppins(color: textColor.withOpacity(0.5)),
        isDense: true,
      ),
    ),
  );
}
