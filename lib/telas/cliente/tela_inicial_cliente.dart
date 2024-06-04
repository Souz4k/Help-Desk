import 'package:app/telas/Tela_inicial.dart';
import 'package:flutter/material.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/AjudaTecnica.dart';
import 'package:app/telas/AtendimentosAgendados.dart';
import 'package:app/telas/HistoricoCliente.dart';
import 'package:app/telas/cliente/alterar_Info_Cli.dart';
import 'package:app/telas/cliente/geolocalizacao_cli.dart';
import 'package:app/telas/suporte.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/_comum/meu_snackbar.dart';

class TelaInicialCliente extends StatefulWidget {
  const TelaInicialCliente({Key? key}) : super(key: key);

  @override
  State<TelaInicialCliente> createState() => _TelaInicialClienteState();
}

class _TelaInicialClienteState extends State<TelaInicialCliente> {
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data()!.containsKey('fotourl')) {
      setState(() {
        _imageUrl = userDoc['fotourl'];
      });
    }
  }

  Future<void> _deslogar(BuildContext context) async {
    try {
      await AutenticacaoServico().deslogar();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaInicial()),
      );
    } catch (e) {
      print("Erro ao deslogar: $e");
      mostrarSnackBar(context: context, texto: "Erro ao deslogar");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MinhasCores.azulEscuro,
        automaticallyImplyLeading: false,
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Deslogar"),
              onTap: () => _deslogar(context),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Informações"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlterarInfoCli()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            margin: EdgeInsets.only(bottom: 100, top: 50, left: 10),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: MinhasCores.brancogelo,
              borderRadius: BorderRadius.circular(100),
            ),
            child: _imageUrl.isNotEmpty
                ? AspectRatio(
                    aspectRatio: 1,
                    child: ClipOval(
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Icon(Icons.camera_outlined),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AjudaTecnica(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 75,
              color: MinhasCores.brancogelo,
              child: Center(
                child: Text(
                  "Ajuda técnica",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoricoCliente(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 75,
              color: Colors.white,
              child: Center(
                child: Text(
                  "Histórico de Técnicos",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AtendimentosAgendados(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 75,
              color: MinhasCores.brancogelo,
              child: Center(
                child: Text(
                  "Atendimentos agendados",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Suporte(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 75,
              color: Colors.white,
              child: Center(
                child: Text(
                  "Suporte",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Geolocalizacao(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 75,
              color: MinhasCores.brancogelo,
              child: Center(
                child: Text(
                  "Técnicos em sua região",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
