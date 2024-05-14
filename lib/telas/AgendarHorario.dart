import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Escolher_atendimento.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:flutter/material.dart';

class AgendarHorariro extends StatefulWidget {
  const AgendarHorariro({super.key});

  @override
  State<AgendarHorariro> createState() => _AgendarHorariroState();
}

class _AgendarHorariroState extends State<AgendarHorariro> {
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
              padding: EdgeInsets.only(left: 0.0), // Ajuste conforme necessário
              child: Text(
                "Técnicos da sua região",
                style: TextStyle(
                  fontSize: 25,
                  height: 5,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 0.0), // Ajuste conforme necessário
              child: Text(
                "Presencial",
                style: TextStyle(
                  fontSize: 20,
                  height: -1,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              width: double.infinity,
              height: 75,
              color: MinhasCores.brancogelo,
              child: const Padding(
                padding: EdgeInsets.only(
                    left: 15, top: 6), // Ajuste o espaçamento interno aqui
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Preço para atendimento",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 70), // Espaçamento entre os textos
                        Text(
                          "R\$:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4), // Espaçamento entre os textos
                    Row(
                      children: [
                        Text(
                          "Preço por tempo extra",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 85),
                        Text(
                          "R\$:",
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
            const Padding(
              padding: EdgeInsets.only(left: 0.0), // Ajuste conforme necessário
              child: Text(
                "Remoto",
                style: TextStyle(
                  fontSize: 20,
                  height: 3,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 75,
              color: MinhasCores.brancogelo,
              child: const Padding(
                padding: EdgeInsets.only(
                    left: 15, top: 6), // Ajuste o espaçamento interno aqui
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Preço para atendimento",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 70), // Espaçamento entre os textos
                        Text(
                          "R\$:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4), // Espaçamento entre os textos
                    Row(
                      children: [
                        Text(
                          "Preço por tempo extra",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 85),
                        Text(
                          "R\$:",
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
            const Padding(
              padding: EdgeInsets.only(left: 0.0), // Ajuste conforme necessário
              child: Text(
                "Detalhes",
                style: TextStyle(
                  fontSize: 25,
                  height: 3,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 250,
              color: MinhasCores.brancogelo,
              child: const Text("O tempo padrão de atendimento é de 1 hora, podendo ser estendido caso não haja pessoas com horário marcado. O tempo extra acrescenta mais 30 minutos, podendo ser agendado previamente. Por exemplo: agendar um horário de 3 horas, irá somar o preço de um atendimento de 1 hora mais o preço de 2 horas de tempo extra, o agendamento pode ser cancelado, porém se for cancelado a menos de 3 dias do atendimento terá que pagar uma multa de 10% do valor do atendimento. ",
              style: TextStyle(
                fontSize: 16,
              ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent, // Adicione esta linha
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EscolhaAtendimento(),
                  ),
                );
                // Adicione a lógica que deseja quando o círculo é clicado
              },
              child: Container(
                width: 100, // Preenche toda a largura
                height: 50, // Ajuste a altura conforme necessário
                margin: const EdgeInsets.only(top: 50, bottom: 35),
                decoration: BoxDecoration(
                  color: MinhasCores.brancogelo,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    "Agendar",
                    style: TextStyle(
                      color: Colors.black, // Cor do texto
                      fontSize: 20, // Tamanho da fonte
                    ),
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
