import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:flutter/material.dart';

class HistoricoCliente extends StatelessWidget {
  const HistoricoCliente({super.key});

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
            padding: EdgeInsets.only(top: 30),
            child: Text(
              "Historico",
              style: TextStyle(fontSize: 25),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("historico");
              // Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => (),
              //           ),
              // );
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
                          borderRadius: BorderRadius.circular(10)),
                      child: TextButton(
                        onPressed: () {
                          // Lógica para o botão branco aqui
                          print("Botão branco clicado");
                        },
                        child: Text(""),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ), // Espaço entre o botão branco e o texto

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          "Nome:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tipo de atendimento:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("historico");
              // Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => (),
              //           ),
              // );
            },
            child: Container(
              width: double.infinity,
              height: 75,
              margin: const EdgeInsets.only(top: 10),
              color: Colors.white,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          color: MinhasCores.brancogelo,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextButton(
                        onPressed: () {
                          // Lógica para o botão branco aqui
                          print("Botão branco clicado");
                        },
                        child: Text(""),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ), // Espaço entre o botão branco e o texto

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          "Nome:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tipo de atendimento:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("historico");
              // Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => (),
              //           ),
              // );
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
                          borderRadius: BorderRadius.circular(10)),
                      child: TextButton(
                        onPressed: () {
                          // Lógica para o botão branco aqui
                          print("Botão branco clicado");
                        },
                        child: Text(""),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ), // Espaço entre o botão branco e o texto

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          "Nome:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tipo de atendimento:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
