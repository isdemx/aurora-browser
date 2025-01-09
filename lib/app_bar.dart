import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController addressBarController;
  final FocusNode addressFocusNode;
  final bool isFavorite;
  final VoidCallback onBackPressed;
  final VoidCallback onForwardPressed;
  final VoidCallback onRefreshPressed;
  final VoidCallback onHistoryPressed;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onFavoritesLongPress;
  final ValueChanged<String> onUrlSubmitted;
  final Animation<Color?> gradientAnimation;

  const GradientAppBar({
    Key? key,
    required this.addressBarController,
    required this.addressFocusNode,
    required this.isFavorite,
    required this.onBackPressed,
    required this.onForwardPressed,
    required this.onRefreshPressed,
    required this.onHistoryPressed,
    required this.onFavoriteToggle,
    required this.onFavoritesLongPress,
    required this.onUrlSubmitted,
    required this.gradientAnimation,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gradientAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientAnimation.value ?? Colors.blueGrey,
                Colors.black54,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: onBackPressed,
                  tooltip: 'Back',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  onPressed: onForwardPressed,
                  tooltip: 'Forward',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: onRefreshPressed,
                  tooltip: 'Refresh',
                ),
                // Текстовое поле
                Expanded(
                  child: TextField(
                    focusNode: addressFocusNode,
                    controller: addressBarController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: onUrlSubmitted,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter URL',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onFavoriteToggle,
                  onLongPress: onFavoritesLongPress,
                  child: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.yellow : Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.history,
                    color: Colors.white,
                  ),
                  onPressed: onHistoryPressed,
                  tooltip: 'History',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
