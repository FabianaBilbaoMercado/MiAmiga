// ignore_for_file: use_build_context_synchronously, dead_code, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// ignore: unused_import
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/numberKeyboard.dart';
import 'package:miamiga_app/components/phoneKeyboard.dart';
import 'package:miamiga_app/model/datos_usuario_existe.dart';

// ignore: unused_import
import 'package:miamiga_app/pages/map.dart';

class RegistroPage extends StatefulWidget {
  final Function()? onTap;

  const RegistroPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {

  /* List<String> roles = ['Usuario Normal', 'Supervisor', 'Administrador']; */

  double lat = 0.0;
  double long = 0.0;

  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  final fullnameController = TextEditingController();
  final identityController = TextEditingController();
  final phoneController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  void signUserUp() async {
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
    // Check if password is confirmed
    if (passwordController.text != confirmPassController.text) {
      Navigator.pop(context); //cerrar el dialogo en caso de error
      showErrorMsg("Las contraseñas no coinciden");
      return;
    }

    if (areFieldsEmpty()) {
      Navigator.pop(context); //cerrar el dialogo en caso de error
      showErrorMsg("Por favor, complete todos los campos");
      return;
    }

    if (!isEmailValid(emailController.text)) {
      Navigator.pop(context); //cerrar el dialogo en caso de error
      showErrorMsg("Por favor, ingrese un correo valido");
      return;
    }

    if (!isPasswordValid(passwordController.text)) {
  Navigator.pop(context); //cerrar el dialogo en caso de error
  showErrorMsg("La contraseña debe tener al menos 8 caracteres, incluyendo al menos una letra mayúscula, una letra minúscula, un número y un caracter especial como @, #, \$, & o *");
  return;
}

    if (!isFullNameValid(fullnameController.text.trim())) {
      Navigator.pop(context); //cerrar el dialogo en caso de error
      showErrorMsg("Por favor, ingrese un nombre valido");
      return;
    }

    if (!isIdentityValid(identityController.text.trim())) {
      Navigator.pop(context); //cerrar el dialogo en caso de error
      showErrorMsg("Por favor, ingrese un carnet de identidad valido");
      return;
    }

    if (!isPhoneValid(phoneController.text.trim())) {
      Navigator.pop(context); //cerrar el dialogo en caso de error
      showErrorMsg("Por favor, ingrese un numero de telefono valido");
      return;
    }

    final existingUser = await getUserByEmail(emailController.text);
    if (existingUser != null) {
      Navigator.pop(context);
      showErrorMsg("Ya existe una cuenta con este correo electronico");
      return;
    }

    final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res.user != null) {
      //send email verification
      // await res.user!.sendEmailVerification();

      await createUserDocument(
        res.user!,
        fullnameController.text.trim(),
        emailController.text.trim(),
        int.parse(identityController.text.trim()),
        int.parse(phoneController.text.trim()),
        double.parse(latController.text.trim()),
        double.parse(longController.text.trim()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/screens_usuario');
      
    } else {
      Navigator.pop(context); //cerrar el dialogo en caso de error
      showErrorMsg("Error al crear la cuenta. Intente nuevamente.");
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context); //cerrar el dialogo en caso de error
    showErrorMsg(e.message ?? "Error desconocido");
  } catch (e) {
    Navigator.pop(context); //cerrar el dialogo en caso de error
    showErrorMsg("Error inesperado: $e");
  } 
}

bool areFieldsEmpty() {
  return emailController.text.isEmpty ||
      passwordController.text.isEmpty ||
      fullnameController.text.isEmpty ||
      identityController.text.isEmpty ||
      phoneController.text.isEmpty ||
      latController.text.isEmpty ||
      longController.text.isEmpty;
}

  void showErrorMsg(String errorMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMsg,
          style: const TextStyle(
            color: Colors.white,
          )
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  bool isPasswordValid(String password) {
    Pattern upperCasePattern = r'[A-Z]';
    Pattern lowerCasePattern = r'[a-z]';
    Pattern digitCasePattern = r'[0-9]';
    Pattern specialCasePattern = r'[@#$&*]';
    RegExp upperCaseRegex = RegExp(upperCasePattern as String);
    RegExp lowerCaseRegex = RegExp(lowerCasePattern as String);
    RegExp digitCaseRegex = RegExp(digitCasePattern as String);
    RegExp specialCaseRegex = RegExp(specialCasePattern as String);

    return password.length >= 8 &&
        upperCaseRegex.hasMatch(password) &&
        lowerCaseRegex.hasMatch(password) &&
        digitCaseRegex.hasMatch(password) &&
        specialCaseRegex.hasMatch(password);
  }

  bool isFullNameValid(String fullName) {
    final fullNameRegex = RegExp(r"[a-zA-Z]+ [a-zA-Z]+$");
    return fullNameRegex.hasMatch(fullName);
  }

  bool isIdentityValid(String identity) {
    final identityRegex = RegExp(r"[0-9]{7,8}");
    return identityRegex.hasMatch(identity);
  }

  bool isPhoneValid(String phone) {
    final phoneRegex = RegExp(r"[0-9]{7,8}");
    return phoneRegex.hasMatch(phone);
  }

  Future<UserExist?> getUserByEmail(String email) async {
    try {
      final res = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (res.docs.isNotEmpty) {
        final user = res.docs.first;
        return UserExist.fromMap(user.data());
      } else {
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener el usuario por email: $e');
      return null;
    }
  }

  Future<void> createUserDocument(User user, String fullName, String email, int ci, int phone, double lat, double long) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Use the UID as the document ID
          .set({
            'fullname': fullName,
            'email': email,
            'ci': ci,
            'phone': phone,
            'lat': lat,
            'long': long,
            'role': 'Usuario Normal',
          });
    } catch (e) {
      // ignore: avoid_print
      print('Error al crear documento del usuario: $e');
      Navigator.pop(context);
    }
  }

  bool controlgetUserModifiedLocation = false; 

  Future<Map<String, String>> getUserLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String calle = placemark.thoroughfare ?? '';
        final String localidad = placemark.locality ?? '';
        final String pais = placemark.country ?? '';
        
        return {
          'street': calle,
          'locality': localidad,
          'country': pais,
        };
      } else {
        return {
          'street': 'No se pudo obtener la ubicacion',
          'locality': 'No se pudo obtener la ubicacion',
          'country': 'No se pudo obtener la ubicacion',
        };
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener la ubicacion del usuario: $e');
      return {
        'street': 'No se pudo obtener la ubicacion',
        'locality': 'No se pudo obtener la ubicacion',
        'country': 'No se pudo obtener la ubicacion',
      };
    }
  }

  Future<Map<String, String>> getUserModifiedLocation() async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        long,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String calle = placemark.thoroughfare ?? '';
        final String avenida = placemark.subLocality ?? '';
        final String localidad = placemark.locality ?? '';
        final String pais = placemark.country ?? '';

        final String fullStreet = avenida.isNotEmpty
          ? '$calle, $avenida'
          : calle;

        return {
          'street': fullStreet,
          'locality': localidad,
          'country': pais,
        };
      } else {
        return {
          'street': 'No se pudo obtener la ubicacion',
          'locality': 'No se pudo obtener la ubicacion',
          'country': 'No se pudo obtener la ubicacion',
        };
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener la ubicacion modificada: $e');
      return {
        'street': 'No se pudo obtener la ubicacion',
        'locality': 'No se pudo obtener la ubicacion',
        'country': 'No se pudo obtener la ubicacion',
      };
    }
  }

  @override
  void dispose () {
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    fullnameController.dispose();
    identityController.dispose();
    phoneController.dispose();
    latController.dispose();
    longController.dispose();
    super.dispose();
  }

  // String selectedRole = "Usuario Normal";

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
                header: 'Registrate',
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

              //campo confirmar contrasena

              MyTextField(
                controller: confirmPassController,
                text: 'Confirmar Contraseña',
                hintText: 'Confirmar Contraseña',
                obscureText: true,
                isEnabled: true,
                isVisible: true,
              ),
              
              const SizedBox(height: 10),

              //campo nombre completo

              MyTextField(
                controller: fullnameController,
                text: 'Nombre Completo',
                hintText: 'Nombre Completo',
                obscureText: false,
                isEnabled: true,
                isVisible: true,
              ),
              
              const SizedBox(height: 10),

              //campo CI

              MyNumberKeyboard(
                controller: identityController,
                text: 'Carnet de Identidad',
                hintText: 'Carnet de Identidad',
                obscureText: false,
                isEnabled: true,
                isVisible: true,
              ),
              
              const SizedBox(height: 10),

              //campo Numero de Telefono

              MyPhoneKeyboard(
                controller: phoneController,
                text: 'Telefono',
                hintText: 'Telefono',
                obscureText: false,
                isEnabled: true,
                isVisible: true,
              ),

              const SizedBox(height: 10),              
              FutureBuilder<Map<String, String>>(
                future: getUserModifiedLocation(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text ('Error: ${snapshot.error}');
                  } else {
                    final locationData = snapshot.data!;
                    final calle = locationData['street'];
                    final localidad = locationData['locality'];
                    final pais = locationData['country'];
                    return Column(
                      children: [
                        /*hidden lat and long*/
                        const SizedBox(height: 10),
                        MyTextField(
                          controller: latController,
                          text: 'Latitud', 
                          hintText: 'Latitud',
                          obscureText: false,
                          isEnabled: false,
                          isVisible: false,
                        ),
                        const SizedBox(height: 10),
                        MyTextField(
                          controller: longController,
                          text: 'Longitud',
                          hintText: 'Longitud',
                          obscureText: false,
                          isEnabled: false,
                          isVisible: false,
                        ),
                        /*hidden lat and long*/
                        const SizedBox(height: 10),
                        Text('Calle: $calle'),
                        Text('Localidad: $localidad'),
                        Text('Pais: $pais'),
                        /* Text('Ubicacion modificado: ${latController.text}, ${longController.text}') */
                      ],
                    );
                  }
                }
              ),

              const SizedBox(height: 10),
              //seleccionar ubicacion

              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(248, 181, 149, 1)),
                ),
                onPressed: () async {
                  final selectedLocation = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const CurrentLocationScreen();
                      },
                    ),
                  );
                  if (selectedLocation != null && selectedLocation is Map<String, double>) {
                    setState(() {
                      lat = selectedLocation['latitude']!;
                      long = selectedLocation['longitude']!;
                    });
                    final locationData = await getUserModifiedLocation();
                    final calle = locationData['street'];
                    final localidad = locationData['locality'];
                    final pais = locationData['country'];
                    latController.text = lat.toString();
                    longController.text = long.toString();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          children: [
                            Text('Calle: $calle'),
                            Text('Localidad: $localidad'),
                            Text('Pais: $pais'),
                          ]
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }, 
                child: const Text('Seleccionar Ubicacion'),
              ),
              

              const SizedBox(height: 25),       

              //boton de iniciar sesion

              MyImportantBtn(
                text: 'Registrate',
                onTap: signUserUp,
              ),
              
              const SizedBox(height: 25),       

              //ya tiene cuenta puede ir al iniciar sesion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ya tiene cuenta?',
                    style: TextStyle(
                      color: Color.fromRGBO(200, 198, 198, 1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Iniciar Sesion',
                      style: TextStyle(
                        color: Color.fromRGBO(108, 91, 124, 1), 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),  
            ],
          ),
        ),
      ),
    );
  }
}