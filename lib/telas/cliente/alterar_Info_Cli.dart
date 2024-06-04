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
  late TextEditingController _senhaAtualController; // Senha antiga
  late TextEditingController _novaSenhaController;
  late TextEditingController _celularController;
  User? _user;
  String? _nomeAtual;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _nomeAtual = _user?.displayName;
    _nomeController = TextEditingController(text: _nomeAtual);
    _senhaAtualController = TextEditingController(); // Inicialize o controlador para a senha antiga
    _novaSenhaController = TextEditingController();
    _celularController = TextEditingController();
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
      String newName, String oldPassword, String newSenha, String celular) async {
    try {
      if (_user != null) {
        // Autenticar o usuário novamente com a senha antiga para garantir sua validade
        var credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: oldPassword,
        );
        await _user!.reauthenticateWithCredential(credential);

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

        if (updateData.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.email)
              .set(
                  updateData,
                  SetOptions(
                      merge:
                          true)); 
        }

        final snackBar = SnackBar(
          content: Text(
            "Informações atualizadas com sucesso",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
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
        backgroundColor: Colors.red,
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
                controller: _senhaAtualController, // Campo para a senha antiga
                decoration: getAutenticationInputDecoration("Senha Antiga"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _novaSenhaController,
                decoration: getAutenticationInputDecoration("Nova Senha"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "A senha não pode ser vazia";
                  }
                  if (value.length < 6) {
                    return "A senha é muito curta";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _celularController,
                decoration: getAutenticationInputDecoration("Número de Celular"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _atualizarInformacoes(
                    _nomeController.text,
                    _senhaAtualController.text,
                    _novaSenhaController.text,
                    _celularController.text,
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
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _celularController.dispose();
    super.dispose();
  }
}
