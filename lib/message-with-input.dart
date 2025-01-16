import 'package:flutter/material.dart';

class MessageWithInput extends StatelessWidget {
  final String message;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onGoPressed;
  final ValueChanged<String>? onSubmitted;
  final Color backgroundColor;
  final double borderRadius;
  final Color textColor;

  const MessageWithInput({
    Key? key,
    required this.message,
    required this.hintText,
    required this.controller,
    required this.onGoPressed,
    this.onSubmitted,
    this.backgroundColor = const Color.fromARGB(77, 0, 0, 0), // default black with opacity
    this.borderRadius = 12.0,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.go,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: textColor.withOpacity(0.54)),
                  filled: true,
                  fillColor: textColor.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.arrow_forward, color: textColor),
                    onPressed: onGoPressed,
                  ),
                ),
                onSubmitted: onSubmitted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
