import 'dart:math';
import 'package:flutter/material.dart';

/// Пример генерации пастельного цвета
Color generateRandomPastelColor() {
  final Random rnd = Random();
  // пастель = берем рандом в диапазоне 150..255 (примерно)
  int r = 150 + rnd.nextInt(106);
  int g = 150 + rnd.nextInt(106);
  int b = 150 + rnd.nextInt(106);
  return Color.fromARGB(255, r, g, b);
}

String colorToHex(Color c) {
  return '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}

bool isUrl(String text) {
  return text.contains('.') && !text.contains(' ');
}

String buildSearchQuery(String query) {
  final encodedQuery = Uri.encodeComponent(query);
  return 'https://www.google.com/search?q=$encodedQuery';
}
