import 'package:app/servicos/horario.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdicionarHorarioScreen extends StatefulWidget {
  @override
  _AdicionarHorarioScreenState createState() => _AdicionarHorarioScreenState();
}

class _AdicionarHorarioScreenState extends State<AdicionarHorarioScreen> {
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
        DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        DateTime now = DateTime.now();

        if (selectedDateTime.isBefore(now)) {
          _showInvalidHorarioDialog();
        } else {
          String formattedDateTime =
              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

          bool horarioExistente =
              horarios.any((horario) => horario.hora == formattedDateTime);

          if (horarioExistente) {
            _showDuplicateHorarioDialog();
          } else {
            DocumentReference docRef =
                await FirebaseFirestore.instance.collection('horarios').add({
              'horario': formattedDateTime,
              'uid': user!.uid,
              'nome': null,
              'configuracao': null,
              'problema': null,
              'disponivel': true,
            });

            setState(() {
              horarios.add(Horario(id: docRef.id, hora: formattedDateTime));
            });
          }
        }
      }
    }
  }

  void _showInvalidHorarioDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Horário Inválido"),
          content: Text(
              "Você não pode adicionar um horário no passado. Por favor, selecione um horário atual ou futuro."),
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

  Future<void> _removeHorario(String id) async {
    await FirebaseFirestore.instance.collection('horarios').doc(id).delete();

    setState(() {
      horarios.removeWhere((horario) => horario.id == id);
    });
  }

  void _showRemoveConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remover Horário"),
          content: Text("Você deseja remover este horário?"),
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
                _removeHorario(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Horário'),
      ),
      body: Padding(
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
                        if (horario.nome != null) Text('Nome: ${horario.nome}'),
                        if (horario.configuracao != null)
                          Text('Configuração: ${horario.configuracao}'),
                        if (horario.problema != null)
                          Text('Problema: ${horario.problema}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          color: horario.disponivel ? Colors.green : Colors.red,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              _showRemoveConfirmationDialog(horario.id),
                        ),
                      ],
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
