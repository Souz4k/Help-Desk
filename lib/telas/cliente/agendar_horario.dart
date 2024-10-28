import 'package:app/_comum/minhas_cores.dart';
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
      return {
        'uid': doc.id,
        'nome': data['nome'] ?? 'Nome não disponível',
        'telefone': data['telefone'] ?? 'Telefone não disponível',
        'fotoUrl': data['fotoUrl'] ?? ''
      };
    }).toList();

    setState(() {
      tecnicos = fetchedTecnicos;
    });
  }

  void _showTecnicoDetails(Map<String, dynamic> tecnico) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // Use Expanded para que o texto não fique cortado
                child: Text(
                  "Detalhes do Técnico",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  overflow: TextOverflow
                      .visible, // Garante que o texto não fique cortado
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tecnico['fotoUrl'].isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(tecnico['fotoUrl']),
                      radius: 50,
                    )
                  : CircleAvatar(
                      child: Icon(Icons.person, size: 50),
                      radius: 50,
                    ),
              SizedBox(height: 10),
              Text(tecnico['nome'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(tecnico['telefone'],
                  style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _onTecnicoSelected(tecnico);
                },
                child: Text("Ver horários disponíveis",
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        title: Text('Selecionar Técnico',
            style: TextStyle(fontSize: 20, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: tecnicos.length,
          itemBuilder: (context, index) {
            final tecnico = tecnicos[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: tecnico['fotoUrl'].isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(tecnico['fotoUrl']),
                        radius: 25,
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person, size: 30),
                        radius: 25,
                      ),
                title: Text(tecnico['nome'], style: TextStyle(fontSize: 18)),
                onTap: () => _showTecnicoDetails(tecnico),
              ),
            );
          },
        ),
      ),
    );
  }
}

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

  Widget _buildTextField(
      TextEditingController controller, String labelText, bool obscureText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: obscureText,
    );
  }

  void _showConfirmationDialog(Horario horario) {
  final _nomeController = TextEditingController(text: horario.nome);
  final _configuracaoController =
      TextEditingController(text: horario.configuracao);
  final _problemaController = TextEditingController(text: horario.problema);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white, // Define a cor de fundo do card
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                "Confirmar Agendamento",
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Horário: ${horario.hora}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildTextField(_nomeController, "Nome", false),
              SizedBox(height: 20),
              _buildTextField(
                  _configuracaoController, "Configuração do Aparelho", false),
              SizedBox(height: 20),
              _buildTextField(_problemaController, "Problema", false),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancelar",
                style: TextStyle(color: Colors.blueAccent, fontSize: 14)), // Alterado para azul
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Confirmar",
                style: TextStyle(color: Colors.white, fontSize: 14)),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('horarios')
                  .doc(horario.id)
                  .update({
                'disponivel': false,
                'nome': _nomeController.text,
                'configuracao': _configuracaoController.text,
                'problema': _problemaController.text,
              });
              setState(() {
                horario.disponivel = false;
                horario.nome = _nomeController.text;
                horario.configuracao = _configuracaoController.text;
                horario.problema = _problemaController.text;
              });
              Navigator.pop(context);
              _showSuccessDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      );
    },
  );
}

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8), // Espaço entre o ícone e o texto
                  Expanded(
                    child: Text(
                      "Agendamento Realizado",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2, // Permitir até 2 linhas
                      overflow: TextOverflow
                          .ellipsis, // Exibir reticências para textos longos
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: Text(
            "Seu agendamento foi realizado com sucesso!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  16, // Tamanho da fonte ajustado para melhorar a legibilidade
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green, // Cor de fundo do botão
                  foregroundColor: Colors.white, // Cor do texto
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20), // Bordas arredondadas
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12), // Padding
                ),
              ),
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
        title: Text('Horários de ${widget.tecnico['nome']}',
            style: TextStyle(fontSize: 20, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
              onTap: () =>
                  horario.disponivel ? _showConfirmationDialog(horario) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: horario.disponivel ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  horario.hora,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
