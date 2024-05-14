import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/AjudaTecnica.dart';
import 'package:app/telas/AtendimentosAgendados.dart';
import 'package:app/telas/HistoricoCliente.dart';
import 'package:app/telas/cliente/alterar_Info_Cli.dart';
import 'package:app/telas/cliente/geolocalizacao_cli.dart';
import 'package:app/telas/suporte.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/telas/Tela_inicial.dart';

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';

class tela_inicial_cliente extends StatefulWidget {
  tela_inicial_cliente({Key? key});

  @override
  State<tela_inicial_cliente> createState() => _tela_inicial_clienteState();
}

class _tela_inicial_clienteState extends State<tela_inicial_cliente> {
  File? _selectedImgae;

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
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              _pickImageFromCamera(); // Adicione aqui a lógica para selecionar uma imagem da câmera
            },
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                  width: 150,
                  height: 150,
                  margin: EdgeInsets.only(bottom: 100, top: 50, left: 10),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: MinhasCores.brancogelo,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: _selectedImgae != null
                      ? AspectRatio(
                          aspectRatio:
                              1, // Garante que a imagem mantenha a proporção
                          child: ClipOval(
                            child: Image.file(
                              _selectedImgae!,
                              fit: BoxFit
                                  .cover, // Ajusta a imagem ao círculo sem distorcer
                            ),
                          ),
                        )
                      : const Icon(Icons.camera_outlined)),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent, // Adicione esta linha
            onTap: () {
              // Adicione a lógica que deseja quando o círculo é clicado
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AjudaTecnica(),
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
      ), // ou qualquer outro widget que você queira exibir
    );
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    //Esse if é responsavel para se o usuario não selecionar uma imagem ele voutar para a tela anterior e não para uma tela em preto
    if (returnedImage == null) return;
    setState(() {
      _selectedImgae = File(returnedImage.path);
    });

    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();

// Create a reference to 'images/mountains.jpg'
    final imageref =
        storageRef.child("${FirebaseAuth.instance.currentUser!.email}.jpg");
    await imageref.putFile(
      File(returnedImage.path),
    );
    var url = await imageref.getDownloadURL();
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({"fotourl": url});
  }
}
