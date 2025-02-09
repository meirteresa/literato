import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Usuario{
    Future<void> salvarUsuarionoBanco(String nome, String email, String senha) async {
    try {
      // Criar usuário no Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);

      // Salvar dados adicionais no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user?.uid) // Salva usando o UID do Firebase
          .set({
        'nome': nome,
        'email': email,
        'senha': senha,
        'pontuacao': 0, // Inicia com 0 pontos
        'palavrasEncontradas': [],
        'partida_valida': true,
        'data_criacao': Timestamp.now(),
      });

      print("Usuário salvo com sucesso!");
    } catch (e) {
      throw Exception("Erro inesperado: $e");
    }
  }
}
