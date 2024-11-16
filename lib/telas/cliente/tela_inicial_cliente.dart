import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/AjudaTecnica.dart';
import 'package:app/telas/AtendimentosAgendados.dart';
import 'package:app/telas/HistoricoCliente.dart';
import 'package:app/telas/cliente/agendar_horario.dart';
import 'package:app/telas/cliente/alterar_Info_Cli.dart';
import 'package:app/telas/cliente/geolocalizacao_cli.dart';
import 'package:app/telas/suporte.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/telas/Tela_inicial.dart';

class telaInicialCliente extends StatefulWidget {
  @override
  telaInicialClienteState createState() => telaInicialClienteState();
}

class telaInicialClienteState extends State<telaInicialCliente> {
  late User _user;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser!;
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();

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

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 28),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: Text("Help Desk", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Removido: _pickImageFromCamera(); // Adicione aqui a lógica para selecionar uma imagem da câmera
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage:
                      _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                  backgroundColor: MinhasCores.brancogelo,
                  child: _imageUrl == null
                      ? Icon(Icons.person, size: 70, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              _buildMenuButton("Ajuda Técnica", Icons.build, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SelecionarTecnicoScreen()),
                );
              }),
              _buildMenuButton("Histórico de Agendamenos", Icons.history, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AtendimentosAgendados()),
                );
              }),
              _buildMenuButton("Suporte", Icons.help_outline, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Suporte()),
                );
              }),
              _buildMenuButton("Técnicos em sua Região", Icons.location_on, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Geolocalizacao()),
                );
              }),
              _buildMenuButton("Informações de seu Perfil", Icons.person, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlterarInfoCli()),
                );
              }),
              _buildMenuButton(
                  "Deslogar", Icons.logout, () => _deslogar(context)),
            ],
          ),
        ),
      ),
    );
  }
}
