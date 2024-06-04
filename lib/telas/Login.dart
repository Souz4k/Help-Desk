import 'package:app/telas/tecnico/tela_inicial_tecnico.dart';
import 'package:flutter/material.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/componentes/decoracao_campo_autenticacao.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/cliente/tela_inicial_cliente.dart';
import 'package:app/telas/tecnico/tela_inicial_tecnico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoUsuario { cliente, tecnico }

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool queroEntrar = true;
  bool _erroNoTextField = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: ClampingScrollPhysics(),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fundo.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formkey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Container(
                  width: 225,
                  height: getContainerHeight(),
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: MinhasCores.cinza,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          decoration: getAutenticationInputDecoration(
                              "Cliente" "Técnico"),
                        ),
                      ],
                      const SizedBox(
                        height: 10,
                      ),
                      for (int i = 0; i < 2 + (queroEntrar ? 0 : 2); i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
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
                              if (value == null) {
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
                                return "O e-mail não é valido";
                              }
                              return null;
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            _aumentarTamanhoContainer();
                            botaoDeLogar();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: MinhasCores.azulEscuro,
                            side: const BorderSide(
                                color: Colors.black, width: 3.0),
                            minimumSize: const Size(75, 25),
                            padding: EdgeInsets.zero,
                          ),
                          child: Container(
                            width: 75,
                            height: 25,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/setaDireita.png",
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _formkey.currentState?.reset();
                            queroEntrar = !queroEntrar;
                            _erroNoTextField =
                                false; // Redefine _erroNoTextField ao alternar entre Login e Cadastrar-se
                          });
                        },
                        child: Text(
                          queroEntrar ? "Cadastrar-se" : "Login",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                        thickness: 1.5,
                        height: 0,
                        indent: 50,
                        endIndent: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  botaoDeLogar() {
    String nome = _nomeController.text;
    String senha = _senhaController.text;
    String confirmarSenha = _confirmarsenhaController.text;
    String email = _emailController.text;
    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
      if (queroEntrar) {
        print("Entrada Validada");
        _autenticacaoServico
            .logarUsuario(
          email: email,
          senha: senha,
        )
            .then(
          (String? erro) {
            if (erro == null) {
              // Login bem-sucedido, recupera o tipo de usuário do Firestore
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(email)
                  .get()
                  .then((DocumentSnapshot doc) {
                if (doc.exists) {
                  String userType = doc['userType'];
                  if (userType == 'cliente') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => tela_inicial_cliente(),
                      ),
                    );
                  } else if (userType == 'tecnico') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Tela_inicial_tecnico(),
                      ),
                    );
                  }
                } else {
                  // Se o documento não existir, mostra uma mensagem de erro
                  mostrarSnackBar(
                      context: context, texto: "Usuário não encontrado");
                }
              });
            } else {
              // Mostra mensagem de erro
              mostrarSnackBar(context: context, texto: erro);
            }
          },
        );
      } else {
        print("Cadastro Validado");
        _autenticacaoServico
            .cadastrarUsuario(
                nome: nome,
                senha: senha,
                confirmarSenha: confirmarSenha,
                email: email)
            .then(
          (String? erro) {
            if (erro != null) {
              // voltou com erro
              mostrarSnackBar(context: context, texto: erro);
            } else {
              // Cadastro bem-sucedido, salva o tipo de usuário no Firestore
              FirebaseFirestore.instance.collection('users').doc(email).set({
                'userType': _tipoUsuarioSelecionado == TipoUsuario.cliente
                    ? 'cliente'
                    : 'tecnico',
              }).then((_) {
                // Navega para a tela apropriada após o cadastro bem-sucedido
                if (_tipoUsuarioSelecionado == TipoUsuario.cliente) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => tela_inicial_cliente(),
                    ),
                  );
                } else {
                  // Navega para a tela do técnico
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Tela_inicial_tecnico(),
                    ),
                  );
                }
              }).catchError((error) {
                // Trata erros ao salvar no Firestore
                print("Erro ao salvar no Firestore: $error");
                mostrarSnackBar(
                    context: context,
                    texto: "Erro ao salvar no Firestore, tente novamente.");
              });
            }
          },
        );
      }
      // Adicione aqui qualquer lógica adicional necessária após a validação do formulário
    } else {
      print("Formulário inválido");
      // Adicione aqui qualquer lógica para lidar com o formulário inválido, se necessário
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
