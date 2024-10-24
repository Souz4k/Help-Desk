import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AlterarInfoCli extends StatefulWidget {
  const AlterarInfoCli({Key? key});

  @override
  _AlterarInfoCliState createState() => _AlterarInfoCliState();
}

class _AlterarInfoCliState extends State<AlterarInfoCli> {
  late TextEditingController _nomeController;
  late TextEditingController _senhaAtualController;
  late TextEditingController _novaSenhaController;
  late TextEditingController _celularController;
  User? _user;
  String? _nomeAtual;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _nomeAtual = _user?.displayName;
    _nomeController = TextEditingController(text: _nomeAtual);
    _senhaAtualController = TextEditingController();
    _novaSenhaController = TextEditingController();
    _celularController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('fotourl')) {
        setState(() {
          _imageUrl = userDoc['fotourl'];
        });
      }
    }
  }

  Future<void> _atualizarInformacoes(String newName, String oldPassword,
      String newSenha, String celular) async {
    try {
      if (_user != null) {
        var credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: oldPassword,
        );
        await _user!.reauthenticateWithCredential(credential);

        if (newName.isNotEmpty && newName != _nomeAtual) {
          await _user!.updateDisplayName(newName);
          _nomeAtual = newName;
        }
        if (newSenha.isNotEmpty) {
          await _user!.updatePassword(newSenha);
        }

        Map<String, String> updateData = {};
        if (celular.isNotEmpty) {
          updateData['celular'] = celular;
        }

        if (updateData.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .set(updateData, SetOptions(merge: true));
        }

        // Mostrar pop-up de sucesso
        _showSuccessDialog();
      }
    } catch (e) {
      print("Erro ao atualizar informações: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao atualizar informações",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: source);

      if (returnedImage == null) return;
      File selectedImage = File(returnedImage.path);

      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("${_user!.uid}.jpg");
      await imageRef.putFile(selectedImage);
      var url = await imageRef.getDownloadURL();

      setState(() {
        _imageUrl = url;
      });

      await FirebaseFirestore.instance
          .collection("users")
          .doc(_user!.uid)
          .set({"fotourl": url}, SetOptions(merge: true));
    } catch (e) {
      print("Erro ao fazer upload da imagem: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao fazer upload da imagem"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // O usuário precisa pressionar OK para fechar o diálogo
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
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Informações atualizadas com sucesso!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
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
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        title: Text("Alterar Informações"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                          )
                        : Icon(Icons.camera_alt_outlined, size: 70),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _senhaAtualController,
                decoration: InputDecoration(
                  labelText: 'Senha Atual',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _novaSenhaController,
                decoration: InputDecoration(
                  labelText: 'Nova Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _celularController,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await _atualizarInformacoes(
                    _nomeController.text,
                    _senhaAtualController.text,
                    _novaSenhaController.text,
                    _celularController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  "Atualizar Informações",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeria'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Câmera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _celularController.dispose();
    super.dispose();
  }
}
