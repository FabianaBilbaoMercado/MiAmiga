// ignore_for_file: sort_child_properties_last, use_build_context_synchronously

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/pages/network_helper.dart';
import 'package:miamiga_app/resources/image_data_super.dart';
import 'package:miamiga_app/utils/utils.dart';

class PerfilSupervisor extends StatefulWidget {
  final User? user;

  const PerfilSupervisor({
    super.key,
    required this.user,
  });

  @override
  State<PerfilSupervisor> createState() => _PerfilSupervisorState();
}

class _PerfilSupervisorState extends State<PerfilSupervisor> {
  final ciController = TextEditingController();
  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();

  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? imageUrl;

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // await _googleSignIn.signOut();
    Navigator.of(context).pushReplacementNamed('/inicio_o_registrar');
  }

  final CollectionReference _registration =
      FirebaseFirestore.instance.collection('users');

  Future<void> loadProfileImage(String userId) async {
    try {
      final imageSnapshot = await FirebaseFirestore.instance
          .collection('imageUser')
          .doc(userId)
          .get();
      if (imageSnapshot.exists) {
        final imageUrl = imageSnapshot['imageUrl'];
        if (imageUrl != null) {
          final image = await NetworkHelper.loadImage(imageUrl);
          setState(() {
            _image = image;
          });
        }
      }
    } catch (e) {
      print("Error al cargar la imagen del perfil: $e");
    }
  }

  Future<void> _fetchData() async {
    try {
      // Check if widget.user is not null before proceeding
      if (widget.user != null) {
        final DocumentSnapshot documentSnapshot =
            await _registration.doc(widget.user!.uid).get();

        // Check if the document exists
        if (documentSnapshot.exists) {

          fullnameController.text = documentSnapshot['fullname'];
          ciController.text = documentSnapshot['ci'].toString();
          phoneController.text = documentSnapshot['phone'].toString();
          // double latitude = documentSnapshot['lat'] as double;
          // double longitude = documentSnapshot['long'] as double;

          // lat = latitude;
          // long = longitude;
          loadProfileImage(widget.user!.uid);

          // final List<Placemark> placemarks =
          //     await placemarkFromCoordinates(latitude, longitude);

          // if (placemarks.isNotEmpty) {
          //   final Placemark placemark = placemarks[0];
          //   final String street = placemark.thoroughfare ?? '';
          //   final String locality = placemark.locality ?? '';
          //   final String country = placemark.country ?? '';

          //   final locationString = '$street, $locality, $country';
          //   locationController.text = locationString;
          // } else {
          //   locationController.text = 'No se pudo obtener la ubicación';
          // }
        } else {
          // Handle the case where the document doesn't exist
          print("No existe el documento.");
        }
        /* //obtener del metodo de ubicacion
      final String location = await getUserLocation();

      //imprimir la ubicacion
      print("Ubicacion: $location"); */
      } else {
        // Handle the case where widget.user is null
        print("El usuario es nulo.");
      }
    } catch (e) {
      // Handle any other errors that may occur during data retrieval
      print("Error en obtener datos: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    /* getUserLocation(); */
  }

  // double lat = 0.0;
  // double long = 0.0;

  // Future<String> getUserLocation() async {
  //   try {
  //     final List<Placemark> placemarks = await placemarkFromCoordinates(
  //       lat,
  //       long,
  //     );

  //     if (placemarks.isNotEmpty) {
  //       final Placemark placemark = placemarks[0];
  //       final String street = placemark.thoroughfare ?? '';
  //       final String locality = placemark.locality ?? '';
  //       final String country = placemark.country ?? '';

  //       final formattedAddress = '$street, $locality, $country';
  //       return formattedAddress;
  //     } else {
  //       return 'No se pudo obtener la ubicación';
  //     }
  //   } catch (e) {
  //     print('Error en obteniendo ubicacion del usuario: $e');
  //     return 'No se pudo obtener la ubicación';
  //   }
  // }

  // Future<void> updateLocation() async {
  //   try {
  //     final String location = await getUserLocation();
  //     locationController.text = location;
  //   } catch (e) {
  //     print('Error actualizando ubicacion: $e');
  //   }
  // }

  void editPersonalData() async {
    //i want a navigator to go to the edit perfil page
    Navigator.of(context).pushNamed(
      '/editar_perfil_supervisor',
      arguments: widget.user,
    );
  }

  Uint8List? _image;

  void selectedImageProfile() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
    showSaveDialog(context);
  }

  void saveProfileImage() async {
    try {
      if (_image != null && widget.user != null) {
        String userId = widget.user!.uid;
        String saveResult =
            await StoreDataSuper().saveData(file: _image!, userId: userId);

        if (saveResult == 'Se ocurrió un error') {
          print('Error al guardar la imagen en Firestore');
        } else {
          print('¡Imagen guardada con éxito!');
        }
      } else {
        print('La imagen o el usuario son nulos');
      }
    } catch (e) {
      print("Error guardando la imagen: $e");
    }
  }

  void showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Guardar Imagen"),
          content: const Text("Quieres guardar la imagen?"),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Guardar",
                style: TextStyle(
                  color: Color.fromRGBO(255, 87, 110, 1),
                ),
              ),
              onPressed: () {
                saveProfileImage();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            // Wrap the content with a Stack
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Header(
                        header: 'Mi Perfil',
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          _showSignOutConfirmationDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_image != null) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.6), // make it circular
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.8, // adjust this value as needed
                                    height: MediaQuery.of(context).size.width * 0.8, // adjust this value as needed
                                    child: ClipOval(
                                      child: Image.memory(_image!, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: _image != null
                            ? ClipOval(
                                child: Image.memory(
                                  _image!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                      ),
                    ),
                    Positioned(
                      child: IconButton(
                        onPressed: () {
                          selectedImageProfile();
                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                          color: Colors.black,
                        ),
                      ),
                      bottom: -10,
                      left: 45,
                    ),
                  ],
                ),
                  FutureBuilder(
                      future: null,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromRGBO(255, 87, 110, 1),
                            )
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Column(
                            children: [
                              const SizedBox(height: 25),
                              MyTextField(
                                controller: ciController,
                                text: 'Carnet de Identidad',
                                hintText: 'Carnet de Identidad',
                                obscureText: false,
                                isEnabled: false,
                                isVisible: true,
                              ),
                              const SizedBox(height: 15),
                              MyTextField(
                                controller: fullnameController,
                                text: 'Nombre Completo',
                                hintText: 'Nombre Completo',
                                obscureText: false,
                                isEnabled: false,
                                isVisible: true,
                              ),
                              // const SizedBox(height: 15),
                              // MyTextField(
                              //   controller: locationController,
                              //   text: 'Ubicación',
                              //   hintText: 'Ubicación',
                              //   obscureText: false,
                              //   isEnabled: false,
                              //   isVisible: true,
                              // ),
                              const SizedBox(height: 15),
                              MyTextField(
                                controller: phoneController,
                                text: 'Telefono',
                                hintText: 'Telefono',
                                obscureText: false,
                                isEnabled: false,
                                isVisible: true,
                              ),
                              const SizedBox(height: 25),
                              MyImportantBtn(
                                  onTap: editPersonalData,
                                  text: 'Editar Perfil'),
                            ],
                          );
                        }
                      }),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      widget.user != null
                          ? 'Iniciado como: ${widget.user?.email}'
                          : 'Usuario desconocido',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show the sign-out confirmation dialog
  void _showSignOutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Cierre de Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar la sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform sign-out action here
                signUserOut(context); // Call your sign-out method
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Color.fromRGBO(255, 87, 110, 1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
