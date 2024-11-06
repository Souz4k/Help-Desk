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
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MinhasCores.azulEscuro,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Deslogar"),
              onTap: () => _deslogar(context),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              "Histórico de Agendamentos",
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _obterAgendamentosDoUsuario(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhum agendamento encontrado."));
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
                        data = DateTime.now(); // Usar data atual ou outro valor padrão
                      }
                    } else {
                      data = DateTime.now(); // Ou outro valor padrão se agendamentoId for nulo
                    }

                    String dataFormatada = DateFormat('dd/MM/yyyy HH:mm:ss').format(data);

                    return GestureDetector(
                      onTap: () {
                        print("Agendamento clicado: ${agendamento['tipoAtendimento']}");
                      },
                      child: Container(
                        width: double.infinity,
                        height: 75,
                        margin: const EdgeInsets.only(top: 10),
                        color: MinhasCores.brancogelo,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.event),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Nome: ${agendamento['nome'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "Tipo de atendimento: ${agendamento['problema'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "Data: $dataFormatada",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
    );
  }
}
