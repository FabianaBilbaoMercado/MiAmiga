import 'package:flutter/material.dart';

class ProfileBtn extends StatelessWidget {

  final Function()? onTap;
  final String text;
  final IconData? icon;

  const ProfileBtn({
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
        
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(248, 181, 149, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(    
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: 36, // Customize the icon size as needed
            ),          
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}