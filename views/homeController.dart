import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:literato/utils/decos.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class HomeController {
  // Notificador para o ícone dinâmico
  ValueNotifier<String> dynamicIcon = ValueNotifier<String>('padrao.png');
  ValueNotifier<String> userName = ValueNotifier<String>('');
  // Variável para saída do app
  DateTime? lastPressed;

  // Carregar nome do usuário do Firestore
  Future<void> carregarNomeDoUsuario(Function(bool) updateCarregamento) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (doc.exists && doc.data()?['nome'] != null) {
      userName.value = doc.data()!['nome'];
    }

    updateCarregamento(false);
  }

  // Exibir diálogo de confirmação de saída
  dynamic logOut(BuildContext context) {
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
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
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
          menuPadding:
              EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
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
                builder: (BuildContext context) => logOut(context),
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
          style:
              TextStyle(fontSize: 15, color: Colors.purple, fontFamily: 'Lato'),
        ),
      ),
      PopupMenuItem(
        value: "Sair",
        child: Text(
          "Sair da conta",
          style:
              TextStyle(fontSize: 15, color: Colors.purple, fontFamily: 'Lato'),
        ),
      ),
    ];
  }

  Future<bool> sairDoApp(BuildContext context) async {
    if (lastPressed == null ||
        DateTime.now().difference(lastPressed!) > Duration(seconds: 2)) {
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
            title: Text('Sair do Aplicativo',
                style: TextStyle(
                    color: Colors.purple,
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            content: Text('Tem certeza que gostaria de sair do Literato? ☹️',
                style: TextStyle(
                    color: Colors.black54, fontFamily: 'Lato', fontSize: 14)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancelar',
                        style: TextStyle(
                            color: Colors.purple,
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                  TextButton(
                    onPressed: () {
                      FlutterExitApp.exitApp();
                    },
                    child: Text('Sair',
                        style: TextStyle(
                            color: Colors.purple,
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
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
        title: Text("Escolha seu ícone:",
            style: TextStyle(
                color: roxo,
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.w600)),
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

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update({
      'icone': icone,
    });
  }

  // Carregar ícone salvo no Firestore
  Future<void> carregarIconeDoFirestore(
      Function(bool) updateCarregamento) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
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

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .set({
          'latitude': position.latitude,
          'longitude': position.longitude,
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
