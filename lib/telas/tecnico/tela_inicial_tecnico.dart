import 'package:app/telas/Tela_inicial.dart';
import 'package:app/telas/cliente/geolocalizacao_cli.dart';
import 'package:flutter/material.dart';
import 'package:app/telas/tecnico/adicionar_horario.dart';
import 'package:app/telas/suporte.dart';
import 'package:app/telas/tecnico/alterar_info_Tec.dart';
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
        _imageUrl = userDoc['fotourl'];
        _userName = userDoc['nome'] ?? 'Usuário';
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

  Widget _buildMenuItem(
      String title, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
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
        preferredSize: const Size.fromHeight(220),
        child: AppBar(
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: _imageUrl == null
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      "Olá, ${_userName ?? 'Técnico'}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top, // Preenche toda a altura
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildMenuItem("Agendamento", Icons.calendar_today, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdicionarHorarioScreen()),
                    );
                  }, Colors.white),
                  _buildMenuItem("Suporte", Icons.help_outline, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Suporte()),
                    );
                  }, Colors.white),
                  _buildMenuItem("Agendamentos na Região", Icons.location_on,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Geolocalizacao()),
                    );
                  }, Colors.white),
                  _buildMenuItem("Informações", Icons.person, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AlterarInfotec()),
                    );
                  }, Colors.white),
                  _buildMenuItem("Sair", Icons.logout,
                      () => _deslogar(context), Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
