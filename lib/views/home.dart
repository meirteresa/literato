import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/functions/decos.dart';
const amarelo = Color(0xFFF9BF64);
const rosa = Color(0xF4F08484);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6A4),
      appBar: barraMenu(context),

      body: SingleChildScrollView(
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            // Texto1
            Container(
              margin: const EdgeInsets.only(top: 102.0, bottom: 77.0),
              child: Stack(
                children: <Widget>[
                  Text('Escolha o modo de jogo:', style: textoPrincipal1()),
                  Text('Escolha o modo de jogo:', style: textoPrincipal2()),
                ],
              ),
            ),

            SizedBox(
              width: 200.0,
              height: 60.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: corBorda(false)), right: BorderSide(color: corBorda(false)), top: BorderSide.none, left: BorderSide.none),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(3,4),
                      color:Color.fromARGB(255, 252, 200, 116),
                    )
                  ]
                ),
                child: ElevatedButton.icon(
                  style: botaoModoJogo(rosa, false),
                  onPressed:() {
                    Navigator.pushNamed(context, '/individual');
                  }, 
                  icon: const Icon(Icons.person, size:24, color: Color.fromARGB(255, 252, 200, 116)),
                  label: const Text('INDIVIDUAL'),
                ),
              ),
            ),
            
            SizedBox(height: 45),
            
            SizedBox(
              width: 200.0,
              height: 60.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(3,4),
                      color:Color.fromARGB(201, 243, 164, 164),
                    )
                  ]
                ),
                child: ElevatedButton.icon(
                  style: botaoModoJogo(amarelo, true),
                  onPressed:() {
                    Navigator.pushNamed(context, '/multiplayer');
                  }, 
                  icon: const Icon(Icons.people, size:26, color: rosa),
                  label: const Text('MULTIPLAYER'),
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
