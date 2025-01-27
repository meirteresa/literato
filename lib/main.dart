//firebase
import 'package:flutter/material.dart';
import 'package:literato/firebase_options.dart';
import 'package:literato/views/login.dart';
import 'package:literato/views/cadastro.dart';
import 'package:literato/views/home.dart';
import 'package:literato/views/individual.dart';
import 'package:literato/views/multiplayer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inicializa o Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(), // Mostra um loading enquanto verifica o estado
              ),
            );
          } else if (snapshot.hasData) {
            return HomePage(); 
          } else {
            return LoginPage(); 
          }
        },
      ),
      routes: {
        '/homepage': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/individual': (context) => const IndividualPage(),
        '/multiplayer': (context) => const MultiplayerPage(),
      },
    );
  }
}


