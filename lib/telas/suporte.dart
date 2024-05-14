import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:flutter/material.dart';

class Suporte extends StatelessWidget {
  const Suporte({super.key});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Adicione aqui a lógica para voltar à tela anterior
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
            padding: EdgeInsets.only(top: 40),
            child: Text(
              "Suporte",
              style: TextStyle(fontSize: 30),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent, // Adicione esta linha
            onTap: () {
             print("Problemas Enviados");
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => AjudaTecnica(),
              //   ),
              // );
            },
           child: Container(
            width: double.infinity,
            height: 75,
            margin: const EdgeInsets.only(top: 60),
            color: MinhasCores.brancogelo,
            child: const Padding(
              padding: EdgeInsets.only(left: 60, top: 15),
              child: Text(
                "Problemas enviados",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
