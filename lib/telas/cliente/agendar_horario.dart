import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/horario.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Tela de Selecionar Técnico
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
      return {
        'uid': doc.id,
        'nome': data['nome'] ?? 'Nome não disponível',
        'telefone': data['telefone'] ?? 'Telefone não disponível',
        'fotoUrl': data['fotoUrl'] ?? ''  // Adiciona a URL da foto aqui
      };
    }).toList();

    setState(() {
      tecnicos = fetchedTecnicos;
    });
  }

  void _onTecnicoSelected(Map<String, dynamic> tecnico) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetalhesTecnicoScreen(tecnico: tecnico)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Técnico'),
        backgroundColor: MinhasCores.azulEscuro,
      ),
      body: ListView.builder(
        itemCount: tecnicos.length,
        itemBuilder: (context, index) {
          final tecnico = tecnicos[index];
          final color = index % 2 == 0 ? MinhasCores.brancogelo : Colors.white;

          return Container(
            color: color,
            child: ListTile(
              leading: tecnico['fotoUrl'].isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(tecnico['fotoUrl']),
                      radius: 25,
                    )
                  : CircleAvatar(
                      child: Icon(Icons.person, size: 50),
                      radius: 25,
                    ),  // Placeholder para quando não há foto
              title: Text(tecnico['nome']),
              onTap: () => _onTecnicoSelected(tecnico),
            ),
          );
        },
      ),
    );
  }
}
// Fim da tela de Selecionar Técnico

// Tela de Detalhes do Técnico
class DetalhesTecnicoScreen extends StatefulWidget {
  final Map<String, dynamic> tecnico;

  DetalhesTecnicoScreen({required this.tecnico});

  @override
  _DetalhesTecnicoScreenState createState() => _DetalhesTecnicoScreenState();
}

class _DetalhesTecnicoScreenState extends State<DetalhesTecnicoScreen> {
  List<Horario> horarios = [];

  @override
  void initState() {
    super.initState();
    _fetchHorarios(widget.tecnico['uid']);
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

  void _onHorarioSelected(Horario horario) {
    if (horario.disponivel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgendarHorarioScreen(
            uid: widget.tecnico['uid'],
            horario: horario,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Técnico'),
        backgroundColor: MinhasCores.azulEscuro,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: MinhasCores.brancogelo,
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Nome: ${widget.tecnico['nome']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Telefone: ${widget.tecnico['telefone']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Horários Disponíveis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
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
                    onTap: () => _onHorarioSelected(horario),
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
          ],
        ),
      ),
    );
  }
}
// Fim da tela de Detalhes do Técnico

// Tela de Agendar Horário
class AgendarHorarioScreen extends StatefulWidget {
  final String uid;
  final Horario horario;

  AgendarHorarioScreen({required this.uid, required this.horario});

  @override
  _AgendarHorarioScreenState createState() => _AgendarHorarioScreenState();
}

class _AgendarHorarioScreenState extends State<AgendarHorarioScreen> {
  User? user;
  String? userName;
  String? userConfig;
  String? userProblema;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        var data = userDoc.data() as Map<String, dynamic>;
        userName = data['nome'];
        userConfig = data['configuracao'];
        userProblema = data['problema'];
        userPhone = data['telefone'];
      });
    }
  }

  void _showConfirmationDialog() {
    final _nomeController = TextEditingController(text: userName);
    final _configuracaoController = TextEditingController(text: userConfig);
    final _problemaController = TextEditingController(text: userProblema);
    final _telefoneController = TextEditingController(text: userPhone);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Agendamento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Você deseja agendar o horário ${widget.horario.hora}?"),
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
              TextField(
                controller: _telefoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                ),
                keyboardType: TextInputType.phone,
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
                  widget.horario.disponivel = false;
                  widget.horario.nome = _nomeController.text;
                  widget.horario.configuracao = _configuracaoController.text;
                  widget.horario.problema = _problemaController.text;
                });
                _onSaved(widget.horario, _telefoneController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onSaved(Horario horario, String telefone) {
    FirebaseFirestore.instance.collection('horarios').doc(horario.id).update({
      'clienteId': user!.uid,
      'nome': horario.nome,
      'configuracao': horario.configuracao,
      'problema': horario.problema,
      'disponivel': horario.disponivel,
      'telefone': telefone,
      'status': 'em_analise', // adiciona o status inicial como 'em_analise'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Horário'),
        backgroundColor: MinhasCores.azulEscuro,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agendando horário: ${widget.horario.hora}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showConfirmationDialog,
              child: Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
// Fim da tela de Agendar Horário
