import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Localizacao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Variáveis para o mapa
  final Map<String, Marker> markers = {};
  GoogleMapController? _controller;
  final LatLng _center = LatLng(0, 0); // Posição inicial do mapa

  // Função para pegar a localização do usuário
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Checa se o GPS está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Checa a permição de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    // Pega a localização
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  // Função para adicionar o marcador no mapa
  void _addMarker(LatLng position) => setState(() {
        markers['userLocation'] = Marker(
          markerId: MarkerId('userLocation'),
          position: position,
          infoWindow: InfoWindow(title: 'Your Location'),
        );
      });



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
      body: FutureBuilder<Position>(
        future: _determinePosition(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Define o centro do mapa de acordo com a localização do usuário
            final userLocation =
                LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => _addMarker(userLocation)); // Wrap in post frame callback

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLocation,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              markers: Set<Marker>.of(markers.values),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}