import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AtendimentosAgendadosTecnico extends StatefulWidget {
  const AtendimentosAgendadosTecnico({Key? key}) : super(key: key);

  @override
  _AtendimentosAgendadosTecnicoState createState() =>
      _AtendimentosAgendadosTecnicoState();
}

class _AtendimentosAgendadosTecnicoState
    extends State<AtendimentosAgendadosTecnico> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? uidTecnico;

  @override
  void initState() {
    super.initState();
    _obterUidTecnico();
  }

  Future<void> _obterUidTecnico() async {
    final user = await AutenticacaoServico().obterUsuarioAtual();
    setState(() {
      uidTecnico = user?.uid;
    });
  }

  Future<void> _atualizarStatus(String horarioId, String novoStatus) async {
    try {
      final docRef = _firestore.collection('horarios').doc(horarioId);

      if (novoStatus == 'recusado') {
        // Atualiza o status e torna o horário disponível novamente
        await docRef.update({
          'status': novoStatus,
          'disponivel': true,
          'nome': FieldValue.delete(),
          'problema': FieldValue.delete(),
          'hora': FieldValue.delete(),
          'uidUsuario': FieldValue.delete(),
        });
      } else {
        // Apenas atualiza o status para aceito
        await docRef.update({'status': novoStatus});
      }

      mostrarSnackBar(
        context: context,
        texto: 'Status atualizado para $novoStatus',
      );
      setState(() {}); // Recarrega a página após atualizar o status
    } catch (e) {
      mostrarSnackBar(
        context: context,
        texto: 'Erro ao atualizar status: $e',
        cor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uidTecnico == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atendimentos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('horarios')
            .where('uidTecnico', isEqualTo: uidTecnico)
            .where('disponivel', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar atendimentos.'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum atendimento encontrado.'),
            );
          }

          final atendimentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: atendimentos.length,
            itemBuilder: (context, index) {
              final atendimento = atendimentos[index];
              final Map<String, dynamic> dados =
                  atendimento.data() as Map<String, dynamic>;
              final String horarioId = atendimento.id;
              final String clienteNome =
                  dados['nome'] ?? 'Cliente não informado';
              final String problema = dados['problema'] ?? 'Sem descrição';
              final String hora = dados['hora'] != null
                  ? dados['hora'].toString()
                  : 'Sem horário';
              final String status = dados['status'] ?? 'Indefinido';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: status == 'aceito'
                    ? Colors.lightGreenAccent
                    : Colors.white, // Fundo verde claro para aceitos
                child: ListTile(
                  title: Text(clienteNome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Problema: $problema'),
                      Text('Horário: $hora'),
                      Text('Status: $status'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status !=
                          'aceito') // Exibe apenas se ainda não foi aceito
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _atualizarStatus(horarioId, 'aceito');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          _atualizarStatus(horarioId, 'recusado');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
