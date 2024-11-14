import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AtendimentosAgendados extends StatelessWidget {
  const AtendimentosAgendados({super.key});

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

  // Função para obter os agendamentos do Firebase
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
          // Busca o nome do técnico na coleção de usuários
          String uidTecnico = data['uidTecnico'];
          DocumentSnapshot tecnicoDoc = await FirebaseFirestore.instance
              .collection('users')  // Alterado para acessar a coleção correta
              .doc(uidTecnico)
              .get();

          if (tecnicoDoc.exists) {
            data['nomeTecnico'] = tecnicoDoc['nome'] ?? 'Nome não encontrado';
          } else {
            data['nomeTecnico'] = 'Nome não encontrado';
          }
        }
        agendamentos.add(data);
      }
      return agendamentos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Histórico de Agendamentos"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _obterAgendamentosDoUsuario(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Nenhum agendamento encontrado."));
                  }

                  final agendamentos = snapshot.data!;

                  return ListView.builder(
                    itemCount: agendamentos.length,
                    itemBuilder: (context, index) {
                      final agendamento = agendamentos[index];

                      // Transformar a data do agendamento
                      String? agendamentoId = agendamento['agendamentoId'];
                      DateTime data;

                      if (agendamentoId != null) {
                        int? timestamp = int.tryParse(agendamentoId);
                        if (timestamp != null && timestamp > 0) {
                          data = DateTime.fromMillisecondsSinceEpoch(timestamp);
                        } else {
                          data = DateTime
                              .now(); // Usar data atual ou outro valor padrão
                        }
                      } else {
                        data = DateTime
                            .now(); // Ou outro valor padrão se agendamentoId for nulo
                      }

                      String dataFormatada =
                          DateFormat('dd/MM/yyyy HH:mm:ss').format(data);

                      return GestureDetector(
                        onTap: () {
                          print(
                              "Agendamento clicado: ${agendamento['tipoAtendimento']}");
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MinhasCores.brancogelo,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nome: ${agendamento['nome'] ?? 'N/A'}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Técnico: ${agendamento['nomeTecnico'] ?? 'N/A'}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tipo de atendimento: ${agendamento['problema'] ?? 'N/A'}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Data: $dataFormatada",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
