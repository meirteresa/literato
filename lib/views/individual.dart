import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/functions/decos.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

var amarelo = Color(0xFFF9BF64);
var rosa = Color(0xF4F08484);
var roxo = Colors.purple[300];

class IndividualPage extends StatefulWidget {
  const IndividualPage({super.key});

  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  TextEditingController _controller = TextEditingController();
  List<String> letras = [];
  List<String> palavrasDoDia = [];
  List<String> palavrasEncontradas = [];
  int pontuacao = 0;
  bool isLoading = true;
  bool partidaValida = true;

  @override
  void initState() {
    super.initState();
    carregarDadosDiarios();
    carregarProgressoUsuario();
  }

  Future<void> carregarDadosDiarios() async {
    String today = DateTime.now().toIso8601String().split("T")[0];
    var doc = await FirebaseFirestore.instance
        .collection("daily_levels")
        .doc(today)
        .get();
    if (doc.exists) {
      setState(() {
        letras = List<String>.from(doc.data()?['letras'] ?? []);
        palavrasDoDia = List<String>.from(
            doc.data()?['palavras']?.map((p) => p['palavra']) ?? []);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> carregarProgressoUsuario() async {
    var userDoc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (userDoc.exists) {
      setState(() {
        palavrasEncontradas =
            List<String>.from(userDoc.data()?['palavrasEncontradas'] ?? []);
        pontuacao = userDoc.data()?['pontuacao'] ?? 0;
        partidaValida = userDoc.data()?['partidaValida'] ?? true;
      });
    }
  }

  Future<void> verificarPalavra(String palavra) async {
    if (palavrasDoDia.contains(palavra) && !palavrasEncontradas.contains(palavra)) {
      int pontosGanhos = 5 + (palavra.length - palavrasDoDia.first.length) * 5;
      setState(() {
        palavrasEncontradas.add(palavra);
        pontuacao += pontosGanhos;
      });
      await FirebaseFirestore.instance.collection("usuarios").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "palavrasEncontradas": FieldValue.arrayUnion([palavra]),
        "pontuacao": FieldValue.increment(pontosGanhos)
      });
      verificarVitoria();
    }
  }

  void verificarVitoria() async {
    if (palavrasEncontradas.length == palavrasDoDia.length) {
      mostrarMensagem("Parabéns! Você encontrou todas as palavras!");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({"partidaValida": false}); // Atualiza Firebase
      setState(() {
        partidaValida = false;
      });
    }
  }

  void mostrarMensagem(String mensagem) {
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

  void desistir() async {
    mostrarMensagem("Você desistiu do desafio!");
    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({"partidaValida": false}); // Atualiza Firebase
    setState(() {
      partidaValida = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.purple[300], 
      systemNavigationBarColor: Colors.purple[300],
    ));

if (isLoading || letras.isEmpty || palavrasDoDia.isEmpty) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0D6B6),
      appBar: barraMenuIndividual(context),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return Scaffold(
    backgroundColor: const Color(0xFFA0D6B6),
    appBar: barraMenuIndividual(context),
    body: partidaValida ? jogoUI() : telaFinalUI(),
  );
  }

  Widget jogoUI(){
    int numColumns = 3;// Número fixo de colunas
    int numRows = 7;

  return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[

                  Container(
                    margin: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                    padding: const EdgeInsets.only(left: 80, right: 0),
                    decoration: boxPontos(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(),
                          child: pontos("PONTUAÇÃO:", 'MightySouly', 16, false),
                        ),
                        SizedBox(
                          height: 52,
                          child: VerticalDivider(color: Colors.white, thickness: 1.8),
                        ),
                        DecoratedBox(
                          decoration: boxDeco(),
                            child: pontos("$pontuacao pontos", 'Lato', 15, true),
                        ),
                      ],
                    )
                  ),
                  
                  Container(
                    margin: const EdgeInsets.only(left: 40, right: 40,top: 30, bottom: 0),
                    child: Text("Combine as letras e tente desvendar as 20 palavras secretas de hoje!", style: GoogleFonts.lato(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                  ),

                  // Letras
                  Container(
                    margin: const EdgeInsets.only(left: 40, right: 40,top: 40, bottom: 26),
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(width: 2.5, color: rosa1),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white70,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DecoratedBox(
                          decoration: boxDeco(),
                          child: decoLetras(letras[0]),
                        ),
                        SizedBox(
                          height: 52,
                          child: VerticalDivider(color: rosa1, thickness: 2.5),
                        ),
                        DecoratedBox(
                          decoration: boxDeco(),
                          child: decoLetras(letras[1]),
                        ),
                        SizedBox(
                          height: 52,
                          child: VerticalDivider(color: rosa1, thickness: 2.5),
                        ),                  
                        DecoratedBox(
                          decoration: boxDeco(),
                          child: decoLetras(letras[2]),
                        ),
                        SizedBox(
                          height: 52,
                          child: VerticalDivider(color: rosa1, thickness: 2.5),
                        ),                  
                        DecoratedBox(
                          decoration: boxDeco(),
                          child: decoLetras(letras[3]),
                        ),
                        SizedBox(
                          height: 52,
                          child: VerticalDivider(color: rosa1, thickness: 2.5),
                        ),
                        DecoratedBox(
                          decoration: boxDeco(),
                            child: decoLetras(letras[4]),
                        ),
                      ],
                    )
                  ),

                  // TextField
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 30.0),
                    width: 285.0,

                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      spacing: 15,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: _controller,
                            cursorColor: roxo,
                            textCapitalization: TextCapitalization.words,
                            decoration: respostaDeco("Digite aqui"),
                          ),
                        ),
                        SizedBox(
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, size:22, color: amarelo2, fill: 0.1),
                            style: botaoEnviar(),
                            onPressed: () {
                              verificarPalavra(_controller.text.toLowerCase());
                              _controller.clear();
                            },
                          ),
                        ),
                      ],
                    ),

                  ),

                  Container(
                    width: 315,
                    height: 20,
                    margin: const EdgeInsets.only(left: 0, right: 0,top: 20, bottom: 0),
                    child: Text("Palavras encontradas: ", style: GoogleFonts.lato(color: roxo, fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                  
                  //Caixa de palavras encontradas
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 0),
                    decoration: BoxDecoration(
                      border: null,
                    ),
                    child: Row(
                      children: List.generate(numColumns, (colIndex) {
                        return Expanded(
                          child: Column(
                              children: List.generate(numRows, (rowIndex) {
                              int wordIndex = rowIndex * numColumns + colIndex;
                              bool encontrada = palavrasEncontradas.contains(palavrasDoDia[wordIndex]);
                              if (encontrada) {
                                return wordBox(palavrasDoDia[wordIndex], wordIndex);
                              } else {
                                return wordBox("", wordIndex);
                              }
                            }),
                          ),
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 40),

                  ElevatedButton(
                      onPressed: desistir,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),),
                      child: Text("Desistir", style: TextStyle(fontSize: 14.0, color: Colors.white),),
                  ),
                  

                  SizedBox(height: 20),
            
                ],

              ),
            ),
          );
  }

  Widget telaFinalUI(){
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Fim do Desafio!", style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text("Sua pontuação final: $pontuacao", style: GoogleFonts.lato(fontSize: 18)),
              SizedBox(height: 20),
              Text("Palavras encontradas:", style: GoogleFonts.lato(fontSize: 18)),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: palavrasEncontradas.map((palavra) {
                  return Chip(label: Text(palavra));
                }).toList(),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: roxo),
                child: Text("Voltar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
  }

  Widget wordBox(String word, int index) {
      bool isSpecial = index == 20; // Palavra 21 (índice começa do 0)

      return Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: EdgeInsets.only(left: 2, right: 2, bottom: 2, top: 2),
        width: double.infinity, // Ocupa a largura disponível
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSpecial ? Colors.yellow : Colors.white, width: isSpecial ? 3 : 1),
          boxShadow: isSpecial
              ? [BoxShadow(color: Colors.yellow, blurRadius: 8, spreadRadius: 2)]
              : [],
        ),
        child: Center(
          child: Text(
            word,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
  } 
