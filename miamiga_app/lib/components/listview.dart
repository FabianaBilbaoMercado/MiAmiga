import 'package:flutter/material.dart';

class MyListView extends StatelessWidget {

  final List<Widget> items;
  final Function(int)? onItemClick;
  final Color backgroundColor;
  final double borderRadius;
  const MyListView({
    super.key,
    required this.items,
    this.onItemClick,
    this.backgroundColor = const Color.fromRGBO(248, 181, 149, 1),
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
    
        child: SizedBox(
          height: 55,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: items[index],
                onTap: () {
                  onItemClick!(index);
                },
              );
            }
          ),
        ),
      ),
    );
  }
}