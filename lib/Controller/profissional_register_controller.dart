import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalRegisterController {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final telefoneController = TextEditingController();
  final especialidadeController = TextEditingController();
  final registroProfissionalController = TextEditingController();
  final descricaoController = TextEditingController();

  Future<void> cadastrar(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final user = cred.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('professionals')
            .doc(user.uid)
            .set({
          'id': user.uid,
          'nome': nomeController.text.trim(),
          'email': emailController.text.trim(),
          'telefone': telefoneController.text.trim(),
          'especialidade': especialidadeController.text.trim(),
          'registroProfissional': registroProfissionalController.text.trim(),
          'descricao': descricaoController.text.trim(),
          'role': 'profissional',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Documento universal
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': user.uid,
          'nome': nomeController.text.trim(),
          'email': emailController.text.trim(),
          'role': 'profissional',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadastro de profissional realizado com sucesso!'),
            ),
          );

          // ✅ agora '/login' existe no main.dart
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ PROFESSIONAL REGISTER AUTH ERROR -> ${e.code} ${e.message}");
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Este e-mail já está em uso.';
          break;
        case 'weak-password':
          msg = 'A senha é muito fraca.';
          break;
        default:
          msg = 'Erro ao cadastrar profissional. Tente novamente.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on FirebaseException catch (e) {
      debugPrint("❌ PROFESSIONAL REGISTER FIRESTORE ERROR -> ${e.code} ${e.message}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no Firestore (${e.code}).')),
        );
      }
    } catch (e) {
      debugPrint("❌ PROFESSIONAL REGISTER ERROR -> $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e')),
        );
      }
    }
  }

  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    telefoneController.dispose();
    especialidadeController.dispose();
    registroProfissionalController.dispose();
    descricaoController.dispose();
  }
}
