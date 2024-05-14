import 'package:app/componentes/decoracao_campo_autenticacao.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o pacote Firestore
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';

class AlterarInfoCli extends StatefulWidget {
  const AlterarInfoCli({Key? key});

  @override
  _AlterarInfoCliState createState() => _AlterarInfoCliState();
}

class _AlterarInfoCliState extends State<AlterarInfoCli> {
  late TextEditingController _nomeController;
  late TextEditingController _senhaController;
  late TextEditingController
      _celularController; // Novo controlador para o número de celular
  late TextEditingController
      _anydeskController; // Novo controlador para o código do Anydesk
  User? _user;
  String? _nomeAtual;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _nomeAtual = _user?.displayName;
    _nomeController = TextEditingController(text: _nomeAtual);
    _senhaController = TextEditingController();
    _celularController =
        TextEditingController(); // Inicialize o novo controlador
    _anydeskController =
        TextEditingController(); // Inicialize o novo controlador
  }

  Future<void> _deslogar(BuildContext context) async {
    try {
      await AutenticacaoServico().deslogar();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaInicial()),
      );
    } catch (e) {
      print("Erro ao deslogar: $e");
      mostrarSnackBar(context: context, texto: "Erro ao deslogar");
    }
  }

  Future<void> _atualizarInformacoes(
      String newName, String newSenha, String celular, String anydesk) async {
    try {
      if (_user != null) {
        if (newName.isNotEmpty && newName != _nomeAtual) {
          await _user!.updateDisplayName(newName);
          _nomeAtual = newName;
        }
        if (newSenha.isNotEmpty) {
          await _user!.updatePassword(newSenha);
        }

        Map<String, String> updateData = {};
        if (celular.isNotEmpty) {
          updateData['celular'] = celular;
        }
        if (anydesk.isNotEmpty) {
          updateData['anydesk'] = anydesk;
        }

        if (updateData.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users') // Coleção no Firestore
              .doc(_user!.email) // Documento do usuário atual
              .set(
                  updateData,
                  SetOptions(
                      merge:
                          true)); // Use merge para não substituir todos os dados
        }

        final snackBar = SnackBar(
          content: Text(
            "Informações atualizadas com sucesso",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green, // Cor de fundo verde
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print("Erro ao atualizar informações: $e");
      final snackBar = SnackBar(
        content: Text(
          "Erro ao atualizar informações",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red, // Cor de fundo vermelha para indicar erro
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              leading: Icon(Icons.logout),
              title: Text("Deslogar"),
              onTap: () => _deslogar(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: MinhasCores.brancogelo,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              SizedBox(height: 60),
              TextFormField(
                controller: _nomeController,
                decoration: getAutenticationInputDecoration("Nome"),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _senhaController,
                decoration: getAutenticationInputDecoration("Nova Senha"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    // Verifica se o valor é nulo ou vazio
                    return "A senha não pode ser vazia";
                  }
                  if (value.length < 6) {
                    // Verifica se o comprimento da senha é menor que 6
                    return "A senha é muito curta";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _celularController,
                decoration:
                    getAutenticationInputDecoration("Número de Celular"),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _anydeskController,
                decoration:
                    getAutenticationInputDecoration("Código do Anydesk"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _atualizarInformacoes(
                    _nomeController.text,
                    _senhaController.text,
                    _celularController.text,
                    _anydeskController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: MinhasCores.azulEscuro,
                ),
                child: Text("Atualizar Informações",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    _celularController.dispose(); // Dispose do controlador do número de celular
    _anydeskController.dispose(); // Dispose do controlador do código do Anydesk
    super.dispose();
  }
}
