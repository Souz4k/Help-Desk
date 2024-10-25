import 'package:app/telas/cliente/tela_inicial_cliente.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AlterarInfoCli extends StatefulWidget {
  const AlterarInfoCli({Key? key}) : super(key: key);

  @override
  _AlterarInfoCliState createState() => _AlterarInfoCliState();
}

class _AlterarInfoCliState extends State<AlterarInfoCli> {
  final maskFormatter = MaskTextInputFormatter(
    mask: '(##)#####-####',
    filter: {
      "#": RegExp(r'[0-9]'), // Permite apenas números
    },
  );

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

  Future<void> _atualizarInformacoes(String newName, String oldPassword,
      String newSenha, String celular) async {
    try {
      if (_user != null) {
        var credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: oldPassword,
        );
        await _user!.reauthenticateWithCredential(credential);

        // Atualiza o nome, se necessário
        if (newName.isNotEmpty && newName != _nomeAtual) {
          await _user!.updateDisplayName(newName);
          _nomeAtual = newName;
        }
        // Atualiza a senha, se fornecida
        if (newSenha.isNotEmpty) {
          await _user!.updatePassword(newSenha);
        }

        // Atualiza o celular, se fornecido
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

        _showSuccessDialog();
      }
    } catch (e) {
      print("Erro ao atualizar informações: $e");
      _showErrorDialog("Erro ao atualizar informações: ${e.toString()}");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: source);

      if (returnedImage == null) return;
      File selectedImage = File(returnedImage.path);

      // Faz o upload da imagem para o Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("${_user!.uid}.jpg");
      await imageRef.putFile(selectedImage);
      var url = await imageRef.getDownloadURL();

      setState(() {
        _imageUrl = url; // Atualiza a URL da imagem no estado
      });

      // Atualiza a URL da imagem no Firestore
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

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => telaInicialCliente()),
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
                  'Informações atualizadas com sucesso!',
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

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blueAccent,
      title: Text("Alterar Informações",
          style: TextStyle(fontSize: 20, color: Colors.white)),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: CircleAvatar(
                radius: 75,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                child: _imageUrl == null
                    ? Icon(Icons.camera_alt_outlined,
                        size: 70, color: Colors.grey[600])
                    : null,
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(_nomeController, 'Nome', false),
            SizedBox(height: 20),
            _buildTextField(_senhaAtualController, 'Senha Atual', true),
            SizedBox(height: 20),
            _buildTextField(_novaSenhaController, 'Nova Senha', true),
            // Adicionando o texto informativo abaixo do campo de nova senha
            Text(
              'A senha deve ter no mínimo 6 caracteres.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 20),
            _buildCellphoneField(),
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
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text("Atualizar Informações",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTextField(
      TextEditingController controller, String labelText, bool obscureText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[700]),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildCellphoneField() {
    return TextFormField(
      controller: _celularController,
      decoration: InputDecoration(
        labelText: 'Celular',
        labelStyle: TextStyle(color: Colors.grey[700]),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Permite apenas dígitos
        maskFormatter, // Aplica a máscara
      ],
    );
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
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
