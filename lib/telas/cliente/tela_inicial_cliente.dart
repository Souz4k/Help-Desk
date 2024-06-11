import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/AjudaTecnica.dart';
import 'package:app/telas/AtendimentosAgendados.dart';
import 'package:app/telas/HistoricoCliente.dart';
import 'package:app/telas/cliente/agendar_horario.dart';
import 'package:app/telas/cliente/alterar_Info_Cli.dart';
import 'package:app/telas/cliente/geolocalizacao_cli.dart';
import 'package:app/telas/suporte.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/telas/Tela_inicial.dart';

class tela_inicial_cliente extends StatefulWidget {
  tela_inicial_cliente({Key? key});

  @override
  State<tela_inicial_cliente> createState() => _tela_inicial_clienteState();
}

class _tela_inicial_clienteState extends State<tela_inicial_cliente> {
  late User _user;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser!;
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(_user.uid).get();

    if (userDoc.exists && userDoc.data()!.containsKey('fotourl')) {
      setState(() {
        _imageUrl = userDoc['fotourl'];
      });
    }
  }

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
              leading: Icon(Icons.logout),
              title: Text("Deslogar"),
              onTap: () => _deslogar(context),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("informações"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlterarInfoCli()),
                );
              },
            )
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Removido: _pickImageFromCamera(); // Adicione aqui a lógica para selecionar uma imagem da câmera
              },
              child: Align(
                alignment: Alignment.topCenter,
                child:  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: MinhasCores.brancogelo,
                      shape: BoxShape.circle,
                      image: _imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              behavior: HitTestBehavior.translucent, // Adicione esta linha
              onTap: () {
                // Adicione a lógica que deseja quando o círculo é clicado
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelecionarTecnicoScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity, // Preenche toda a largura
                height: 75, // Ajuste a altura conforme necessário
                color: MinhasCores.brancogelo,
                child: Center(
                  child: Text(
                    "Ajuda técnica",
                    style: TextStyle(
                      color: Colors.black, // Cor do texto
                      fontSize: 20, // Tamanho da fonte
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent, // Adicione esta linha
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoricoCliente(),
                  ),
                );
              },
              child: Container(
                width: double.infinity, // Preenche toda a largura
                height: 75, // Ajuste a altura conforme necessário
                margin: EdgeInsets.only(top: 0),
                color: Colors.white,
                child: Center(
                  child: Text(
                    "Histórico de Técnicos",
                    style: TextStyle(
                      color: Colors.black, // Cor do texto
                      fontSize: 20, // Tamanho da fonte
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent, // Adicione esta linha
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AtendimentosAgendados(),
                  ),
                );
              },
              child: Container(
                width: double.infinity, // Preenche toda a largura
                height: 75, // Ajuste a altura conforme necessário
                margin: EdgeInsets.only(top: 0),
                color: MinhasCores.brancogelo,
                child: Center(
                  child: Text(
                    "Atendimentos agendados",
                    style: TextStyle(
                      color: Colors.black, // Cor do texto
                      fontSize: 20, // Tamanho da fonte
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent, // Adicione esta linha
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Suporte(),
                  ),
                );
              },
              child: Container(
                width: double.infinity, // Preenche toda a largura
                height: 75, // Ajuste a altura conforme necessário
                margin: EdgeInsets.only(top: 0),
                color: Colors.white,
                child: Center(
                  child: Text(
                    "Suporte",
                    style: TextStyle(
                      color: Colors.black, // Cor do texto
                      fontSize: 20, // Tamanho da fonte
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent, // Adicione esta linha
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Geolocalizacao(),
                  ),
                );
              },
              child: Container(
                width: double.infinity, // Preenche toda a largura
                height: 75, // Ajuste a altura conforme necessário
                margin: EdgeInsets.only(top: 0),
                color: MinhasCores.brancogelo,
                child: Center(
                  child: Text(
                    "Técnicos em sua região",
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
