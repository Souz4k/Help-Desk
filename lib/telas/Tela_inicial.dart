import 'package:app/telas/Login.dart';
import 'package:flutter/material.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundoBem-vindo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Bem-Vindo ao ",
                          style: TextStyle(
                            fontSize: 32,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "Help Desk",
                          style: TextStyle(
                            fontSize: 32,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // Espaço entre os textos
                  const Text(
                    "Seu app de serviço de TI",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 100),
                  Column(
                    children: [
                      Container(
                        height: 40, // Ajuste o valor conforme necessário
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Login()), // Página de login
                            );
                          },
                          child: const Text('Continuar'),
                        ),
                      ),
                    ],
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
