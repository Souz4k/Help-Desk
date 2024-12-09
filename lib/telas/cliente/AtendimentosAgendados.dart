import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AtendimentosAgendados extends StatefulWidget {
  const AtendimentosAgendados({super.key});

  @override
  _AtendimentosAgendadosState createState() => _AtendimentosAgendadosState();
}

class _AtendimentosAgendadosState extends State<AtendimentosAgendados> {
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

  Stream<List<Map<String, dynamic>>> _obterAgendamentosDoUsuario() {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('horarios')
        .where('uidUsuario', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> agendamentos = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('uidTecnico')) {
          String uidTecnico = data['uidTecnico'];
          DocumentSnapshot tecnicoDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uidTecnico)
              .get();

          data['nomeTecnico'] = tecnicoDoc.exists
              ? tecnicoDoc['nome'] ?? 'Nome não encontrado'
              : 'Nome não encontrado';
        }

        // Verifica se o campo 'agendamentoId' está presente e converte para DateTime
        if (data.containsKey('agendamentoId') &&
            data['agendamentoId'] != null) {
          try {
            // Extraímos os milissegundos da string e convertemos para DateTime
            int agendamentoMilissegundos = int.parse(data['agendamentoId']);
            data['horaMarcada'] =
                DateTime.fromMillisecondsSinceEpoch(agendamentoMilissegundos);
          } catch (e) {
            print('Erro ao converter agendamentoId para DateTime: $e');
            data['horaMarcada'] =
                DateTime.now(); // Caso falhe, usa a hora atual
          }
        } else {
          data['horaMarcada'] = DateTime
              .now(); // Se não tiver agendamentoId, define como a hora atual
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
        .where((agendamento) => agendamento['nomeTecnico']
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
          "Histórico de Agendamentos",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.white, // Fundo branco
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Barra de pesquisa com design atualizado
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Pesquisar por técnico",
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
                  stream: _obterAgendamentosDoUsuario(),
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
                          "Nenhum agendamento encontrado.",
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

                        // Definir a cor do card com base no status
                        Color cardColor;
                        String? status = agendamento[
                            'status']; // Assumindo que o campo status existe
                        if (status == 'aceito') {
                          cardColor = Colors.green[100]!;
                        } else if (status == 'recusado') {
                          cardColor = Colors.red[100]!;
                        } else {
                          cardColor = Colors.white; // Branco para status null
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
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

                              // Técnico
                              RichText(
                                text: TextSpan(
                                  text: "Técnico: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: agendamento['nomeTecnico'] ?? 'N/A',
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

                              // Telefone Usado no Contato
                              RichText(
                                text: TextSpan(
                                  text: "Telefone Usado no Contato: ",
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
                                status != null
                                    ? "Status: ${status[0].toUpperCase()}${status.substring(1)}"
                                    : "Status: Aguardando confirmação...",
                                style: TextStyle(
                                  color: status == 'aceito'
                                      ? Colors.green
                                      : status == 'recusado'
                                          ? Colors.red
                                          : Colors
                                              .orange, // Cor laranja para 'aguardando confirmação'
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
