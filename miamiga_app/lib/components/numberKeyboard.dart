import 'package:flutter/material.dart';

class MyNumberKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String text;
  final bool obscureText;
  final bool isEnabled;
  final bool isVisible;

  const MyNumberKeyboard({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.text,
    required this.obscureText,
    required this.isEnabled,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<MyNumberKeyboard> createState() => _MyNumberKeyboardState();
}

class _MyNumberKeyboardState extends State<MyNumberKeyboard> {
  bool isFocused = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                color: isFocused ? Colors.black : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: widget.controller,
                  obscureText: widget.obscureText && !isPasswordVisible,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  enabled: widget.isEnabled,
                  onTap: () {
                    setState(() {
                      isFocused = true;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      isFocused = false;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      isFocused = false;
                    });
                  },
                ),
                if (widget.obscureText)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    child: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}






