import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/localizacao.dart';
import 'package:app/telas/cliente/tela_inicial_cliente.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Geolocalizacao extends StatefulWidget {
  const Geolocalizacao({super.key});

  @override
  State<Geolocalizacao> createState() => _GeolocalizacaoState();
}

class _GeolocalizacaoState extends State<Geolocalizacao> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0 && _selectedIndex != 0) {
        Navigator.pop(context); // Navega para a tela anterior
      } else {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MinhasCores.brancogelo,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Voltar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Técnicos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Locais',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  

  static List<Widget> _widgetOptions = <Widget>[
    Text(
        'Voltar'), // Substitua este Text() pelo conteúdo da sua primeira página
    Localizacao(),
 // Substitua este Text() pelo conteúdo da sua segunda página
    Text(
        'Página 3'), // Substitua este Text() pelo conteúdo da sua terceira página
  ];
}

