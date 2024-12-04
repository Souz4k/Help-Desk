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
  String _userType = '';

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
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        String userType =
            userSnapshot.exists ? userSnapshot.get('userType') : 'tecnico';
        setState(() {
          _userType = userType;
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          'userType': userType,
          'name': user.displayName ?? 'Sem Nome',
        }, SetOptions(merge: true));

        _addMarker(
          LatLng(position.latitude, position.longitude),
          user.uid,
          user.displayName ?? 'Sua Localização',
        );
        await _loadUserLocations(
            position.latitude, position.longitude, userType);
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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviços de localização desativados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissões de localização negadas.');
      }
    } else if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Permissões de localização permanentemente negadas. Não é possível solicitar permissões.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<void> _loadUserLocations(
      double latitude, double longitude, String userType) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final users = snapshot.docs.where((doc) {
      final data = doc.data();
      if (data.containsKey('location')) {
        final location = data['location'];
        bool isNearby = location != null &&
            location.containsKey('latitude') &&
            location.containsKey('longitude') &&
            _isNearby(location['latitude'], location['longitude'], latitude,
                longitude);

        // Filtrar usuários com base no tipo de usuário
        if (userType == 'tecnico' && data['userType'] == 'cliente') {
          return false; // Técnicos não veem clientes
        } else if (userType == 'cliente' && data['userType'] == 'tecnico') {
          return isNearby; // Clientes veem técnicos próximos
        }

        return false;
      }
      return false;
    });

    setState(() {
      _markers.clear();
      for (var user in users) {
        final data = user.data();
        final location = data['location'];
        _addMarker(
          LatLng(location['latitude'], location['longitude']),
          user.id,
          data['name'] ?? 'Sem Nome',
        );
      }
    });
  }

  bool _isNearby(double techLat, double techLng, double userLat, double userLng,
      {double radiusInKm = 10}) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(techLat - userLat);
    double dLng = _degreesToRadians(techLng - userLng);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(userLat)) * cos(_degreesToRadians(techLat)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance <= radiusInKm;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _addMarker(LatLng position, String id, String title) {
    _markers.add(Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: title),
    ));
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
      if (index == 0 && _selectedIndex != 0) {
        Navigator.pop(context);
      } else {
        _selectedIndex = index;
      }
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
              icon: Icon(Icons.person),
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
