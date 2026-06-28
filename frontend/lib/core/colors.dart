import 'package:flutter/material.dart';

/// Palette mirrored from the HTML preview.
class AppColors {
  // brand
  static const primary = Color(0xFF0E7C66);
  static const primaryInk = Color(0xFF0A5C4C);
  static const primarySoft = Color(0xFFD8F0E8);
  // borrow (violet) — money you owe
  static const borrow = Color(0xFF7C3AED);
  static const borrowInk = Color(0xFF5B23B8);
  static const borrowSoft = Color(0xFFEBE3FB);
  // status
  static const paid = Color(0xFF10B981);
  static const paidSoft = Color(0xFFD6F4E6);
  static const due = Color(0xFFE08A00);
  static const dueSoft = Color(0xFFFCEFD2);
  static const over = Color(0xFFE1483B);
  static const overSoft = Color(0xFFFBDEDB);
  static const indigo = Color(0xFF5B61E6);

  // light surfaces
  static const bgLight = Color(0xFFEFF2F7);
  static const surfaceLight = Color(0xFFF6F8FB);
  static const cardLight = Color(0xFFFFFFFF);
  static const inkLight = Color(0xFF0E1726);
  static const mutedLight = Color(0xFF647184);
  static const lineLight = Color(0xFFE7ECF2);

  // dark surfaces
  static const bgDark = Color(0xFF05080C);
  static const surfaceDark = Color(0xFF0B1117);
  static const cardDark = Color(0xFF141B24);
  static const inkDark = Color(0xFFE8EDF4);
  static const mutedDark = Color(0xFF8C99AB);
  static const lineDark = Color(0xFF232D3A);
}

bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color cardColor(BuildContext c) => _isDark(c) ? AppColors.cardDark : AppColors.cardLight;
Color mutedColor(BuildContext c) => _isDark(c) ? AppColors.mutedDark : AppColors.mutedLight;
Color lineColor(BuildContext c) => _isDark(c) ? AppColors.lineDark : AppColors.lineLight;

// Deterministic avatar color from an id/string.
const _avatarPalette = [
  Color(0xFF0E7C66), Color(0xFF5B61E6), Color(0xFFE08A00), Color(0xFFE1483B),
  Color(0xFF0EA5A0), Color(0xFF9333EA), Color(0xFF0284C7), Color(0xFFDB2777),
];
Color avatarColor(String id) {
  var h = 0;
  for (final c in id.codeUnits) {
    h = (h + c) % _avatarPalette.length;
  }
  return _avatarPalette[h];
}
