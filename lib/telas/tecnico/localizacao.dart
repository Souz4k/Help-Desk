import 'package:app/telas/tecnico/alterar_info_Tec.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChooseLocationScreen extends StatefulWidget {
  @override
  _ChooseLocationScreenState createState() => _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  LatLng _selectedLocation =
      LatLng(-20.8202, -49.3797); // São José do Rio Preto

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AlterarInfotec()),
    );
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                'Sucesso',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Localização atualizada com Sucesso!',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToHomeScreen();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text(
                'Erro',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Erro ao Atualizar Informações",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveLocation() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'location': {
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
        },
      }).then((_) {
        _showSuccessDialog();
        // Navigator.pop(context); // Voltar para a tela anterior após salvar
      }).catchError((error) {
        _showErrorDialog("Erro ao escolher localização");
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
