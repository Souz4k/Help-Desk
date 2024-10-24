import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/telas/Login.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Novo fundo com overlay escurecido
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundoBem-vindo.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          // Conteúdo da página centralizado
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centraliza verticalmente
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centraliza horizontalmente
                children: [
                  // Texto de boas-vindas centralizado
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Bem-Vindo ao ",
                          style: GoogleFonts.lato(
                            fontSize: 28,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "Help Desk",
                          style: GoogleFonts.lato(
                            fontSize: 28,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16), // Espaço entre os textos
                  Text(
                    "Seu app de serviço de TI",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60), // Espaço menor antes do botão
                  // Botão centralizado
                  SizedBox(
                    width: 200, // Define uma largura fixa para o botão
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.lightBlueAccent, // A cor do botão
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Bordas arredondadas
                        ),
                      ),
                      child: Text(
                        'Continuar',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
