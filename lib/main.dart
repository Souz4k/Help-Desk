import 'package:app/telas/Login.dart'; // Importação adicionada
import 'package:app/telas/Tela_inicial.dart';
import 'package:app/telas/cliente/tela_inicial_cliente.dart';
import 'package:app/telas/tecnico/tela_inicial_tecnico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RoteadorTela(),
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  Future<String?> _getUserType(String email) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (doc.exists) {
        return doc.data()?['userType'] as String?;
      }
    } catch (e) {
      print('Erro ao obter tipo de usuário: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text(
                ''), // Temporariamente remove o ProgressIndicator
          );
        }
        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: _getUserType(snapshot.data!.email!),
            builder: (context, userTypeSnapshot) {
              if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Text(
                      ''), // Temporariamente remove o ProgressIndicator
                );
              }
              if (userTypeSnapshot.hasData) {
                if (userTypeSnapshot.data == 'cliente') {
                  return telaInicialCliente();
                } else if (userTypeSnapshot.data == 'tecnico') {
                  return Tela_inicial_tecnico();
                }
              }
              return const TelaInicial(); // Caso o tipo de usuário não seja encontrado ou seja inválido
            },
          );
        } else {
          return const Login(); // Alterado para Login()
        }
      },
    );
  }
}
