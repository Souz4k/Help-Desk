import 'dart:math';
import 'package:app/_comum/minhas_cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Geolocalizacao extends StatefulWidget {
  const Geolocalizacao({super.key});

  @override
  State<Geolocalizacao> createState() => _GeolocalizacaoState();
}

class _GeolocalizacaoState extends State<Geolocalizacao> {
  int _selectedIndex = 1;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determineAndSavePosition();
  }

  Future<void> _determineAndSavePosition() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _currentPosition = position;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        }, SetOptions(merge: true));

        // Carregar todas as localizações dos técnicos
        await _loadTechniciansLocations();
      }
    } catch (e) {
      print('Erro ao determinar e salvar a posição: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviços de localização desativados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissões de localização negadas.');
      }
    } else if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Permissões de localização permanentemente negadas.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<void> _loadTechniciansLocations() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final technicians = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['userType'] == 'tecnico' &&
          data['location'] != null &&
          data['location']['latitude'] != null &&
          data['location']['longitude'] != null;
    });

    setState(() {
      _markers.clear();
      for (var tech in technicians) {
        final data = tech.data();
        final location = data['location'];
        _addMarker(
          LatLng(location['latitude'], location['longitude']),
          tech.id,
          data['name'] ?? 'Sem Nome',
        );
      }
    });
  }

  void _addMarker(LatLng position, String id, String title) {
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: position,
        infoWindow: InfoWindow(title: title),
      ),
    );
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          12,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _determineAndSavePosition();
        return true;
      },
      child: Scaffold(
        body: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: MinhasCores.brancogelo,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Voltar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configurações',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  static List<Widget> _widgetOptions = <Widget>[
    Text('Voltar'),
    LocalizacaoMapa(),
    Text('Configurações'),
  ];
}

class LocalizacaoMapa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_GeolocalizacaoState>();
    if (state?._isLoading ?? true) {
      return Center(child: CircularProgressIndicator());
    }
    if (state?._currentPosition == null) {
      return Center(child: Text('Erro ao obter a posição'));
    }
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        state?._onMapCreated(controller);
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(state!._currentPosition!.latitude,
            state._currentPosition!.longitude),
        zoom: 12,
      ),
      markers: state._markers,
    );
  }
}
