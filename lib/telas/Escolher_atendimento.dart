import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/AgendarHorario.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:flutter/material.dart';

class EscolhaAtendimento extends StatelessWidget {
  const EscolhaAtendimento({Key? key});

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 6.0), // Ajuste conforme necessário
              child: Text(
                "Opção de agendamento",
                style: TextStyle(
                  fontSize: 25,
                  height: 5,
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent, // Adicione esta linha
              onTap: () {
                print("Presencial");
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => AgendarHorario(),
                //   ),
                // );
                // Adicione a lógica que deseja quando o círculo é clicado
              },
              child: Container(
                width: double.infinity, // Preenche toda a largura
                height: 125, // Ajuste a altura conforme necessário
                margin: const EdgeInsets.only(top: 0),
                color: MinhasCores.brancogelo,
                child: const Center(
                  child: Text(
                    "Presencial",
                    style: TextStyle(
                      color: Colors.black, // Cor do texto
                      fontSize: 20, // Tamanho da fonte
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 150,
            ),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent, // Adicione esta linha
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => AgendarRemoto(),
            //       ),
            //     );
            //     //Adicione a lógica que deseja quando o círculo é clicado
            //   },
            //   child: Container(
            //     width: double.infinity, // Preenche toda a largura
            //     height: 125, // Ajuste a altura conforme necessário
            //     margin: const EdgeInsets.only(top: 0),
            //     color: MinhasCores.brancogelo,
            //     child: const Center(
            //       child: Text(
            //         "Remoto",
            //         style: TextStyle(
            //           color: Colors.black, // Cor do texto
            //           fontSize: 20, // Tamanho da fonte
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
