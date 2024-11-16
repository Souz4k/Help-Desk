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
          // Fundo azul
          Container(
            color: Colors.blueAccent,
          ),
          // Conteúdo da página centralizado
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícone no topo
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.support_agent,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Texto de boas-vindas
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Bem-vindo ao ",
                          style: GoogleFonts.lato(
                            fontSize: 26,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "Help Desk",
                          style: GoogleFonts.lato(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Subtítulo explicativo
                  Text(
                    "Conecte-se rapidamente com técnicos especializados\nem tecnologia da informação.",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Botão estilizado
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Continuar',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Texto de rodapé
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
