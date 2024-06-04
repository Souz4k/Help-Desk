import 'package:app/telas/Tela_inicial.dart';
import 'package:flutter/material.dart';
import 'package:app/Pedidos.dart';
import 'package:app/telas/cliente/geolocalizacao_cli.dart';
import 'package:app/telas/suporte.dart';
import 'package:app/telas/tecnico/alterar_info_Tec.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Tela_inicial_tecnico extends StatefulWidget {
  const Tela_inicial_tecnico({Key? key});

  @override
  _Tela_inicial_tecnicoState createState() => _Tela_inicial_tecnicoState();
}

class _Tela_inicial_tecnicoState extends State<Tela_inicial_tecnico> {
  late User _user;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser!;
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(_user.uid).get();

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
                  MaterialPageRoute(builder: (context) => AlterarInfotec()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: MinhasCores.brancogelo,
                    shape: BoxShape.circle,
                    image: _imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageUrl == null
                      ? Icon(Icons.camera_alt_outlined, size: 70)
                      : null,
                ),
                SizedBox(height: 70),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pedidos(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 75,
                    margin: EdgeInsets.only(top: 0),
                    color: MinhasCores.brancogelo,
                    child: Center(
                      child: Text(
                        "Agendamento",
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
                    margin: EdgeInsets.only(top: 0),
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
                    margin: EdgeInsets.only(top: 0),
                    color: MinhasCores.brancogelo,
                    child: Center(
                      child: Text(
                        "Agendamentos na Região",
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
          ),
        ),
      ),
    );
  }
}
