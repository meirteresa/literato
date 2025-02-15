import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:literato/utils/decos.dart';

class IndividualPageController{
  //app bar individual
  dynamic barraMenuIndividual(BuildContext context){
    var barraMenu = AppBar(
            toolbarHeight: 80,
            backgroundColor: Colors.purple[300],
            leading: IconButton(
              padding: EdgeInsets.only(left: 25, right: 0, top: 20, bottom: 20),
              icon: Icon(Icons.arrow_back, color: branco),
              onPressed: () => Navigator.of(context).pop(),
              iconSize: 32,
            ),
            actions: [
              IconButton(
                padding: EdgeInsets.only(left: 0, right: 25, top: 20, bottom: 20),
                onPressed: () {
                  Navigator.pushNamed(context, '/help');
                },
                icon: Icon(Icons.help_outline_rounded, color: branco),
                iconSize: 32,
              ),
            ],
            title: Image.asset('images/logo5.png', fit: BoxFit.fill, height: 68),
            centerTitle: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              )
            ),
        );

    return barraMenu;
  }

  //CARREGAMENTOS DE DADOS
  Future<void> carregarDadosDiarios(Function(List<String>) updateLetras, Function(List<String>) updatePalavrasDoDia) async {
    List<String> letras = [];
    List<String> palavrasDoDia = [];

    String today = DateTime.now().toIso8601String().split("T")[0];
    var doc = await FirebaseFirestore.instance
        .collection("daily_levels")
        .doc(today)
        .get();
    if (doc.exists) {
      letras = List<String>.from(doc.data()?['letras'] ?? []);
      palavrasDoDia = List<String>.from(
          doc.data()?['palavras']?.map((p) => p['palavra']) ?? []);

      updateLetras(letras);
      updatePalavrasDoDia(palavrasDoDia);
    }
  }


  Future<void> carregarProgressoUsuario(
    Function(List<String>) updatePalavrasEncontradas,
    Function(int) updatePontuacao,
    Function(bool) updatePartidaValida,
    Function(bool) updateCarregamento,
    List<String> palavrasDoDia
  ) async {
    List<String> palavrasEncontradas = [];
    int pontuacao = 0;
    bool partidaValida = true;

    var userDoc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (userDoc.exists) {
      palavrasEncontradas =
          List<String>.from(userDoc.data()?['palavrasEncontradas'] ?? []);
      pontuacao = userDoc.data()?['pontuacao'] ?? 0;
      partidaValida = userDoc.data()?['partida_valida'] ?? true;

      // Se houver palavras encontradas e pelo menos uma não estiver nas palavras do dia, resetar
      if (palavrasEncontradas.isNotEmpty &&
          palavrasEncontradas.any((p) => !palavrasDoDia.contains(p))) {
        palavrasEncontradas = [];
        pontuacao = 0;

        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'palavrasEncontradas': [],
          'pontuacao': 0,
          'partida_valida': true
        });
      }

      updatePalavrasEncontradas(palavrasEncontradas);
      updatePontuacao(pontuacao);
      updatePartidaValida(partidaValida);
    }

    updateCarregamento(false);
  }
 

  Future<int?> carregarPontuacaoPalavra(String palavra) async {
    String today = DateTime.now().toIso8601String().split("T")[0];

    var doc = await FirebaseFirestore.instance
        .collection("daily_levels")
        .doc(today)
        .get();

    if (doc.exists) {
      List<dynamic> palavrasDoDia = doc.data()?['palavras'] ?? [];

      // Procura a palavra na lista e retorna a pontuação correspondente
      for (var item in palavrasDoDia) {
        if (item['palavra'] == palavra) {
          return item['pontos'];
        }
      }
    }

    return null;
  }


  //MENSAGENS E CAIXAS DE DIÁLOGO
  void mostrarMensagem(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }


  Future<bool> confirmaVitoria(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Text("Você ganhou!", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 18, fontWeight: FontWeight.w600)),
          content: Text("Achou todas as palavras e venceu o desafio! 🥳", style: TextStyle(color: Colors.black54, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w400)),
          actions: 
          [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    acao1();
                  },
                  child: Text("Ok", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  void acao1() async {
    await FirebaseFirestore.instance
    .collection("usuarios")
    .doc(FirebaseAuth.instance.currentUser?.uid)
    .update({"partida_valida": false});
  } 


  Future<bool> confirmaDesistencia(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Text("Confirmação", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 18, fontWeight: FontWeight.w600)),
          content: Text("Tem certeza que deseja desistir? ☹️", style: TextStyle(color: Colors.black54, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w400)),
          actions: 
          [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    acao1();
                  },
                  child: Text("Sim", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Cancelar", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  Future<void> confirmapontuacao(BuildContext context, String palavra, int pontos, bool especial) async {
    String titulo = especial ? "🎉 Palavra Especial! 🎉" : "Palavra Encontrada!";
    String mensagem = "\nVocê encontrou a palavra \"$palavra\"";
    
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(color: especial ? Colors.orange : roxo, fontFamily: 'Lato', fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 15), // Espaço entre os textos
              Text(
                "+$pontos pontos",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: especial ? Colors.orangeAccent : Colors.green,
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Ok", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }


  //VERIFICAR VITORIA & DESISTÊNCIA  
  Future<void> verificarVitoria(
    BuildContext context, 
    Function(bool) updatePartidaValida,
    List<String> palavrasDoDia,
    List<String> palavrasEncontradas
  ) async {
    if (Set<String>.from(palavrasEncontradas).containsAll(palavrasDoDia)) {
      bool confirmou = await confirmaVitoria(context);
      
      if (confirmou) {
        mostrarMensagem(context, "Parabéns! Você venceu!");
        
        updatePartidaValida(false);
      }
    }
  }


  Future<void> desistir(BuildContext context, Function(bool) updatePartidaValida,) async {
    bool confirmou = await confirmaDesistencia(context);
    
    if (confirmou) {
      mostrarMensagem(context, "Você desistiu do desafio!");
      
      updatePartidaValida(false);
    }
  }
}
