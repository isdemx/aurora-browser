import 'package:flutter/material.dart';

class FavoritesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> favorites;
  final ValueChanged<String> onFavoriteTap;

  const FavoritesWidget({
    Key? key,
    required this.favorites,
    required this.onFavoriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return Center(
        child: Text(
          'No favorites added yet.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true, // Чтобы Grid поместился внутри ScrollView
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Две плитки в ряд
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemBuilder: (context, index) {
        final fav = favorites[index];
        final url = fav["url"] as String;
        final colorHex = fav["color"] as String;

        // Парсинг цвета
        final color = Color(int.parse(colorHex.replaceAll('#', ''), radix: 16));

        // Парсим домен (без протокола)
        String domain = Uri.parse(url).host;
        if (domain.isEmpty) domain = url; // fallback

        return GestureDetector(
          onTap: () => onFavoriteTap(url),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              domain,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
