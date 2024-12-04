import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TelaLocalizacaoTecnico extends StatefulWidget {
  @override
  _TelaLocalizacaoTecnicoState createState() => _TelaLocalizacaoTecnicoState();
}

class _TelaLocalizacaoTecnicoState extends State<TelaLocalizacaoTecnico> {
  late GoogleMapController _mapController;
  LatLng? _tecnicoLocalizacao;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTecnicoLocalizacao();
  }

  Future<void> _loadTecnicoLocalizacao() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists && snapshot.data() != null) {
          var data = snapshot.data()!;

          // Verifica se o campo 'location' existe e contém latitude e longitude
          if (data.containsKey('location')) {
            var location = data['location'];

            if (location.containsKey('latitude') &&
                location.containsKey('longitude')) {
              setState(() {
                _tecnicoLocalizacao = LatLng(
                  location['latitude'],
                  location['longitude'],
                );
              });
            }
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar localização: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localização do Técnico'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tecnicoLocalizacao == null
              ? Center(child: Text('Localização não encontrada'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _tecnicoLocalizacao!,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('tecnicoLocation'),
                      position: _tecnicoLocalizacao!,
                      infoWindow: InfoWindow(
                        title: 'Localização do Técnico',
                      ),
                    )
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: false,
                  zoomGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                ),
    );
  }
}
