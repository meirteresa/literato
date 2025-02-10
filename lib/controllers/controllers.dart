import 'package:literato/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:literato/views/functions/decos.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';


class UsuarioController {
  final Usuario _user = Usuario();
  Timer? _debounce;

  Future<void> salvarUsuario(BuildContext context, String nome, String email, String senha, Function(String?) updateNomeError, Function(String?) updateEmailError, Function(String?) updateSenhaError) async {
    bool sucesso = await _validateAndSubmit(context, nome, email, senha, updateEmailError, updateNomeError, updateSenhaError);
    if (sucesso) {
      await _user.salvarUsuarionoBanco(nome, email, senha);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário cadastrado com sucesso!")),
      );
      Navigator.pushReplacementNamed(context, '/homepage');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao cadastrar. Tente novamente!")),
      );
    }
  }

  // Função para validar todos os campos
  Future <bool> _validateAndSubmit(BuildContext context, String nome, String email, String senha, Function(String?) updateEmailError, Function(String?) updateNomeError, Function(String?) updateSenhaError) async {
    final nomeError = _validateNome(nome);
    final emailError = _validateEmail(email);
    final senhaError = _validateSenha(senha);

    updateNomeError(null);
    updateEmailError(null);
    updateSenhaError(null);

    if (nomeError == null && emailError == null && senhaError == null) {
      return true;

    } else {
        updateNomeError(nomeError);
        updateSenhaError(senhaError);
        updateEmailError( emailError);
      return false;
    }
  }

  Future<void> _checkEmail(String email, Function(String?) updateEmailError) async {
    updateEmailError(null); // Inicia a verificação e limpa o erro

    try {
      // Consulta o Firestore para verificar se o e-mail já está cadastrado
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        updateEmailError('Este e-mail já está cadastrado.');
      } else {
        updateEmailError(null); // Nenhum erro encontrado
      }
    } catch (e) {
      print("Erro ao verificar e-mail: $e");
      updateEmailError('Erro ao verificar e-mail.');
    }
  }

   void onEmailChanged(String value, Function(String?) updateEmailError) {
    final error = _validateEmail(value);
    if (error == null) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 150), () {
        _checkEmail(value, updateEmailError);
      });
    } else {
      updateEmailError(error);
    }
  }

  // Validação do nome
  String? _validateNome(String nome) {
    if (nome.isEmpty) {
      return 'O nome não pode estar vazio.';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]{1,50}$').hasMatch(nome)) {
      return 'O nome deve conter apenas letras e espaços.';
    }
    return null;
  }

  // Validação do email
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'O email não pode estar vazio.';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return 'Digite um email válido.';
    }
    return null;
  }


  // Validação da senha
  String? _validateSenha(String senha) {
    if (senha.isEmpty) {
      return 'A senha não pode estar vazia.';
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(senha)) {
      return 'A senha deve conter 8 caracteres, uma letra maiúscula, um número e um caractere especial.';
    }
    return null;
  }


  Future<bool> verificarLogin(String email, String senha) async {
    try {
      // Referencie a coleção de usuários
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .where('senha', isEqualTo: senha)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar login: $e');
      return false;
    }
  }

  Future<void> validarLogin(BuildContext context, String email, String senha, Function(String?) updateEmailError, Function(String?) updateSenhaError) async {
    final emailError = _validateEmail(email);
    final senhaError = _validateSenha(senha);

    updateEmailError(null);
    updateSenhaError(null);

    if (emailError == null && senhaError == null) {
      bool loginValido = await verificarLogin(email, senha);

      if (loginValido) {
        Navigator.pushNamed(context, '/homepage');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Não foi possível realizar o login.")),
        );
        updateSenhaError("Email ou senha inválidos");
        updateEmailError("Email ou senha inválidos");
      }
    } else {
        updateSenhaError(senhaError);
        updateEmailError(emailError);
    }
  }
}




class HomeController {
  // Notificador para o ícone dinâmico
  ValueNotifier<String> dynamicIcon = ValueNotifier<String>('padrao.png');

  // Exibir diálogo de confirmação de saída
  dynamic sair(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Deseja sair da conta?'),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Sair'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Appbar home
  dynamic barraMenu(BuildContext context) {
    var barraMenu = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.purple[300], // Navigation bar
        statusBarColor: Colors.purple[300], // Status bar
      ),
      toolbarHeight: 95,
      backgroundColor: Colors.purple[300],
      leading: IconButton(
        padding: EdgeInsets.only(left: 25, right: 0, top: 20, bottom: 20),
        icon: Icon(Icons.help_outline_rounded, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/help');
        },
        iconSize: 34,
      ),
      actions: [
        PopupMenuButton(
          color: Colors.white,
          offset: Offset(0, 62),
          menuPadding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
          padding: EdgeInsets.only(left: 0, right: 25, top: 20, bottom: 20),
          icon: ValueListenableBuilder<String>(
            valueListenable: dynamicIcon,
            builder: (context, iconPath, _) {
              return CircleAvatar(
                backgroundImage: AssetImage('images/$iconPath'),
                radius: 19,
                backgroundColor: Colors.white,
              );
            },
          ),
          onSelected: (value) {
            if (value == "MudarIcone") {
              abrirSelecaoDeIcone(context);
            } else if (value == "Sair") {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => sair(context),
              );
            }
          },
          itemBuilder: (context) => itemBuilder(context),
        ),
      ],
      title: Image.asset('images/logo5.png', fit: BoxFit.fill, height: 68),
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
    );

    return barraMenu;
  }


  // Itens do PopupMenu
  List<PopupMenuEntry<Object?>> itemBuilder(BuildContext context) {
    return [
      PopupMenuItem(
        value: "MudarIcone",
        child: Text(
          "Mudar ícone do perfil",
          style: TextStyle(fontSize: 15, color: Colors.purple, fontFamily: 'Lato'),
        ),
      ),
      PopupMenuItem(
        value: "Sair",
        child: Text(
          "Sair da conta",
          style: TextStyle(fontSize: 15, color: Colors.purple, fontFamily: 'Lato'),
        ),
      ),
    ];
  }

  // Variável para saída do app
  DateTime? lastPressed;

  Future<bool> sairDoApp(BuildContext context) async {
    if (lastPressed == null || DateTime.now().difference(lastPressed!) > Duration(seconds: 2)) {
      lastPressed = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pressione novamente para sair'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            title: Text('Sair do Aplicativo', style: TextStyle(color: Colors.purple, fontFamily: 'Lato', fontSize: 18, fontWeight: FontWeight.w600)),
            content: Text('Tem certeza que gostaria de sair do Literato? ☹️', style: TextStyle(color: Colors.black54, fontFamily: 'Lato', fontSize: 14)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancelar', style: TextStyle(color: Colors.purple, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  TextButton(
                    onPressed: () {
                      FlutterExitApp.exitApp();
                    },
                    child: Text('Sair', style: TextStyle(color: Colors.purple, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
  }

  // Abrir seleção de ícones
  void abrirSelecaoDeIcone(BuildContext context) {
    List<String> iconesDisponiveis = [
      'amarelo.png',
      'azul.png',
      'laranja.png',
      'lilas.png',
      'rosa.png',
      'verde.png',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Escolha seu ícone:", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 18, fontWeight: FontWeight.w600)),
        content: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: iconesDisponiveis.map((icone) {
            return GestureDetector(
              onTap: () {
                dynamicIcon.value = icone;
                salvarIconeNoFirestore(icone);
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/$icone'),
                  backgroundColor: Colors.white,
                  radius: 32,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Salvar ícone no Firestore
  Future<void> salvarIconeNoFirestore(String icone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
      'icone': icone,
    });
  }

  // Carregar ícone salvo no Firestore
  Future<void> carregarIconeDoFirestore(Function(bool) updateCarregamento) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    if (doc.exists && doc.data()?['icone'] != null) {
      dynamicIcon.value = doc.data()!['icone'];
    }

    updateCarregamento(false);
  }

    Future<void> savePlayerLocation(BuildContext context) async {
    try {
      var status = await Permission.location.request();

      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition();

        await FirebaseFirestore.instance.collection('players_waiting').doc(FirebaseAuth.instance.currentUser?.uid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
    });
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao obter localização!")),
      );
    }
  }
}






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

class HelpPageController {
  dynamic barraMenuAjuda(BuildContext context){
    var barraMenu = AppBar(
            toolbarHeight: 80,
            backgroundColor: Colors.purple[300],
            leading: IconButton(
              padding: EdgeInsets.only(left: 25, right: 0, top: 20, bottom: 20),
              icon: Icon(Icons.arrow_back, color: branco),
              onPressed: () => Navigator.of(context).pop(),
              iconSize: 32,
            ),
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
}


class ConnectionController {
  static Future<bool> checaConexao(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isConnected = connectivityResult != ConnectivityResult.none;

    if (!isConnected) {
      showNoConnectionDialog(context);
    }
    
    return isConnected;
  }

  static void showNoConnectionDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: roxo), 
              SizedBox(width: 10),
              Text("Sem conexão", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),

          content: Text("Este aplicativo requer conexão com a internet.", style: TextStyle(color: Colors.black54, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w400)),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); 
                    await checaConexao(context); 
                  },
                  child: Text("Tentar novamente", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Fechar", style: TextStyle(color: roxo, fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ],
             
            ),
          ],
        ),
      );
    });
  }
}


class MultiplayerPageController{
  //app bar multiplayer
  dynamic barraMenuMultiplayer(BuildContext context){
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

  Future<List<Map<String, dynamic>>> getPlayersSearchingMatch(String? userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('players_waiting')
        // .where('timestamp', isGreaterThan: Timestamp.now().seconds - 300) // Últimos 5 minutos
        .get();

    return snapshot.docs
        .where((doc) => doc.id != userId)
        .map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Adiciona o ID do jogador no mapa
          return data;
        })
        .toList();
  }

  Future<double> getDistance(double lat1, double lon1, double lat2, double lon2) async {
    String apiKey = "AIzaSyBpVwMhg7zM5nnOujZutkwm3R7PyldRjFA";
    String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$lat1,$lon1&destinations=$lat2,$lon2&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['rows'][0]['elements'][0]['distance']['value'] / 1000.0; // Convertendo metros para km
    } else {
      throw Exception('Erro ao calcular a distância');
    }
  }

  Future<void> findAndStartMatch(Function(bool) updateCarregamento,) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    double myLat = 0;
    double myLon = 0;

    var userDoc = await FirebaseFirestore.instance
      .collection("players_waiting")
      .doc(userId)
      .get();

    if (userDoc.exists) {
      myLat = userDoc.data()?['latitude'] ?? 0;
      myLon = userDoc.data()?['longitude'] ?? 0;
    }
    
    List<Map<String, dynamic>> players = await getPlayersSearchingMatch(userId);

    if (players.isEmpty) {
      print("Nenhum jogador disponível no momento.");
      return;
    }

    Map<String, dynamic>? closestPlayer;
    double closestDistance = double.infinity;

    for (var player in players) {
      double distance = await getDistance(myLat, myLon, player['latitude'], player['longitude']);

      if (distance < closestDistance) {
        closestDistance = distance;
        closestPlayer = player;
      }
    }

    if (closestPlayer != null) {
      print("Partida encontrada! Jogador mais próximo a $closestDistance km.");
      // Criar a partida no Firebase
      await FirebaseFirestore.instance.collection('matches').add({
        'player1': userId,
        'player2': closestPlayer['id'],
        'created_at': FieldValue.serverTimestamp(),
    });

      // Remover jogadores da fila
      await FirebaseFirestore.instance.collection('players_waiting').doc(userId).delete();
      await FirebaseFirestore.instance.collection('players_waiting').doc(closestPlayer['id']).delete();
    }

    updateCarregamento(false);
  }

  //CARREGAMENTOS DE DADOS

  Future<void> carregarDadosDiarios(Function(List<String>) updateLetras, Function(List<String>) updatePalavrasDoDia) async {
    List<String> letras = [];
    List<String> palavrasDoDia = [];

    String today = DateTime.now().toIso8601String().split("T")[0];
    var doc = await FirebaseFirestore.instance
        .collection("daily_levels_multiplayer")
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
      palavrasEncontradas = List<String>.from(userDoc.data()?['palavrasEncontradasM'] ?? []);
      pontuacao = userDoc.data()?['pontuacaoM'] ?? 0;
      partidaValida = userDoc.data()?['partida_validaM'] ?? true;

      // Se houver palavras encontradas e pelo menos uma não estiver nas palavras do dia, resetar
      if (palavrasEncontradas.isNotEmpty &&
          palavrasEncontradas.any((p) => !palavrasDoDia.contains(p))) {
        palavrasEncontradas = [];
        pontuacao = 0;

        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'palavrasEncontradasM': [],
          'pontuacaoM': 0,
          'partida_validaM': true
        });
      }

      updatePalavrasEncontradas(palavrasEncontradas);
      updatePontuacao(pontuacao);
      updatePartidaValida(partidaValida);
    }
  }

  Future<void> carregarProgressoPartida(
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
      palavrasEncontradas = List<String>.from(userDoc.data()?['palavrasEncontradasM'] ?? []);
      pontuacao = userDoc.data()?['pontuacaoM'] ?? 0;
      partidaValida = userDoc.data()?['partida_validaM'] ?? true;

      // Se houver palavras encontradas e pelo menos uma não estiver nas palavras do dia, resetar
      if (palavrasEncontradas.isNotEmpty &&
          palavrasEncontradas.any((p) => !palavrasDoDia.contains(p))) {
        palavrasEncontradas = [];
        pontuacao = 0;

        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'palavrasEncontradasM': [],
          'pontuacaoM': 0,
          'partida_validaM': true
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
        .collection("daily_levels_multiplayer")
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
    .update({"partida_validaM": false});
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
      await FirebaseFirestore.instance.collection("matches").where("player1", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get().then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

      await FirebaseFirestore.instance.collection("matches").where("player2", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get().then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

      updatePartidaValida(false);
    }
  }
}
