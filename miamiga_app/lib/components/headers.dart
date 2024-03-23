import 'package:flutter/material.dart';

class Header extends StatelessWidget {

  final String header;
  const Header({
    Key? key,
    required this.header,
  }) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              header,
              style: const TextStyle(
                color: Color.fromRGBO(209, 90, 124, 1),
                fontSize: 24,
              ),
            ),
            Container(
              width: 65,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(209, 90, 124, 1),
                  width: 2.0, // Adjust the width of the line
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}