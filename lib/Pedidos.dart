import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Horario {
  final String id;
  final String hora;
  bool disponivel;
  String? nome;
  String? configuracao;
  String? problema;

  Horario({
    required this.id,
    required this.hora,
    this.disponivel = true,
    this.nome,
    this.configuracao,
    this.problema,
  });
}

class Pedidos extends StatefulWidget {
  @override
  _PedidosState createState() => _PedidosState();
}

class _PedidosState extends State<Pedidos> {
  List<Horario> horarios = [];
  final _horaController = TextEditingController();
  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _horaController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchUserHorarios();
    } else {
      // Handle user not logged in
    }
  }

  Future<void> _fetchUserHorarios() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('horarios')
        .where('uid', isEqualTo: user!.uid)
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

  Future<void> _addHorario() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        String formattedDateTime =
            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

        bool horarioExistente =
            horarios.any((horario) => horario.hora == formattedDateTime);

        if (horarioExistente) {
          _showDuplicateHorarioDialog();
        } else {
          // Salvar no Firestore
          DocumentReference docRef =
              await FirebaseFirestore.instance.collection('horarios').add({
            'horario': formattedDateTime,
            'uid': user!.uid,
            'nome': null,
            'configuracao': null,
            'problema': null,
            'disponivel': true,
          });

          // Adicionar na lista local
          setState(() {
            horarios.add(Horario(id: docRef.id, hora: formattedDateTime));
          });
        }
      }
    }
  }

  void _showDuplicateHorarioDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Horário Duplicado"),
          content: Text(
              "Este horário já foi adicionado. Por favor, selecione um horário diferente."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Agendamento de Horários'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Adicionar Horários'),
              Tab(text: 'Agendar Horários'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aba de Adição de Horários
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _addHorario,
                    child: Text('Adicionar Horário'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: horarios.length,
                      itemBuilder: (context, index) {
                        final horario = horarios[index];
                        return ListTile(
                          title: Text(horario.hora),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (horario.nome != null)
                                Text('Nome: ${horario.nome}'),
                              if (horario.configuracao != null)
                                Text('Configuração: ${horario.configuracao}'),
                              if (horario.problema != null)
                                Text('Problema: ${horario.problema}'),
                            ],
                          ),
                          trailing: Icon(
                            Icons.check,
                            color:
                                horario.disponivel ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Aba de Agendamento
            Padding(
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
          ],
        ),
      ),
    );
  }
}
