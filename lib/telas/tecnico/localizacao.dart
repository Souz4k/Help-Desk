import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChooseLocationScreen extends StatefulWidget {
  @override
  _ChooseLocationScreenState createState() => _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  LatLng _selectedLocation = LatLng(-20.8202, -49.3797); // São José do Rio Preto

  void _saveLocation() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'location': {
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
        },
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Localização salva com sucesso!')),
        );
        Navigator.pop(context); // Voltar para a tela anterior após salvar
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar localização: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Escolher Localização",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveLocation,
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation, // Foco inicial no mapa
          zoom: 15, // Nível de zoom inicial
        ),
        onTap: (LatLng position) {
          setState(() {
            _selectedLocation = position;
          });
        },
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: _selectedLocation,
          ),
        },
      ),
    );
  }
}
