import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/AjudaTecnica.dart';
import 'package:app/telas/InformacaoTecnico.dart';
import 'package:flutter/material.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/telas/Tela_inicial.dart';

class ChamarTecnico extends StatefulWidget {
  const ChamarTecnico({Key? key});

  @override
  State<ChamarTecnico> createState() => _ChamarTecnicoState();
}

class _ChamarTecnicoState extends State<ChamarTecnico> {
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
          icon: Icon(Icons.arrow_back),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Técnicos da sua região",
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => informacaoTecnico(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 75,
                margin: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  color: MinhasCores.brancogelo,
                  border: Border(
                    top: BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
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
                          SizedBox(height: 8),
                          Text(
                            "Nome:",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Avaliação:",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
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
                print("tecnico selecionado");
                // Adicione a lógica desejada para o gesto aqui
              },
              child: Container(
                width: double.infinity,
                height: 75,
                decoration: const BoxDecoration(
                  color: MinhasCores.brancogelo,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
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
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Avaliação:",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
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
      ),
    );
  }
}
