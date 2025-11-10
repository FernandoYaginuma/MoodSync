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
      // Login com Firebase Authentication
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw FirebaseAuthException(code: "user-null");

      // 🔍 Tenta buscar o usuário primeiro como profissional
      final profissionalSnap =
      await _firestore.collection('professionals').doc(user.uid).get();

      // 🔍 Se não for profissional, tenta buscar como paciente
      final pacienteSnap =
      await _firestore.collection('patients').doc(user.uid).get();

      if (!profissionalSnap.exists && !pacienteSnap.exists) {
        throw Exception("Usuário não encontrado no banco de dados.");
      }

      // Define os dados conforme o tipo
      String nome;
      bool isProfissional;

      if (profissionalSnap.exists) {
        final data = profissionalSnap.data()!;
        nome = data['nome'] ?? 'Profissional';
        isProfissional = true;
      } else {
        final data = pacienteSnap.data()!;
        nome = data['nome'] ?? 'Paciente';
        isProfissional = false;
      }

      // Redirecionamento com base no tipo de usuário
      if (context.mounted) {
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
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      switch (e.code) {
        case 'user-not-found':
          mensagemErro = 'Nenhum usuário encontrado com este e-mail.';
          break;
        case 'wrong-password':
          mensagemErro = 'Senha incorreta. Por favor, tente novamente.';
          break;
        case 'invalid-email':
          mensagemErro = 'O formato do e-mail é inválido.';
          break;
        default:
          mensagemErro = 'Ocorreu um erro ao fazer login. Tente novamente.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: ${e.toString()}")),
        );
      }
    }
  }

  void dispose() {
    emailController.dispose();
    senhaController.dispose();
  }
}
