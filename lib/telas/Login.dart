import 'package:flutter/material.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/componentes/decoracao_campo_autenticacao.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import "package:app/telas/cliente/tela_inicial_cliente.dart";
import 'package:app/telas/tecnico/tela_inicial_tecnico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum TipoUsuario { cliente, tecnico }

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool queroEntrar = true;
  bool _erroNoTextField = false;
  bool _isLoading = false;

  final _formkey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  TextEditingController _confirmarsenhaController = TextEditingController();
  TextEditingController _nomeController = TextEditingController();

  AutenticacaoServico _autenticacaoServico = AutenticacaoServico();

  TipoUsuario _tipoUsuarioSelecionado = TipoUsuario.cliente;

  double getContainerHeight() {
    if (queroEntrar) {
      return _erroNoTextField ? 320.0 : 270.0;
    } else {
      return _erroNoTextField ? 530.0 : 430.0;
    }
  }

  void _aumentarTamanhoContainer() {
    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
      setState(() {
        _erroNoTextField = false;
      });
    } else {
      setState(() {
        _erroNoTextField = true;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      mostrarSnackBar(context: context, texto: message);
    }
  }

  void _navigateToNextScreen(Widget screen) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 68, 138, 225), // Cor de fundo clara e limpa
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(
              key: _formkey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, // Caixa branca elegante
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      queroEntrar ? 'Login' : 'Cadastrar-se',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!queroEntrar) ...[
                      DropdownButtonFormField<TipoUsuario>(
                        value: _tipoUsuarioSelecionado,
                        items: [
                          DropdownMenuItem(
                            value: TipoUsuario.cliente,
                            child: Text('Cliente'),
                          ),
                          DropdownMenuItem(
                            value: TipoUsuario.tecnico,
                            child: Text('Técnico'),
                          ),
                        ],
                        onChanged: (TipoUsuario? value) {
                          setState(() {
                            _tipoUsuarioSelecionado = value!;
                          });
                        },
                        decoration:
                            getAutenticationInputDecoration("Tipo de Usuário"),
                      ),
                    ],
                    const SizedBox(height: 10),
                    for (int i = 0; i < 2 + (queroEntrar ? 0 : 2); i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: i == 0
                              ? _emailController
                              : i == 1
                                  ? _senhaController
                                  : i == 2
                                      ? _confirmarsenhaController
                                      : _nomeController,
                          onTap: () {
                            _scrollToPosition(i + 1);
                          },
                          decoration: getAutenticationInputDecoration(
                            i == 0
                                ? "E-mail"
                                : i == 1
                                    ? "Senha"
                                    : i == 2
                                        ? "Confirmar Senha"
                                        : "Nome",
                          ),
                          obscureText: i == 1 || i == 2,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return i == 0
                                  ? "O e-mail não pode ser vazio"
                                  : i == 1
                                      ? "A senha não pode ser vazia"
                                      : i == 2
                                          ? "A confirmação de senha não pode ser vazia"
                                          : "O nome não pode ser vazio";
                            }
                            if (value.length < 5) {
                              return i == 0
                                  ? "O e-mail é muito curto"
                                  : i == 1
                                      ? "A senha é muito curta"
                                      : i == 2
                                          ? "A confirmação de senha é muito curta"
                                          : "O nome é muito curto";
                            }
                            if (i == 0 && !value.contains("@")) {
                              return "O e-mail não é válido";
                            }
                            return null;
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: () {
                          _aumentarTamanhoContainer();
                          botaoDeLogar();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          queroEntrar ? 'Entrar' : 'Cadastrar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _formkey.currentState?.reset();
                          queroEntrar = !queroEntrar;
                          _erroNoTextField = false;
                        });
                      },
                      child: Text(
                        queroEntrar ? "Cadastrar-se" : "Login",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> botaoDeLogar() async {
    String nome = _nomeController.text;
    String senha = _senhaController.text;
    String confirmarSenha = _confirmarsenhaController.text;
    String email = _emailController.text;

    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (queroEntrar) {
          await _autenticacaoServico.logarUsuario(email: email, senha: senha);
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            String uid = user.uid;
            try {
              DocumentSnapshot doc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();
              if (doc.exists) {
                String userType = doc.get(
                    'userType'); // Utilizando `doc.get` para obter o campo userType
                if (userType == 'cliente') {
                  _navigateToNextScreen(telaInicialCliente());
                } else if (userType == 'tecnico') {
                  _navigateToNextScreen(Tela_inicial_tecnico());
                } else {
                  _showSnackBar("Tipo de usuário inválido");
                }
              } else {
                _showSnackBar("Usuário não encontrado");
              }
            } catch (e) {
              _showSnackBar(
                  "Erro ao recuperar documento do Firestore: ${e.toString()}");
            }
          } else {
            _showSnackBar("Erro ao recuperar usuário logado");
          }
        } else {
          await _autenticacaoServico.cadastrarUsuario(
            nome: nome,
            senha: senha,
            confirmarSenha: confirmarSenha,
            email: email,
          );
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            String uid = user.uid;
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'userType': _tipoUsuarioSelecionado == TipoUsuario.cliente
                  ? 'cliente'
                  : 'tecnico',
              'nome': nome,
            });
            if (_tipoUsuarioSelecionado == TipoUsuario.cliente) {
              _navigateToNextScreen(telaInicialCliente());
            } else {
              _navigateToNextScreen(Tela_inicial_tecnico());
            }
          } else {
            _showSnackBar("Erro ao recuperar usuário logado");
          }
        }
      } catch (e) {
        _showSnackBar("Erro: ${e.toString()}");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print("Formulário inválido");
    }
  }

  void _scrollToPosition(int position) {
    _scrollController.animateTo(
      position * 70.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
