import 'package:flutter/material.dart';

class RowButton extends StatelessWidget {

  final Function()? onTap;
  final String text;
  final IconData? icon;

  const RowButton({
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
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        width: 80,
        
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        
        decoration: BoxDecoration(
          color: const Color.fromRGBO(249, 181, 149, 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(    
          children: [
            if (icon != null)
              Icon(
                icon,
                color: Colors.black,
                size: 30, // Customize the icon size as needed
            ),          
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}