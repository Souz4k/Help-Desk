// Parte do Cliente:

import 'package:app/servicos/horario.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelecionarTecnicoScreen extends StatefulWidget {
  @override
  _SelecionarTecnicoScreenState createState() =>
      _SelecionarTecnicoScreenState();
}

class _SelecionarTecnicoScreenState extends State<SelecionarTecnicoScreen> {
  List<Map<String, dynamic>> tecnicos = [];
  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchTecnicos();
  }

  Future<void> _getCurrentUser() async {
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _fetchTecnicos() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'tecnico')
        .get();

    List<Map<String, dynamic>> fetchedTecnicos = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {'uid': doc.id, 'nome': data['nome'] ?? 'Nome não disponível'};
    }).toList();

    setState(() {
      tecnicos = fetchedTecnicos;
    });
  }

  void _onTecnicoSelected(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgendarHorarioScreen(uid: uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Técnico'),
      ),
      body: ListView.builder(
        itemCount: tecnicos.length,
        itemBuilder: (context, index) {
          final tecnico = tecnicos[index];
          return ListTile(
            title: Text(tecnico['nome']),
            onTap: () => _onTecnicoSelected(tecnico['uid']),
          );
        },
      ),
    );
  }
}

class AgendarHorarioScreen extends StatefulWidget {
  final String uid;

  AgendarHorarioScreen({required this.uid});

  @override
  _AgendarHorarioScreenState createState() => _AgendarHorarioScreenState();
}

class _AgendarHorarioScreenState extends State<AgendarHorarioScreen> {
  List<Horario> horarios = [];
  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchHorarios(widget.uid);
  }

  Future<void> _getCurrentUser() async {
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _fetchHorarios(String uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('horarios')
        .where('uid', isEqualTo: uid)
        .get();

    List<Horario> fetchedHorarios = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Horario(
        id: doc.id,
        hora: data['horario'],
        disponivel: data['disponivel'],
        nome: data['nome'],
        configuracao: data['configuracao'],
        problema: data['problema'],
      );
    }).toList();

    setState(() {
      horarios = fetchedHorarios;
    });
  }

  void _showConfirmationDialog(Horario horario) {
    final _nomeController = TextEditingController();
    final _configuracaoController = TextEditingController();
    final _problemaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Agendamento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Você deseja agendar o horário ${horario.hora}?"),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                ),
              ),
              TextField(
                controller: _configuracaoController,
                decoration: InputDecoration(
                  labelText: 'Configuração do Computador',
                ),
              ),
              TextField(
                controller: _problemaController,
                decoration: InputDecoration(
                  labelText: 'Problema',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () {
                setState(() {
                  horario.disponivel = false;
                  horario.nome = _nomeController.text;
                  horario.configuracao = _configuracaoController.text;
                  horario.problema = _problemaController.text;
                });
                _onSaved(horario);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleHorario(Horario horario) {
    if (horario.disponivel) {
      _showConfirmationDialog(horario);
    }
  }

  void _onSaved(Horario horario) {
    FirebaseFirestore.instance.collection('horarios').doc(horario.id).update({
      'uid': user!.uid,
      'nome': horario.nome,
      'configuracao': horario.configuracao,
      'problema': horario.problema,
      'disponivel': horario.disponivel,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Horário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: horarios.length,
          itemBuilder: (context, index) {
            final horario = horarios[index];
            return GestureDetector(
              onTap: () {
                _toggleHorario(horario);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: horario.disponivel ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    horario.hora,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
