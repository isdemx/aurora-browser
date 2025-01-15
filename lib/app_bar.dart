import 'package:flutter/material.dart';

class GradientAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  _GradientAppBarState createState() => _GradientAppBarState();
}

class _GradientAppBarState extends State<GradientAppBar> {
  bool _hasFocused = false;

  @override
  void initState() {
    super.initState();
    widget.addressFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.addressFocusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (widget.addressFocusNode.hasFocus && !_hasFocused) {
      // Выделяем весь текст только при первом фокусе
      widget.addressBarController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.addressBarController.text.length,
      );
      setState(() {
        _hasFocused = true;
      });
    } else if (!widget.addressFocusNode.hasFocus) {
      // Сбрасываем состояние при потере фокуса
      setState(() {
        _hasFocused = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.gradientAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.gradientAnimation.value ?? Colors.blueGrey,
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
                  onPressed: widget.onBackPressed,
                  tooltip: 'Back',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  onPressed: widget.onForwardPressed,
                  tooltip: 'Forward',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: widget.onRefreshPressed,
                  tooltip: 'Refresh',
                ),
                // Текстовое поле
                Expanded(
                  child: TextField(
                    focusNode: widget.addressFocusNode,
                    controller: widget.addressBarController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go,
                    onSubmitted: widget.onUrlSubmitted,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter URL or search prompt',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onFavoriteToggle,
                  onLongPress: widget.onFavoritesLongPress,
                  child: Icon(
                    widget.isFavorite ? Icons.star : Icons.star_border,
                    color: widget.isFavorite ? Colors.yellow : Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.history,
                    color: Colors.white,
                  ),
                  onPressed: widget.onHistoryPressed,
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
