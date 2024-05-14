import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:app/telas/chamarTecnico.dart';
import 'package:flutter/material.dart';

class AjudaTecnica extends StatelessWidget {
  const AjudaTecnica({super.key});

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
      body: Stack(
        children: [
          Container(
              // decoração
              ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  const Text(
                    "Chamar um Técnico",
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                    ), // Ajuste o valor conforme necessário
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200, // Ajuste o valor conforme necessário
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChamarTecnico(),
                          ),
                        );
                      },
                      child: Image.asset("assets/iconeTecnico.png"),
                    ),
                  ),
                  const Text(
                    "ou",
                    style: TextStyle(
                      fontSize: 35,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ), // Ajuste o valor conforme necessário
                  InkWell(
                    // onTap: () {
                    //   Navigator.push(
                    //     // context,
                    //     // // MaterialPageRoute(
                    //     // //   // builder: (context) => LoginTecnico(),
                    //     // // ),
                    //   );
                    // },
                    child: Container(
                      height: 200, // Ajuste o valor conforme necessário
                      child: Image.asset("assets/iconeferramenta.png"),
                    ),
                  ),
                  const Text(
                    "faça você mesmo",
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.5,
                    ), // Ajuste o valor conforme necessário
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
