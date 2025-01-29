import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/functions/decos.dart';
import 'package:google_fonts/google_fonts.dart';

var amarelo = Color(0xFFF9BF64);
var rosa = Color(0xF4F08484);
var roxo = Colors.purple[300];

class IndividualPage extends StatefulWidget {
  const IndividualPage({super.key});

  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  final List<String> words = List.generate(21, (index) => 'Palavra ${index + 1}');

  @override
  Widget build(BuildContext context) {
    int numColumns = 3; // Número fixo de colunas
    int numRows = 7;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.purple[300], 
      systemNavigationBarColor: Colors.purple[300],
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFA0D6B6),
      appBar: barraMenuIndividual(context),

      body: SingleChildScrollView(
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
                      child: pontos("0 pontos", 'Lato', 15, true),
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
                    child: letras('A'),
                  ),
                  SizedBox(
                    height: 52,
                    child: VerticalDivider(color: rosa1, thickness: 2.5),
                  ),
                  DecoratedBox(
                    decoration: boxDeco(),
                    child: letras('B'),
                  ),
                  SizedBox(
                    height: 52,
                    child: VerticalDivider(color: rosa1, thickness: 2.5),
                  ),                  
                  DecoratedBox(
                    decoration: boxDeco(),
                    child: letras('C'),
                  ),
                  SizedBox(
                    height: 52,
                    child: VerticalDivider(color: rosa1, thickness: 2.5),
                  ),                  
                  DecoratedBox(
                    decoration: boxDeco(),
                    child: letras('D'),
                  ),
                  SizedBox(
                    height: 52,
                    child: VerticalDivider(color: rosa1, thickness: 2.5),
                  ),
                  DecoratedBox(
                    decoration: boxDeco(),
                      child: letras('E'),
                  ),
                ],
              )
            ),

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
                      cursorColor: roxo,
                      textCapitalization: TextCapitalization.words,
                      decoration: respostaDeco("Digite aqui"),
                    ),
                  ),
                  SizedBox(
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, size:22, color: amarelo2, fill: 0.1),
                      style: botaoEnviar(),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

            ),

            Container(
              width: 315,
              height: 20,
              margin: const EdgeInsets.only(left: 0, right: 0,top: 40, bottom: 0),
              child: Text("Palavras encontradas: ", style: GoogleFonts.lato(color: roxo, fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),

            //Lista de palavras
            Container(
              padding: EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 0),
              decoration: BoxDecoration(
                border: null,
              ),
              child: Row(
                children: List.generate(numColumns, (colIndex) {
                  return Expanded(
                    child: Column(
                        children: List.generate(numRows, (rowIndex) {
                        int wordIndex = rowIndex * numColumns + colIndex;
                        if (wordIndex < words.length) {
                          return wordBox(words[wordIndex], wordIndex);
                        } else {
                          return SizedBox(width: 100); // Espaço vazio, caso não haja palavra
                        }
                      }),
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: 10),
       

          ],

        ),
        ),
      ),

    );
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
}
