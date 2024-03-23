import 'package:flutter/material.dart';

class ImportantButton extends StatelessWidget {

  final Function()? onTap;
  final String text;
  final IconData? icon;

  const ImportantButton({
    super.key,
    required this.onTap,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(214, 52, 71, 1),
          borderRadius: BorderRadius.circular(200),
        ),
        child: Column(    
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: 100, // Customize the icon size as needed
            ),          
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}