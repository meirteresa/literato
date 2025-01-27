import 'package:flutter/material.dart';
import 'package:literato/views/functions/decos.dart';
const amarelo = Color(0xFFF9BF64);
const rosa = Color(0xF4F08484);

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({super.key});

  @override
  State<MultiplayerPage> createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0D6B6),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            // // Texto de boas-vindas
            // Container(
            //   margin: const EdgeInsets.only(top: 40.0),
            //   child: Stack(
            //     children: <Widget>[
            //       Text('Bem vindo ao', style: textoPrincipal1()),
            //       Text('Bem vindo ao', style: textoPrincipal2()),
            //     ],
            //   ),
            // ),

            //imagem
            Container(
              margin: const EdgeInsets.only(top: 50.0, bottom: 0.0),
              width: 150.0,
              height: 85.0,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: ExactAssetImage('images/logo5.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),

            Text("Jogue com outras pessoas e tente desvendar as 20 palavras secretas do dia!", style: TextStyle(color: Colors.white, fontSize: 16),),


          ],

        ),
      ),

    );
  }
}