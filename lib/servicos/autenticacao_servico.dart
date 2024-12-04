import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? get uid => null;

  Future<String?> cadastrarUsuario({
    required String nome,
    required String senha,
    required String confirmarSenha,
    required String email,
  }) async {
    if (senha.length < 6) {
      return "A senha deve ter pelo menos 6 caracteres";
    }

    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await userCredential.user!.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "Usuário já cadastrado com este e-mail";
      }
      return "Erro ao cadastrar usuário: ${e.message}";
    }
  }

  Future<String?> logarUsuario(
      {required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      return "Erro ao fazer login: ${e.message}";
    }
  }

  Future<void> deslogar() async {
    return _firebaseAuth.signOut();
  }

  /// Obtém o usuário atual autenticado
  User? obterUsuarioAtual() {
    return _firebaseAuth.currentUser;
  }
}
