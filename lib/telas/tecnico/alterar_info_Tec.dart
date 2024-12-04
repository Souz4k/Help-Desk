import 'package:app/componentes/decoracao_campo_autenticacao.dart';
import 'package:app/telas/cliente/tela_inicial_cliente.dart';
import 'package:app/telas/tecnico/tela_inicial_tecnico.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/servicos/autenticacao_servico.dart';
import 'package:app/telas/Tela_inicial.dart';
import 'package:app/_comum/meu_snackbar.dart';
import 'package:app/_comum/minhas_cores.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app/telas/tecnico/localizacao.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AlterarInfotec extends StatefulWidget {
  const AlterarInfotec({Key? key});

  @override
  _AlterarInfotecState createState() => _AlterarInfotecState();
}

class _AlterarInfotecState extends State<AlterarInfotec> {
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
  List<String> _diplomaUrls = [];

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
    _loadDiplomaImages();
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

  Future<void> _loadDiplomaImages() async {
    if (_user != null) {
      var diplomasDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('diplomas')
          .get();

      if (diplomasDoc.docs.isNotEmpty) {
        setState(() {
          _diplomaUrls =
              diplomasDoc.docs.map((doc) => doc['url'] as String).toList();
        });
      }
    }
  }

  Future<void> _deslogar(BuildContext context) async {
    try {
      await AutenticacaoServico().deslogar();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaInicial()),
      );
    } catch (e) {
      print("Erro ao deslogar: $e");
      mostrarSnackBar(context: context, texto: "Erro ao deslogar");
    }
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Tela_inicial_tecnico()),
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
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .update({'name': newName});
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

        _showSuccessDialog();
      }
    } catch (e) {
      print("Erro ao atualizar informações: $e");
      _showErrorDialog("Erro ao atualizar informações: ${e.toString()}");
    }
  }

  Future<void> _pickDiplomaImage() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;
    File selectedImage = File(returnedImage.path);

    final storageRef = FirebaseStorage.instance.ref();
    final imageref = storageRef.child(
        "${_user!.uid}/diplomas/${DateTime.now().millisecondsSinceEpoch}.jpg");
    await imageref.putFile(selectedImage);
    var url = await imageref.getDownloadURL();

    setState(() {
      _diplomaUrls.add(url);
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_user!.uid)
        .collection("diplomas")
        .add({"url": url});
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final returnedImage = await ImagePicker().pickImage(source: source);

    if (returnedImage == null) return;
    File selectedImage = File(returnedImage.path);

    final storageRef = FirebaseStorage.instance.ref();
    final imageref =
        storageRef.child("${FirebaseAuth.instance.currentUser!.uid}.jpg");
    await imageref.putFile(selectedImage);
    var url = await imageref.getDownloadURL();

    setState(() {
      _imageUrl = url;
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({"fotourl": url}, SetOptions(merge: true));
  }

  void _showProfileImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Câmera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, bool obscureText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0), // Bordas arredondadas
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildCellphoneField() {
    return TextFormField(
      controller: _celularController,
      decoration: InputDecoration(
        labelText: 'Celular',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0), // Bordas arredondadas
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Permite apenas dígitos
        maskFormatter, // Aplica a máscara
      ],
    );
  }

  Future<void> _deleteDiploma(String url) async {
    try {
      // Remover do Firestore
      final diplomas = await FirebaseFirestore.instance
          .collection("users")
          .doc(_user!.uid)
          .collection("diplomas")
          .where("url", isEqualTo: url)
          .get();

      for (var doc in diplomas.docs) {
        await doc.reference.delete();
      }

      // Remover do Storage
      final storageRef = FirebaseStorage.instance.refFromURL(url);
      await storageRef.delete();

      setState(() {
        _diplomaUrls.remove(url);
      });
    } catch (e) {
      print("Erro ao deletar diploma: $e");
    }
  }

  Widget _buildDiplomaGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 imagens por linha
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _diplomaUrls.length,
          itemBuilder: (context, index) {
            final url = _diplomaUrls[index];
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () => _deleteDiploma(url),
                    child: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Alterar Informações",
            style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showProfileImageSourceActionSheet(context),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
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
                        : Container(
                            color: MinhasCores.brancogelo,
                            child: Icon(Icons.camera_alt_outlined, size: 70),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_nomeController, 'Nome', false),
              SizedBox(height: 20),
              _buildTextField(_senhaAtualController, 'Senha Atual', true),
              SizedBox(height: 20),
              _buildTextField(_novaSenhaController, 'Nova Senha', true),
              Text(
                'A senha deve ter no mínimo 6 caracteres.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 20),
              _buildCellphoneField(),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChooseLocationScreen()),
                  );
                },
                child: Text('Escolher Localização',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              SizedBox(height: 20),
              Text("Meus Diplomas:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildDiplomaGrid(),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickDiplomaImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text("Adicionar Diploma",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              SizedBox(height: 20),
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

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _celularController.dispose();
    super.dispose();
  }
}
