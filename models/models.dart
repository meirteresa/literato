import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Usuario {
  Future<void> salvarUsuarionoBanco(
      String nome, String email, String senha) async {
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
        'icone': 'padrao.png',
        'latitude': 0.0,
        'longitude': 0.0,

        //Individual
        'pontuacao': 0,
        'palavrasEncontradas': [],
        'partida_valida': true,

        //Multiplayer
        'pontuacaoM': 0,
        'palavrasEncontradasM': [],
        'partida_validaM': true,
        'winM': false,
        'buscandoM': false,
        'duracaoM': DateTime.now(),
        'id_adversario': "",
        'mensagem_final': "",

        'data_criacao': Timestamp.now(),
      });

      print("Usuário salvo com sucesso!");
    } catch (e) {
      throw Exception("Erro inesperado: $e");
    }
  }
}

class Player {
  List<String> palavrasEncontradas;
  int pontuacao;
  bool partidaValida;
  bool win;
  String icone;
  String nome;
  DateTime duracao;
  bool buscandoM;

  Player.vazio()
      : palavrasEncontradas = [],
        pontuacao = 0,
        partidaValida = true,
        win = false,
        icone = "",
        nome = "",
        duracao = DateTime.now(),
        buscandoM = true;
}

class Match {
  int idAdversario;
  bool isFinished;

  Match.vazio()
      : idAdversario = 0,
        isFinished = false;
}

class HoraFim {
  static Future<Timestamp?> calcularHoraFimPartida() async {
    var doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    Timestamp? horaFim = doc.data()?['horaFim'];

    return horaFim;
  }
}
