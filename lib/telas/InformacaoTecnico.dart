import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/AgendarHorario.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:flutter/material.dart';

class informacaoTecnico extends StatelessWidget {
  const informacaoTecnico({super.key});

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
            GestureDetector(
              onTap: () {
                // Adicione a lógica que deseja quando o círculo é clicado
                print("Quadrado circular foi clicado");
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 150,
                  height: 150,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: MinhasCores.brancogelo,
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(-80.0, -10.0), // Ajuste a posição vertical aqui
              child: const Text(
                "Avaliação:",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center, // ou TextAlign.left, TextAlign.right
              ),
            ),
            Container(
              width: double.infinity,
              height: 125,
              margin: const EdgeInsets.only(top: 0),
              color: MinhasCores.brancogelo,
              child: const Padding(
                padding: EdgeInsets.only(
                    left: 15, top: 20), // Ajuste o espaçamento interno aqui
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "nome:",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20), // Espaçamento entre os textos
                    Text(
                      "Distância:",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent, // Adicione esta linha
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgendarHorariro(),
                  ),
                );
                // Adicione a lógica que deseja quando o círculo é clicado
              },
              child: Container(
                width: double.infinity, // Preenche toda a largura
                height: 75, // Ajuste a altura conforme necessário
                margin: const EdgeInsets.only(top: 0),
                color: MinhasCores.brancogelo,
                child: const Center(
                  child: Text(
                    "Agendar Horario",
                    style: TextStyle(
                      color: Colors.black, // Cor do texto
                      fontSize: 20, // Tamanho da fonte
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, 10.0), // Ajuste a posição vertical aqui
              child: const Text(
                "Comentarios",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center, // ou TextAlign.left, TextAlign.right
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              height: 70,
              margin: const EdgeInsets.only(top: 0),
              color: MinhasCores.brancogelo,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            10), // Metade da largura ou altura para obter um círculo
                        color: Colors.white,
                      ),
                    ),
        
                    const SizedBox(
                        width:
                            10), // Adiciona um espaçamento entre o Container e o texto
                    const Text(
                      "nome:",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
