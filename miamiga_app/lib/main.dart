import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miamiga_app/index/indexes.dart';


// ignore: unused_import
import 'package:miamiga_app/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Miamiga',
      initialRoute: '/',
      routes: {
        '/':(context) => const SplashScreen(),
        '/auth':(context) => const AuthPage(),
        '/inicio_o_registrar':(context) => WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: const LoginOrRegister(),
        ),
        '/screens_usuario': (context) => WillPopScope( 
          onWillPop: () async {
            return false;
          },
          child: const Screens(),
        ),
        '/screens_supervisor':(context) => WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: const ScreenSupervisor(),
        ),
        '/detalle_denuncia':(context) => DetalleDenuncia(
          user: FirebaseAuth.instance.currentUser,
          incidentData: IncidentData(description: '', date: DateTime.now(), lat: 0.0, long: 0.0, imageUrls: [], audioUrl: ''),
          denuncianteData: DenuncianteData(fullName: '', ci: 0, phone: 0, lat: 0.0, long: 0.0, documentId: '', estado: ''), future: Future(() => null), 
          userIdDenuncia: '', documentIdDenuncia: '',
        ),
        '/completar_perfil':(context) => const CompleteProfile(),
        '/perfil_usuario':(context) => PerfilScreen(user: FirebaseAuth.instance.currentUser),
        '/perfil_supervisor':(context) => PerfilSupervisor(user: FirebaseAuth.instance.currentUser),
        '/editar_perfil_usuario':(context) => EditPerfil(user: FirebaseAuth.instance.currentUser),
        '/editar_perfil_supervisor':(context) => EditPerfilSupervisor(user: FirebaseAuth.instance.currentUser),
        '/casos':(context) => CasePage(item: FirebaseAuth.instance.currentUser!.uid, user: FirebaseAuth.instance.currentUser!),
        '/leer_casos':(context) => ReadCases(user: FirebaseAuth.instance.currentUser!, incidentData: IncidentData(description: '', date: DateTime.now(), lat: 0.0, long: 0.0, imageUrls: [], audioUrl: ''), 
        denuncianteData: DenuncianteData(fullName: '', ci: 0, phone: 0, lat: 0.0, long: 0.0, documentId: '', estado: '')),
      },
    );
  }
}






