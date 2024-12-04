import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/AjudaTecnica.dart';
import 'package:app/telas/AtendimentosAgendados.dart';
import 'package:app/telas/HistoricoCliente.dart';
import 'package:app/telas/cliente/agendar_horario.dart';
import 'package:app/telas/cliente/alterar_Info_Cli.dart';
import 'package:app/telas/cliente/geolocalizacao_cli.dart';
import 'package:app/telas/suporte.dart';
import 'package:app/telas/Tela_inicial.dart';

class telaInicialCliente extends StatefulWidget {
  @override
  telaInicialClienteState createState() => telaInicialClienteState();
}

class telaInicialClienteState extends State<telaInicialCliente> {
  late User _user;
  String? _imageUrl;
  String? _userName;

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

    if (userDoc.exists) {
      setState(() {
        _imageUrl = userDoc.data()?['fotourl'];
        _userName = userDoc.data()?['nome'] ?? 'Usuário';
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

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(15),
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
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(220), // Increase the height for more space
        child: AppBar(
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove the back button
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: SingleChildScrollView(
              // Wrap in a scroll view to avoid overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60, // Increased the size of the profile picture
                    backgroundImage:
                        _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: _imageUrl == null
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Olá, ${_userName ?? 'Usuário'}",
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                    style: const TextStyle(
                      fontSize:
                          24, // Slightly smaller font size for better spacing
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildMenuItem("Ajuda Técnica", Icons.build, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelecionarTecnicoScreen()),
              );
            }),
            _buildMenuItem("Histórico de Agendamentos", Icons.history, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AtendimentosAgendados()),
              );
            }),
            _buildMenuItem("Suporte", Icons.help_outline, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Suporte()),
              );
            }),
            _buildMenuItem("Técnicos em sua Região", Icons.location_on, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Geolocalizacao()),
              );
            }),
            _buildMenuItem("Informações de Perfil", Icons.person, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlterarInfoCli()),
              );
            }),
            _buildMenuItem("Sair", Icons.logout, () => _deslogar(context)),
          ],
        ),
      ),
    );
  }
}
