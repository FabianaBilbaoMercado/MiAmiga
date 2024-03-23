// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/numberKeyboard.dart';
import 'package:miamiga_app/components/phoneKeyboard.dart';
import 'package:miamiga_app/pages/map.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  final identityController = TextEditingController();
  final phoneController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  Future<void> checkUserProfile(User user) async {
  final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  if (userDoc.exists) {
    final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    // Check if all profile fields are filled
    if (userData['fullname'] != null && userData['email'] != null && userData['ci'] != null && userData['phone'] != null && userData['lat'] != null && userData['long'] != null) {
      // Profile is complete, navigate to main screen
      Navigator.of(context).pushReplacementNamed('/screens_usuario');
    } else {
      // Profile is not complete, navigate to profile completion screen
      Navigator.of(context).pushReplacementNamed('/completar_perfil');
    }
  }
}

  void completeGoogleUserProfile(User user) async {

    await checkUserProfile(user);

    showDialog(
      context: context, 
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(255, 87, 110, 1),
          ),
        );
      }
    );

    try {
      if (areFieldsEmpty()) {
        Navigator.pop(context);
        showErrorMsg('Por favor, completa todos los campos');
        return;
      }

      await createUserGoogleDocument(
        user, 
        int.parse(identityController.text), 
        int.parse(phoneController.text), 
        double.parse(latController.text), 
        double.parse(longController.text)
      );
      Navigator.pop(context);
      Navigator.of(context).pushReplacementNamed('/screens_usuario');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil completado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      showErrorMsg('Error al completar el perfil: $e');
    }
  }

  bool areFieldsEmpty() {
  return identityController.text.isEmpty ||
      phoneController.text.isEmpty;
  }

  void showErrorMsg(String errorMsg) {
    if (mounted) {
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
  }

  Future<void> createUserGoogleDocument(User user, int ci, int phone, double lat, double long) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullname': user.displayName,
        'email': user.email,
        'ci': ci,
        'phone': phone,
        'lat': lat,
        'long': long,
        'role': 'Usuario Normal',
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error al crear el documento de usuario: $e');
    }
  }

  double lat = 0.0;
  double long = 0.0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),

              const Header(
                header: 'Completar Perfil',
              ),

              const SizedBox(height: 25),

              MyNumberKeyboard(
                controller: identityController, 
                hintText: 'Carnet de Identidad', 
                text: 'Carnet de Identidad', 
                obscureText: false, 
                isEnabled: true, 
                isVisible: true
              ),

              const SizedBox(height: 10),

              MyPhoneKeyboard(
                controller: phoneController, 
                hintText: 'Telefono', 
                text: 'Telefono', 
                obscureText: false, 
                isEnabled: true, 
                isVisible: true
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

              MyImportantBtn(
                text: 'Completar Perfil',
                onTap: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    completeGoogleUserProfile(user);
                  } else {
                    showErrorMsg('Error al completar el perfil');
                  }
                },
              ),

              const SizedBox(height: 30),

              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).pushReplacementNamed('/screens_usuario');
              //   }, 
              //   child: const Text(
              //     'Omitir',
              //     style: TextStyle(
              //       color: Color.fromRGBO(255, 87, 110, 1),
              //       fontSize: 18,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
        )
      ),
    );
  }
}