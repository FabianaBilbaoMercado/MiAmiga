import 'package:flutter/material.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //image of logo 
          Image(
            image: AssetImage('lib/images/logo.png'),
            height: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Sobre la aplicacion',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Miamiga es la aplicacion que brinda ayuda a las mujeres que sufren con violencia de todo tipo, ya sea fisica, psicologica, sexual, entre otras. Su objetivo es proporcionar un medio seguro para que las mujeres puedan denunciar a sus agresores, brindando asi la ayuda necesaria para salir de estas situaciones dificiles.',
              style: TextStyle(
                fontSize: 20,  
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
