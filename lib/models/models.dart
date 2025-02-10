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
        'icone': 'padrao.png',

        //Individual
        'pontuacao': 0,
        'palavrasEncontradas': [],
        'partida_valida': true,

        //Multiplayer
        'pontuacaoM': 0,
        'palavrasEncontradasM': [],
        'partida_validaM': true,
        'winM': false,
        'buscandoM': true,
        'duracaoM': DateTime.now(),

        'data_criacao': Timestamp.now(),
      });

      print("Usuário salvo com sucesso!");
    } catch (e) {
      throw Exception("Erro inesperado: $e");
    }
  }
}

class Player{
  List<String> palavrasEncontradas;
  int pontuacao;
  bool partidaValida;
  bool win;
  String icone;
  String nome;
  DateTime duracao;

  Player.vazio()
    : palavrasEncontradas = [],
      pontuacao = 0,
      partidaValida = false,
      win = false,
      icone = "",
      nome = "",
      duracao = DateTime.now();
}

class Match{
  int idAdversario;
  bool isFinished;

  Match.vazio()
    : idAdversario = 0,
      isFinished = false;
}
