import 'package:flutter/material.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/telas/Tela_inicial.dart';

class tela_inicial_tecnico extends StatelessWidget {
  const tela_inicial_tecnico({super.key});

  Future<void> _deslogar(BuildContext context) async {
    try {
      await AutenticacaoServico().deslogar();
      // Navegue de volta para a tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaInicial()),
      );
    } catch (e) {
      // Trate o erro, se necessário
      print("Erro ao deslogar: $e");
      mostrarSnackBar(context: context, texto: "Erro ao deslogar");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MinhasCores.azulEscuro,
        automaticallyImplyLeading: false, // Define para não mostrar a seta
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
    );
  }
}
