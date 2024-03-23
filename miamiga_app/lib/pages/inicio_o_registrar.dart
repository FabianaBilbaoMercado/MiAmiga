import 'package:flutter/material.dart';
import 'package:miamiga_app/pages/inicio_sesion.dart';
import 'package:miamiga_app/pages/registro_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  //inicializar mostrar pagina de inicio de sesion
  bool showLoginPage = true;

  //toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage) {
      return IniciarSesion(
        onTap: togglePages,
      );
    } else {
      return RegistroPage(
        onTap: togglePages,
      );
    }
  }
}