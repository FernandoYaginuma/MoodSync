import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/View/home_view.dart';
import 'package:android2/View/professional_home_view.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fazerLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      // ============================================================
      // 🔐 LOGIN
      // ============================================================
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: "user-null",
          message: "Usuário veio nulo após login.",
        );
      }

      // ============================================================
      // 🔍 IDENTIFICA TIPO DE USUÁRIO
      // ============================================================
      final profissionalSnap =
      await _firestore.collection('professionals').doc(user.uid).get();

      final pacienteSnap =
      await _firestore.collection('users').doc(user.uid).get();

      if (!profissionalSnap.exists && !pacienteSnap.exists) {
        throw Exception(
          "Usuário autenticou, mas não existe em 'professionals' nem em 'users'.",
        );
      }

      String nome;
      bool isProfissional;

      if (profissionalSnap.exists) {
        final data = profissionalSnap.data()!;
        nome = (data['nome'] ?? 'Profissional').toString();
        isProfissional = true;
      } else {
        final data = pacienteSnap.data()!;
        nome = (data['nome'] ?? 'Paciente').toString();
        isProfissional = false;

        // ✅ IMPORTANTE:
        // Não verificar vínculos aqui, senão o dialog aparece na tela de login.
        // A HomeView já faz isso no initState (post frame).
      }

      // ============================================================
      // 🚀 REDIRECIONAMENTO
      // ============================================================
      if (!context.mounted) return;

      if (isProfissional) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfessionalHomeView(
              profissionalId: user.uid,
              profissionalNome: nome,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeView(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FIREBASE AUTH ERROR -> code=${e.code} message=${e.message}");

      String mensagemErro;
      switch (e.code) {
        case 'user-not-found':
          mensagemErro = 'Nenhum usuário encontrado com este e-mail.';
          break;
        case 'wrong-password':
          mensagemErro = 'Senha incorreta.';
          break;
        case 'invalid-email':
          mensagemErro = 'O formato do e-mail é inválido.';
          break;
        case 'network-request-failed':
          mensagemErro =
          'Falha de rede no dispositivo. Verifique internet/Wi-Fi.';
          break;
        case 'too-many-requests':
          mensagemErro = 'Muitas tentativas. Aguarde e tente novamente.';
          break;
        case 'operation-not-allowed':
          mensagemErro =
          'Login por e-mail/senha não está habilitado no Firebase.';
          break;
        default:
          mensagemErro = 'Erro ao fazer login (${e.code}).';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro)),
        );
      }
    } on FirebaseException catch (e) {
      // ✅ pega erro real do Firestore (permission-denied, unavailable, etc.)
      debugPrint("FIRESTORE ERROR -> code=${e.code} message=${e.message}");

      final msg = (e.code == 'permission-denied')
          ? 'Sem permissão no Firestore (verifique regras).'
          : 'Erro no Firestore (${e.code}).';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      debugPrint("GENERIC ERROR -> $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e")),
        );
      }
    }
  }

  void dispose() {
    emailController.dispose();
    senhaController.dispose();
  }
}
