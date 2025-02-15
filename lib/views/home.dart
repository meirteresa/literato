import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/controllers/connectionController.dart';
import 'package:literato/utils/decos.dart';
import 'package:literato/controllers/homeController.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controllerPage = HomeController();
  DateTime? lastPressed;
  bool isLoading = true;

  void _updateCarregamento(bool carregamento) {
    setState(() {
      isLoading = carregamento;
    });
  }

  @override
  void initState() {
    super.initState();
    ConnectionController.checaConexao(context);
    setState(() {
      _controllerPage.carregarIconeDoFirestore(_updateCarregamento);
      _controllerPage.carregarNomeDoUsuario(_updateCarregamento);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFA0D6B6),
        appBar: _controllerPage.barraMenu(context),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        bool shouldExit = await _controllerPage.sairDoApp(context);
        if (shouldExit) FlutterExitApp.exitApp();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF6A4),
        appBar: _controllerPage.barraMenu(context),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ValueListenableBuilder<String>(
                  valueListenable: _controllerPage.userName,
                  builder: (context, userName, _) {
                    return Container(
                      margin: const EdgeInsets.only(top: 60.0),
                      padding: const EdgeInsets.all(12.0),
                      child:
                          Text('✴ Olá, $userName! ✴', style: textoPrincipal2()),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(top: 70.0, bottom: 35.0),
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
                      border: Border(
                          bottom: BorderSide(color: corBorda(false)),
                          right: BorderSide(color: corBorda(false)),
                          top: BorderSide.none,
                          left: BorderSide.none),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(3, 4),
                          color: Color.fromARGB(255, 252, 200, 116),
                        )
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: botaoModoJogo(rosa1, false),
                      onPressed: () {
                        Navigator.pushNamed(context, '/individual');
                      },
                      icon: const Icon(Icons.person,
                          size: 24, color: Color.fromARGB(255, 252, 200, 116)),
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
                          offset: Offset(3, 4),
                          color: Color.fromARGB(201, 243, 164, 164),
                        )
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: botaoModoJogo(amarelo, true),
                      onPressed: () {
                        Navigator.pushNamed(context, '/multiplayer');
                      },
                      icon: const Icon(Icons.people, size: 26, color: rosa1),
                      label: const Text('MULTIPLAYER'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
