// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/square_tile.dart';
import 'package:miamiga_app/pages/restablecer_contrase%C3%B1a.dart';
import 'package:miamiga_app/services/auth_services.dart';

class IniciarSesion extends StatefulWidget {
  final Function()? onTap;
  const IniciarSesion({
    super.key,
    required this.onTap,
  });

  @override
  State<IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends State<IniciarSesion> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Map<String, String> errorMessages = {
    'invalid-email': 'Correo electrónico y Contraseña inválido',
    'user-not-found': 'Usuario no encontrado',
    'wrong-password': 'Correo electrónico y Contraseña inválido',
  };

  //sign in method
  void signInUser() async {
    //mostrar un carga de inicio
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(255, 87, 110, 1),
          )
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      //manejar el rol del usuario
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final role = await fetchUserRole(user.uid);
        // Navigator.pop(context); //quitar el dialogo de carga

        if (role == 'Supervisor') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/screens_supervisor');
          });
        } else if (role == 'Usuario Normal') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/screens_usuario');
          });
        }
      } else {
        Navigator.pop(context);
        showErrorMsg("Rol invalido");
      }
    } on FirebaseAuthException catch (e) {
      //quitar el dialogo de carga
      Navigator.pop(context);
      //mostar mensaje de error
      showErrorMsg(e.code);
    } catch (e) {
      //quitar el dialogo de carga
      Navigator.pop(context);
      //mostar mensaje de error
      showErrorMsg(e.toString());
    }
  }

  //fetch user role
  Future<String?> fetchUserRole(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .withConverter(
          fromFirestore: (snapshot, _) => snapshot.data()?['role'] ?? '',
          toFirestore: (role, _) => {'role': role},
        )
        .get(GetOptions(source: Source.server));

    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }

  void showErrorMsg(String errorCode) {
    String errorMessage =
        errorMessages[errorCode] ?? 'Porfavor llene los campos';

    final snackBar = SnackBar(
      content: Text(
        errorMessage,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //no se interfiere cuando se hace un hot reload
  bool isFirstRun = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //safearea avoids the notch area
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),

              const Header(
                header: 'Iniciar Sesion',
              ),

              const SizedBox(height: 25),

              //campo usuario

              MyTextField(
                controller: emailController,
                text: 'Correo Electrónico',
                hintText: 'Correo Electrónico',
                obscureText: false,
                isEnabled: true,
                isVisible: true,
              ),

              const SizedBox(height: 10),

              //campo contrasena

              MyTextField(
                controller: passwordController,
                text: 'Contraseña',
                hintText: 'Contraseña',
                obscureText: true,
                isEnabled: true,
                isVisible: true,
              ),

              const SizedBox(height: 10),

              //restablecer contrasena

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return const ResetPassword();
                          }),
                        );
                      },
                      child: const Text(
                        'Olvidaste tu Contraseña',
                        style: TextStyle(
                          color: Color.fromRGBO(108, 91, 124, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //boton de iniciar sesion

              MyImportantBtn(
                text: 'Iniciar Sesion',
                onTap: signInUser,
              ),

              const SizedBox(height: 50),

              //o continuar con

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'O continuar con',
                        style: TextStyle(
                          color: Color.fromRGBO(200, 198, 198, 1),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              //google
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //google button
                  SquareTile(
                      imgPath: 'lib/images/google.png',
                      onTap: () {
                        final authService = AuthService(context: context);
                        authService.signInWithGoogle();
                      }),
                ],
              ),

              const SizedBox(height: 50),

              //aun no tiene cuenta debe registrarse
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Aun no tiene cuenta?',
                    style: TextStyle(
                      color: Color.fromRGBO(200, 198, 198, 1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Registrate',
                      style: TextStyle(
                        color: Color.fromRGBO(108, 91, 124, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
