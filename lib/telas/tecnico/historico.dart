import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AtendimentosTecnico extends StatefulWidget {
  const AtendimentosTecnico({super.key});

  @override
  _AtendimentosTecnicoState createState() => _AtendimentosTecnicoState();
}

class _AtendimentosTecnicoState extends State<AtendimentosTecnico> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _agendamentos = [];
  List<Map<String, dynamic>> _agendamentosFiltrados = [];

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

  Stream<List<Map<String, dynamic>>> _obterAgendamentosDoTecnico() {
    String tecnicoId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('horarios')
        .where('uidTecnico', isEqualTo: tecnicoId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> agendamentos = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();

        // Obtém o nome do solicitante a partir do 'uidUsuario'
        if (data.containsKey('uidUsuario')) {
          String uidUsuario = data['uidUsuario'];
          DocumentSnapshot usuarioDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uidUsuario)
              .get();

          data['nomeSolicitante'] = usuarioDoc.exists
              ? usuarioDoc['nome'] ?? 'Nome não encontrado'
              : 'Nome não encontrado';
        }

        // Verifica e converte o campo 'agendamentoId' para DateTime
        if (data.containsKey('agendamentoId') &&
            data['agendamentoId'] != null) {
          try {
            int agendamentoMilissegundos = int.parse(data['agendamentoId']);
            data['horaMarcada'] =
                DateTime.fromMillisecondsSinceEpoch(agendamentoMilissegundos);
          } catch (e) {
            print('Erro ao converter agendamentoId para DateTime: $e');
            data['horaMarcada'] = DateTime.now(); // Hora atual como fallback
          }
        } else {
          data['horaMarcada'] = DateTime.now();
        }

        agendamentos.add(data);
      }
      return agendamentos;
    });
  }

  List<Map<String, dynamic>> _filtrarAgendamentos(
      List<Map<String, dynamic>> agendamentos, String query) {
    if (query.isEmpty) return agendamentos;

    return agendamentos
        .where((agendamento) => agendamento['nomeSolicitante']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Histórico de Atendimentos",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Barra de pesquisa
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Pesquisar por solicitante",
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    _agendamentosFiltrados =
                        _filtrarAgendamentos(_agendamentos, value);
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _obterAgendamentosDoTecnico(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: Colors.blueAccent),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nenhum atendimento encontrado.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    if (_agendamentos.isEmpty) {
                      _agendamentos = snapshot.data!;
                      _agendamentosFiltrados = _filtrarAgendamentos(
                          _agendamentos, _searchController.text);
                    }

                    return ListView.builder(
                      itemCount: _agendamentosFiltrados.length,
                      itemBuilder: (context, index) {
                        final agendamento = _agendamentosFiltrados[index];

                        // Obter horaMarcada como DateTime
                        DateTime horaMarcada = agendamento['horaMarcada'];
                        String dataFormatada =
                            DateFormat('dd/MM/yyyy HH:mm').format(horaMarcada);

                        // Exibir os detalhes do agendamento
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: agendamento['status'] == 'aceito'
                                ? Colors.green[100] // Verde claro para aceito
                                : agendamento['status'] == 'recusado'
                                    ? Colors
                                        .red[100] // Vermelho claro para recusado
                                    : Colors.white, // Laranja claro para pendente ou outro
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Solicitante
                              RichText(
                                text: TextSpan(
                                  text: "Solicitante: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: agendamento['nome'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  text: "Configuração: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          agendamento['configuracao'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Problema Relatado
                              RichText(
                                text: TextSpan(
                                  text: "Problema Relatado: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: agendamento['problema'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Hora Marcada
                              RichText(
                                text: TextSpan(
                                  text: "Hora Marcada: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: dataFormatada,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  text: "Contato Utilizado: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: agendamento['contato'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Status
                              Text(
                                agendamento['status'] != null
                                    ? "Status: ${agendamento['status'][0].toUpperCase()}${agendamento['status'].substring(1)}"
                                    : "Status: Aguardando confirmação...",
                                style: TextStyle(
                                  color: agendamento['status'] == 'aceito'
                                      ? Colors.green
                                      : agendamento['status'] == 'recusado'
                                          ? Colors.red
                                          : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
