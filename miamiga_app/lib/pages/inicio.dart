// ignore_for_file: use_build_context_synchronously, avoid_print, duplicate_ignore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miamiga_app/components/important_button.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';
import 'package:miamiga_app/model/datos_registro_usuario.dart';
import 'package:miamiga_app/pages/incidente.dart';

class InicioScreen extends StatefulWidget {
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denunciaData;
  const InicioScreen({
    super.key,
    required this.user,
    required this.incidentData,
    required this.denunciaData,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {

  Future<String> getUserName(User? user) async {
  if (user != null) {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final fullName = snapshot.get('fullname');
        return fullName;
      } else {
        return 'Usuario desconocido';
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user name: $e');
      return 'Usuario desconocido';
    }
  } else {
    return 'Usuario desconocido';
  }
}

  void denunciarScreen() async{
      //i want a navigator to go to the edit perfil page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DenunciaIncidente(
            user: widget.user, 
            incidentData: widget.incidentData, 
            denuncianteData: widget.denunciaData,
          ), 
        ),
      );
    }

    // Future<String> fetchCaseData(String? userId) async {
    //   if (userId == null) {
    //     throw Exception('User ID is null');
    //   }

    //   final querySnapshot = await FirebaseFirestore.instance
    //       .collection('cases')
    //       .where('user', isEqualTo: userId)
    //       .get();

    //   if (querySnapshot.docs.isEmpty) {
    //     return 'No hay casos';
    //   }

    //   return querySnapshot.docs.first.id;
    // }

    Future<UserRegister> fetchDenuncianteData(String? userId) async {
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) {
        throw Exception('No user found with ID $userId');
      }

      return UserRegister(
        ci: doc.get('ci'),
        fullname: doc.get('fullname'),
        email: doc.get('email'),
        phone: doc.get('phone'),
        lat: doc.get('lat'),
        long: doc.get('long'),
      ); 
     }
    
    Future<void> createAlert(User? user) async {
    try {
      // Extract UID from user
      String? userId = user?.uid;

      if (userId == null) {
        print('Error: User is null or does not have UID');
        return;
      }

      // String caseId = await fetchCaseData(userId);

      UserRegister userRegister = await fetchDenuncianteData(userId);

      // The rest of your code remains unchanged
      final CollectionReference _alert = FirebaseFirestore.instance.collection('alert');

      QuerySnapshot<Object?> userAlerts = await _alert.where('user', isEqualTo: userId).get();

      int newAlert = userAlerts.docs.isNotEmpty ? userAlerts.docs.first.get('alert') + 1 : 1;

      // Show a confirmation dialog
      bool confirmAlert = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Alerta'),
            content: const Text('Deseas crear un alert?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // User pressed cancel
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
                  Navigator.of(context).pop(true); // User confirmed alert
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 87, 110, 1),
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (confirmAlert == true) {
        showDialog(
          context: context, 
          barrierDismissible: false, 
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(255, 87, 110, 1),
              ),
            );
          }
        );

        if (userAlerts.docs.isNotEmpty) {
        DocumentSnapshot<Object?> userAlert = userAlerts.docs.first;

        await _alert.doc(userAlert.id).update({
          'alert': newAlert,
          'fecha': DateTime.now(),
        });

        // await FirebaseFirestore.instance.collection('cases').doc(caseId).update({
        //   'alertCount': newAlert,
        // });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta actualizada'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await _alert.add({
            'alert': newAlert,
            'user': userId,
            'ci': userRegister.ci,
            'fullname': userRegister.fullname,
            'email': userRegister.email,
            'phone': userRegister.phone,
            'lat': userRegister.lat,
            'long': userRegister.long,
            'fecha': DateTime.now(),
            // 'case': caseId,
          });

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta creada'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear alerta'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      print('Error al crear el caso: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   checkUserProfile();
  // }

  // Future<void> checkUserProfile() async {
  //   final user = FirebaseAuth.instance.currentUser;
      
  //   if(user != null) {
  //     final DocumentSnapshot userDoc =
  //       await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  //       if (userDoc.exists) {
  //         final Map<String, dynamic> userData =
  //           userDoc.data() as Map<String, dynamic>;
  //         if (userData['fullname'] == null
  //             || userData['ci'] == null
  //             || userData['phone'] == null
  //             || userData['lat'] == null
  //             || userData['long'] == null) {
            
  //         }
  //       }
  //   }
  // }

  // void showProfileCompletionSnackBar() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text('Completa tu perfil para poder denunciar'),
  //       duration: const Duration(seconds: 3),
  //       action: SnackBarAction(
  //         label: 'Completar Perfil',
  //         onPressed: () {
  //           Navigator.of(context).pushNamed('/completar_perfil');
  //         },
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              FutureBuilder<String>(
                future: getUserName(widget.user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(255, 87, 110, 1),
                      )
                    );
                  } else {
                    final userName = snapshot.data ?? 'Usuario desconocido';
                    return Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Text(
                              'Bienvenido, $userName',
                                style: const TextStyle(fontSize: 40),
                                textAlign: TextAlign.start,
                            ),
                          ),    
                          const SizedBox(height: 100),
                          MyImportantBtn(
                            text: 'DENUNCIAR',
                            onTap: denunciarScreen,
                          ),
                          const SizedBox(height: 100),
                          ImportantButton(
                            text: 'ALERTA',
                            onTap: () async{
                              User? user = widget.user;
                              // DenuncianteData denuncianteData = widget.denunciaData;
                              await createAlert(user);
                            },
                            icon: Icons.warning_rounded,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
