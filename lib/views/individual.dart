import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/controllers/connectionController.dart';
import 'package:literato/utils/decos.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:literato/controllers/individualController.dart';

var amarelo = Color(0xFFF9BF64);

class IndividualPage extends StatefulWidget {
  const IndividualPage({super.key});

  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  final IndividualPageController _controllerPage = IndividualPageController();
  TextEditingController _controller = TextEditingController();
  List<String> letras = [];
  List<String> palavrasDoDia = [];
  List<String> palavrasEncontradas = [];
  int pontuacao = 0;
  bool isLoading = true;
  bool partidaValida = true;
  final FocusNode _focusNode = FocusNode();

  void _updateLetras(List<String> letrasAtualizadas) {
    setState(() {
      letras = letrasAtualizadas;
    });
  }

  void _updatePalavrasDoDia(List<String> palavrasDoDiaAtualizadas) {
    setState(() {
      palavrasDoDia = palavrasDoDiaAtualizadas;
    });
  }

  void _updatePalavrasEncontradas(List<String> palavrasEncontradasAtualizadas) {
    setState(() {
      palavrasEncontradas = palavrasEncontradasAtualizadas;
    });
  }  

  void _updatePontuacao(int pontuacaoAtualizada) {
    setState(() {
      pontuacao = pontuacaoAtualizada;
    });
  }  

  void _updatePartidaValida(bool estadoPartida) {
    setState(() {
      partidaValida = estadoPartida;
    });
  }  

  void _updateCarregamento(bool carregamento) {
    setState(() {
      isLoading = carregamento;
    });
  }

  @override
  void initState() {
    super.initState();

    _controllerPage.carregarDadosDiarios(_updateLetras, _updatePalavrasDoDia).then((_) {
    _controllerPage.carregarProgressoUsuario(
      _updatePalavrasEncontradas, 
      _updatePontuacao, 
      _updatePartidaValida, 
      _updateCarregamento, 
      palavrasDoDia
    );
  });
    ConnectionController.checaConexao(context);
  }

  Future<void> verificarPalavra(String palavra) async {
    _focusNode.unfocus();

    palavra = palavra.trim();

    if(RegExp(r'[áàâãéèêíïóôõöúçñ]').hasMatch(palavra)){
      _controllerPage.mostrarMensagem(context, "Lembre-se que acentos e cedilha não são aceitos! Tente escrever a palavra sem ele(s). ✍️");
      return;
    }

    if(palavrasEncontradas.contains(palavra)){
      _controllerPage.mostrarMensagem(context, "Você já encontrou essa palavra! Continue tentando 😉");
      return;
    }

    if(palavra.length < 4){
      _controllerPage.mostrarMensagem(context, "A palavra ter pelo menos 4 letras! 📏");
      return;
    }

    if (!palavra.split('').every((letra) => letras.contains(letra))){
      _controllerPage.mostrarMensagem(context, "A palavra digitada contém letra(s) que não foram sorteadas. Tente novamente! 🔤");
      return;
    }

    if (palavrasDoDia.contains(palavra) && !palavrasEncontradas.contains(palavra)) {
      int pontosGanhos = await _controllerPage.carregarPontuacaoPalavra(palavra) ?? 0;
      bool especial = palavra == palavrasDoDia.last;

      await _controllerPage.confirmapontuacao(context, palavra, pontosGanhos, especial);

      setState(() {
        palavrasEncontradas.add(palavra);
        pontuacao += pontosGanhos;
      });

      await FirebaseFirestore.instance.collection("usuarios").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "palavrasEncontradas": FieldValue.arrayUnion([palavra]),
        "pontuacao": FieldValue.increment(pontosGanhos)
      });

      _controllerPage.verificarVitoria(context, _updatePartidaValida, palavrasDoDia, palavrasEncontradas);
    }else{
      _controllerPage.mostrarMensagem(context, "Palavra errada! Continue tentando 😉");
    }
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
      appBar: _controllerPage.barraMenuIndividual(context),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return Scaffold(
    backgroundColor: const Color(0xFFA0D6B6),
    appBar: _controllerPage.barraMenuIndividual(context),
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
                    child: Text("Combine as letras e tente desvendar as 21 palavras secretas de hoje!", style: GoogleFonts.lato(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
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
                            focusNode: _focusNode,
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
                      onPressed: () {
                        _focusNode.unfocus();
                        _controllerPage.desistir(context, _updatePartidaValida);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),),
                      child: Text("Desistir", style: TextStyle(fontSize: 14.0, color: Colors.white),),
                  ),
                  

                  SizedBox(height: 20),
            
                ],

              ),
            ),
          );
  }

  Widget telaFinalUI() {
    String mensagemFinal = palavrasEncontradas.length == palavrasDoDia.length
        ? "Parabéns! Você acertou todas \nas palavras e ganhou o jogo! 🥇"
        : "Você desistiu da partida! \n\n☹️";

    return SingleChildScrollView(
      child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 70),
          Text("Fim do Desafio!", style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(mensagemFinal, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          SizedBox(height: 40),
          Text("Pontuação final:", style: GoogleFonts.lato(fontSize: 18)),
          Text("$pontuacao pontos", style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.w800, color: roxo)),
          SizedBox(height: 40),
          Text("Gabarito das palavras:", style: GoogleFonts.lato(fontSize: 18)),
          SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            children: palavrasDoDia.map((palavra) {
              return Chip(label: Text(palavra));
            }).toList(),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: roxo),
            child: Text("Voltar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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