import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/functions/decos.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:literato/controllers/controllers.dart';
import 'package:literato/models/models.dart';

const amarelo = Color(0xFFF9BF64);
const rosa = Color(0xF4F08484);

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({super.key});

  @override
  State<MultiplayerPage> createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  final ScrollController _scrollController = ScrollController();
  double _opacity = 1.0; // Controla a visibilidade do container
  final FocusNode _focusNode = FocusNode();

  TextEditingController _controller = TextEditingController();
  final MultiplayerPageController _controllerPage = MultiplayerPageController();
  List<String> letras = [];
  List<String> palavrasDoDia = [];
  bool isLoading = true;
  Player user = Player.vazio();
  Player adversario = Player.vazio();
 

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
      user.palavrasEncontradas = palavrasEncontradasAtualizadas;
    });
  }  

  void _updatePontuacao(int pontuacaoAtualizada) {
    setState(() {
      user.pontuacao = pontuacaoAtualizada;
    });
  }  

  void _updatePartidaValida(bool estadoPartida) {
    setState(() {
      user.partidaValida = estadoPartida;
    });
  }  

  void _updatePartidaWin(bool win) {
    setState(() {
      user.win = win;
    });
  }  

  void _updateAdversario(int pontuacaoAtualizada , bool partidaValida, bool win, String nome, String icone) {
    setState(() {
      adversario.pontuacao = pontuacaoAtualizada;
      adversario.partidaValida = partidaValida;
      adversario.win = win;
      adversario.nome = nome;
      adversario.icone = icone;
    });
  }  

  void _updateNomeIcone(String nome, String icone) {
    setState(() {
      user.nome = nome;
      user.icone = icone;
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
    _scrollController.addListener(_handleScroll);
    _controllerPage.carregarDadosDiarios(_updateLetras, _updatePalavrasDoDia).then((_) {
      _controllerPage.carregarProgressoUsuario(
        _updatePalavrasEncontradas, 
        _updatePontuacao, 
        _updatePartidaValida,
        _updateNomeIcone,
        _updatePartidaWin,
        palavrasDoDia
      );
      _controllerPage.findAndStartMatch();
      _controllerPage.atualizarAdversario(_updateAdversario, _updateCarregamento);
    });
  }

  Future<void> verificarPalavra(String palavra) async {
    _focusNode.unfocus();

    if(RegExp(r'[áàâãéèêíïóôõöúçñ]').hasMatch(palavra)){
      _controllerPage.mostrarMensagem(context, "Lembre-se que acentos e cedilha não são aceitos! Tente escrever a palavra sem ele(s). ✍️");
      return;
    }

    if(user.palavrasEncontradas.contains(palavra)){
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

    if (palavrasDoDia.contains(palavra) && !user.palavrasEncontradas.contains(palavra)) {
      int pontosGanhos = await _controllerPage.carregarPontuacaoPalavra(palavra) ?? 0;
      bool especial = palavra == palavrasDoDia.last;

      await _controllerPage.confirmapontuacao(context, palavra, pontosGanhos, especial);

      setState(() {
        user.palavrasEncontradas.add(palavra);
        user.pontuacao += pontosGanhos;
      });

      await FirebaseFirestore.instance.collection("usuarios").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "palavrasEncontradas": FieldValue.arrayUnion([palavra]),
        "pontuacao": FieldValue.increment(pontosGanhos)
      });

      _controllerPage.verificarVitoria(context, _updatePartidaValida, palavrasDoDia, user.palavrasEncontradas);
    }else{
      _controllerPage.mostrarMensagem(context, "Palavra errada! Continue tentando 😉");
    }
  }

  void _handleScroll() {
    double offset = _scrollController.offset;
    double maxOpacityScroll = 200; // Defina a rolagem necessária para desaparecer

    double newOpacity = (1 - (offset / maxOpacityScroll)).clamp(0.0, 1.0);

    setState(() {
      _opacity = newOpacity;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
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
      appBar: _controllerPage.barraMenuMultiplayer(context),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return Scaffold(
    backgroundColor: const Color(0xFFA0D6B6),
    appBar: _controllerPage.barraMenuMultiplayer(context),
    body: user.partidaValida ? jogoUI() : telaFinalUI(),
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

                  AnimatedOpacity(
                    duration: Duration(milliseconds: 100),
                    opacity: _opacity,
                    child: Container(
                            height: 95,
                            margin: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
                            padding: const EdgeInsets.only(left: 25, right: 23, top: 0),
                            decoration: boxAdversarios(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(),
                                  child: player(user.nome, "${user.pontuacao} pontos", true, user.icone),
                                ),
                                SizedBox(
                                  height: 95,
                                  child: VerticalDivider(color: Colors.white, thickness: 1.8),
                                ),
                                DecoratedBox(
                                  decoration: boxDeco(),
                                  child: player(adversario.nome, "${adversario.pontuacao}  pontos", false, adversario.icone),
                                ),
                              ],
                            )
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
                              bool encontrada = user.palavrasEncontradas.contains(palavrasDoDia[wordIndex]);
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
    String mensagemFinal = user.palavrasEncontradas.length == palavrasDoDia.length
        ? "Parabéns! Você acertou todas \nas palavras e ganhou o jogo! 🥇"
        : "Você desistiu da partida e seu adversário venceu com ${adversario.pontuacao} pontos \n\n☹️";

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
          Text("${adversario.pontuacao}  pontos", style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.w800, color: roxo)),
          SizedBox(height: 40),
          Text("Palavras encontradas:", style: GoogleFonts.lato(fontSize: 18)),
          SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            children: user.palavrasEncontradas.map((palavra) {
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
