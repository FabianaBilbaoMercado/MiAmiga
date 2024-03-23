import 'package:flutter/material.dart';


class AlertaOficialScreen extends StatefulWidget {
  const AlertaOficialScreen({super.key});

  @override
  State<AlertaOficialScreen> createState() => _AlertaOficialScreenState();
}

class _AlertaOficialScreenState extends State<AlertaOficialScreen> {

  

  

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 15),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          'Su denuncia esta en proceso',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.start,
                        ),
                      ),    
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }