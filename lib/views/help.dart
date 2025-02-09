import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/functions/decos.dart';
import 'package:literato/controllers/controllers.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override

  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>{
  final HelpPageController _controller = HelpPageController();

  @override
  Widget build(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.purple[300], 
      systemNavigationBarColor: Colors.purple[300],
    ));
    return Scaffold(
      backgroundColor: branco,
      appBar: _controller.barraMenuAjuda(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
  
            Container(
              margin: const EdgeInsets.only(top: 20.0, bottom: 10),
              child: Stack(
                children: <Widget>[
                  Text('Ajuda', style: textoPrincipal1()),
                  Text('Ajuda', style: textoPrincipal2()),
                ],
              ),
            ),

            const SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(10),
              decoration: boxDeco(),
              child: Stack(
                children: <Widget> [
                  Text('Sobre o jogo', style: textoPrincipal1(),),
                  Text('Sobre o jogo', style: textoPrincipal2(),),
                ],
              ),
            ),

            const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: boxDeco(),
                child: const Text(
                  'Todo dia você tem 21 palavras novas para descobrir, que variam de pontuação dependendo do tamanho, usando as letras sorteadas. E a cada dia, o jogo começa de novo com letras diferentes para formar palavras novas.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 186, 104, 200),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: boxDeco(),
              child: Stack(
                children: <Widget> [
                  Text('Regras', style: textoPrincipal1(),),
                  Text('Regras', style: textoPrincipal2(),),
                ],
              ),
            ),

              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: boxDeco(),
                child: const Text(
                  '''
1️⃣ Nossa lista de palavras é bem escolhida e limitada, então nem todas as palavras do português vão ser aceitas. 

2️⃣ As palavras precisam ter pelo menos 4 letras. 

3️⃣ Não aceitamos sinais diacríticos, então se a palavra tiver, escreva sem eles. Exemplo: peão vira peao e açao vira acao. 

4️⃣ A maioria dos verbos vai estar no infinitivo, mas alguns também podem aparecer no particípio.

5️⃣ Plurais não são válidos. 

6️⃣ Palavras ofensivas, termos científicos, gírias ou alguns verbos não vão aparecer. 

7️⃣ As letras podem se repetir nas palavras. ''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 186, 104, 200),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: boxDeco(),
              child: Stack(
                children: <Widget> [
                  Text('Sobre o jogo Multiplayer', style: textoPrincipal1(),),
                  Text('Sobre o jogo Multiplayer', style: textoPrincipal2(),),
                ],
              ),
            ),

            const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: boxDeco(),
                child: const Text(
                  '''
1️⃣ Ao entrar no modo multiplayer, você será conectado ao jogador mais próximo disponível.

2️⃣ Todo dia, um novo jogo começa com um conjunto diferente de letras para formar palavras.

3️⃣ Como Vencer? 🏆

O jogador que formar mais palavras corretamente e acumular mais pontos vence.
Se houver empate em pontos, o vencedor será quem terminar primeiro.
Caso um jogador desista, o outro vence automaticamente.
''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 186, 104, 200), 
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
