import 'package:literato/models/models.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:literato/utils/decos.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MultiplayerPageController {
  //app bar multiplayer
  dynamic barraMenuMultiplayer(BuildContext context) {
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
            Navigator.pushNamed(context, '/mapa');
          },
          icon: Icon(Icons.map_outlined, color: branco),
          iconSize: 32,
        ),
      ],
      title: Image.asset('images/logo5.png', fit: BoxFit.fill, height: 68),
      centerTitle: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(0),
      )),
    );

    return barraMenu;
  }

  Future<List<Map<String, dynamic>>> getPlayersSearchingMatch(
      String? userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('buscandoM', isEqualTo: true)
        .get();

    return snapshot.docs.where((doc) => doc.id != userId).map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Adiciona o ID do jogador no mapa
      return data;
    }).toList();
  }

  Future<void> savePlayerLocation(BuildContext context) async {
    try {
      var status = await Permission.location.request();

      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition();

        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .set({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }, SetOptions(merge: true));
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    } catch (e) {
      print("Erro ao obter localização!");
    }
  }

  double getDistance(double lat1, double lon1, double lat2, double lon2) {
    double distancia = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distancia;
  }

  Future<void> findAndStartMatch(BuildContext context) async {
    bool buscandoM;
    String? idAdversario;
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;
    var userDoc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(userId)
        .get();

    if (userDoc.exists) {
      buscandoM = userDoc.data()?['buscandoM'] ?? true;
      idAdversario = userDoc.data()?['id_adversario'] ?? "";
    } else {
      return;
    }

    if (!buscandoM && (idAdversario ?? '') == '') {
      savePlayerLocation(context);
      double myLat = userDoc.data()?['latitude'] ?? 0;
      double myLon = userDoc.data()?['longitude'] ?? 0;

      // 🔍 Busca adversários disponíveis
      List<Map<String, dynamic>> players =
          await getPlayersSearchingMatch(userId);

      if (players.isEmpty) {
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(userId)
            .update({"buscandoM": true});
        return;
      }
      print(players);

      // 🔍 Encontra o jogador mais próximo
      Map<String, dynamic>? closestPlayer;
      double closestDistance = double.infinity;

      for (var player in players) {
        double distance =
            getDistance(myLat, myLon, player['latitude'], player['longitude']);

        if (distance < closestDistance) {
          closestDistance = distance;
          closestPlayer = player;
        }
      }

      if (closestPlayer != null) {
        mostrarMensagem(context,
            "Partida encontrada! Jogador mais próximo a $closestDistance km.");

        // Define a horaFim para meia-noite do dia seguinte
        DateTime now = DateTime.now();
        DateTime midnightTomorrow =
            DateTime(now.year, now.month, now.day + 1, 0, 0, 0);

        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(userId)
            .set({
          'horaFim': Timestamp.fromDate(midnightTomorrow),
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(closestPlayer['id'])
            .set({
          'horaFim': Timestamp.fromDate(midnightTomorrow),
        }, SetOptions(merge: true));

        acao2(userId, closestPlayer['id']);
        acao2(closestPlayer['id'], userId);
      }
    }
  }

  void acao2(String id, String idAdversario) async {
    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(id)
        .update({"buscandoM": false, "id_adversario": idAdversario});
  }

  void updateMensagem(String id, String mensagem) async {
    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(id)
        .update({"mensagem_final": mensagem});
  }

  //CARREGAMENTOS DE DADOS
  Future<void> carregarDadosDiarios(Function(List<String>) updateLetras,
      Function(List<String>) updatePalavrasDoDia) async {
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

  Future<void> carregarProgressoAdversario(
    Function(int, bool, bool, String, String, String?) updateAdversario,
    Function(bool) updateCarregamento,
  ) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    int pontuacao = 0;
    bool partidaValida = true;
    bool win = false;
    String nome = "";
    String icone = "";

    print(userId);
    var userDoc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(userId)
        .get();

    String adversarioId = userDoc.data()?['id_adversario'] ?? "";
    if (adversarioId.isEmpty) {
      print("Nenhum adversário encontrado para este usuário.");
      updateCarregamento(false);
      return;
    }

    var adversarioDoc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(adversarioId)
        .get();
    if (!adversarioDoc.exists) {
      print("O adversário com ID $adversarioId não existe no Firestore.");
      return;
    }

    if (adversarioDoc.exists) {
      pontuacao = adversarioDoc.data()?['pontuacaoM'] ?? 0;
      partidaValida = adversarioDoc.data()?['partida_validaM'] ?? true;
      win = adversarioDoc.data()?['winM'] ?? false;
      nome = adversarioDoc.data()?['nome'] ?? "";
      icone = adversarioDoc.data()?['icone'] ?? "padrao.png";

      updateAdversario(
          pontuacao, partidaValida, win, nome, icone, adversarioId);
    } else {
      print('Nenhuma partida encontrada.');
    }

    updateCarregamento(false);
  }

  Future<void> carregarProgressoUsuario(
    Function(List<String>) updatePalavrasEncontradas,
    Function(int) updatePontuacao,
    Function(bool) updatePartidaValida,
    Function(String, String) updateNomeIcone,
    Function(bool) updatePartidaWin,
    Function(bool) updateBuscandoM,
    List<String> palavrasDoDia,
  ) async {
    var userDoc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    bool buscandoM = userDoc.data()?['buscandoM'] ?? false;

    if (userDoc.exists && buscandoM == false) {
      List<String> palavrasEncontradas = [];
      int pontuacao = 0;
      bool partidaValida = true;
      bool win = false;
      String nome = "";
      String icone = "";

      palavrasEncontradas =
          List<String>.from(userDoc.data()?['palavrasEncontradasM'] ?? []);
      pontuacao = userDoc.data()?['pontuacaoM'] ?? 0;
      win = userDoc.data()?['winM'] ?? false;
      partidaValida = userDoc.data()?['partida_validaM'] ?? true;
      nome = userDoc.data()?['nome'] ?? "";
      icone = userDoc.data()?['icone'] ?? "padrao.png";

      updatePalavrasEncontradas(palavrasEncontradas);
      updatePontuacao(pontuacao);
      updatePartidaValida(partidaValida);
      updateNomeIcone(nome, icone);
      updatePartidaWin(win);
      updateBuscandoM(buscandoM);
    }
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
          title: Text("Parabéns!",
              style: TextStyle(
                  color: roxo,
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          content: Text("Achou todas as palavras! 🥳",
              style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    acao1();
                  },
                  child: Text("Ok",
                      style: TextStyle(
                          color: roxo,
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
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
          title: Text("Confirmação",
              style: TextStyle(
                  color: roxo,
                  fontFamily: 'Lato',
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          content: Text(
              "Não desista agora, seu oponente terá mais chances de vitória 😥",
              style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    acao1();
                  },
                  child: Text("Sim",
                      style: TextStyle(
                          color: roxo,
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Cancelar",
                      style: TextStyle(
                          color: roxo,
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmapontuacao(
      BuildContext context, String palavra, int pontos, bool especial) async {
    String titulo =
        especial ? "🎉 Palavra Especial! 🎉" : "Palavra Encontrada!";
    String mensagem = "\nVocê encontrou a palavra \"$palavra\"";

    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: especial ? Colors.orange : roxo,
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
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
                child: Text("Ok",
                    style: TextStyle(
                        color: roxo,
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

    void updateWinFirestore(String id, bool win) async {
    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(id)
        .update({"winM": win});
    }

  Future<void> verificarVitoria(
      Function(bool) updatePartidaValida,
      Function(bool) updateWin,
      Function(bool) updateCarregamento,
      Function(int, bool, bool, String, String, String?) updateAdversario,
      List<String> palavrasDoDia,
      List<String> palavrasEncontradas,
      Player adversario,
      int meusPontos,
      int pontosAdversario,
      Timestamp? horaFimPartida,
      String idAdversario, bool partidaValida) async {
    carregarProgressoAdversario(updateAdversario, updateCarregamento);
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    DateTime agora = DateTime.now();

    bool adversarioAindaJoga = (await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(idAdversario)
            .get())
        .data()?["partida_validaM"];

    bool Adversariowin = (await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(idAdversario)
            .get())
        .data()?["winM"];

    if(Adversariowin == true && partidaValida == true){
      updateMensagem(
        userId, "Você perdeu. ☹️\nO adversário achou todas as palavras primeiro.");
      updateWinFirestore(userId, false);
      updatePartidaValida(false);
      updateWin(false);
    }

    // Salvar o tempo de finalização do jogador ao terminar todas as palavras
    if (Set<String>.from(palavrasEncontradas).containsAll(palavrasDoDia)) {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userId)
          .update({
        'duracaoM': agora, // Salva o tempo de finalização
      });

      // Se o adversário desistiu, vitória automática
      if (adversarioAindaJoga == false) {
        updateMensagem(
            userId, "Vitória automática! \nO adversário desistiu. 🥳");
        updateWinFirestore(userId, true);
        updatePartidaValida(false);
        updateWin(true);
        return;
      }

      if (adversarioAindaJoga == true &&
          horaFimPartida != null &&
          agora.isBefore(horaFimPartida.toDate())) {
        updateMensagem(userId, "Você venceu! 🥳");
        updateWinFirestore(userId, true);
        updatePartidaValida(false);
        updateWin(true);
        return;
      }

      // Se chegou no horário limite da partida
      if (horaFimPartida != null && agora.isAfter(horaFimPartida.toDate())) {
        if (meusPontos > pontosAdversario) {
          updateMensagem(
              userId, "Você venceu! 🥳\nMais pontos no final do dia.");
          updateWinFirestore(userId, true);
          updateWin(true);
        } else if (meusPontos < pontosAdversario) {
          updateMensagem(
              userId, "Você perdeu. ☹️\nO adversário fez mais pontos.");
          updateWinFirestore(userId, false);
          updateWin(false);
        } else {
          // Empate nos pontos, verificar quem terminou primeiro
          var meuTempoFinal = (await FirebaseFirestore.instance
                  .collection("usuarios")
                  .doc(userId)
                  .get())
              .data()?["duracaoM"];
          var tempoAdversario = (await FirebaseFirestore.instance
                  .collection("usuarios")
                  .doc(idAdversario)
                  .get())
              .data()?["duracaoM"];

          if (meuTempoFinal != null && tempoAdversario != null) {
            DateTime meuTempo = (meuTempoFinal as Timestamp).toDate();
            DateTime adversarioTempo = (tempoAdversario as Timestamp).toDate();

            if (meuTempo.isBefore(adversarioTempo)) {
              updateMensagem(userId,
                  "Empate nos pontos, mas você terminou primeiro!\nVitória! 🥳");
              updateWinFirestore(userId, true);
              updateWin(true);
            } else {
              updateMensagem(userId,
                  "Empate nos pontos, mas o adversário terminou primeiro.\n Você perdeu.☹️");
              updateWinFirestore(userId, false);
              updateWin(false);
            }
          } else {
            updateMensagem(userId,
                "Empate! \nNão foi possível verificar quem terminou primeiro. 😐");
            updateWinFirestore(userId, false);
            updateWin(false);
          }
        }
        updatePartidaValida(false);
        return;
      }
    }
  }

  Future<void> reset(DateTime agora, Timestamp? horaFimPartida) async {
    if (horaFimPartida != null && agora.isAfter(horaFimPartida.toDate())) {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'buscandoM': true,
        'palavrasEncontradasM': [],
        'pontuacaoM': 0,
        'partida_validaM': true,
        'win': false,
        'id_adversario': "",
        'mensagem_final': "",
        'horaFim': FieldValue.delete(),
        'duracaoM': Timestamp.now(),
      });
      return;
    }
  }

  Future<String> getMensagemFinal() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return "";

    String mensagemFinal = (await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(userId)
            .get())
        .data()?["mensagem_final"];

    return mensagemFinal;
  }

  Future<void> desistir(
      BuildContext context,
      Function(bool) updatePartidaValida,
      Function(bool) updateWin,
      Function(bool) updateCarregamento,
      Function(int, bool, bool, String, String, String?) updateAdversario,
      List<String> palavrasDoDia,
      Player adversario,
      int meusPontos,
      int pontosAdversario,
      Timestamp? horaFimPartida,
      String idAdversario) async {
    bool confirmou = await confirmaDesistencia(context);

    if (confirmou) {
      carregarProgressoAdversario(updateAdversario, updateCarregamento);
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      DateTime agora = DateTime.now();

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userId)
          .update({
        'duracaoM': agora, // Salva o tempo de finalização
      });

      bool adversarioAindaJoga = (await FirebaseFirestore.instance
              .collection("usuarios")
              .doc(idAdversario)
              .get())
          .data()?["partida_validaM"];

      if (horaFimPartida != null && agora.isBefore(horaFimPartida.toDate())) {
        // Se o adversário desistiu, vitória automática
        if (adversarioAindaJoga == false) {
          updateMensagem(userId,
              "Vitória automática! \nO adversário desistiu primeiro. 🥳");
          updatePartidaValida(false);
          updateWin(true);
          return;
        }

        if (adversarioAindaJoga == true) {
          updateMensagem(userId,
              "Você desistiu e seu adversário venceu automaticamente! ☹️");
          updatePartidaValida(false);
          updateWin(false);
          return;
        }
      }

      // Se chegou no horário limite da partida
      if (horaFimPartida != null && agora.isAfter(horaFimPartida.toDate())) {
        if (meusPontos > pontosAdversario) {
          updateMensagem(
              userId, "Você venceu! 🥳\nMais pontos no final do dia.");
          updateWin(true);
        } else if (meusPontos < pontosAdversario) {
          updateMensagem(
              userId, "Você perdeu. ☹️\nO adversário fez mais pontos.");
          updateWin(false);
        } else {
          // Empate nos pontos, verificar quem terminou primeiro
          var meuTempoFinal = (await FirebaseFirestore.instance
                  .collection("usuarios")
                  .doc(userId)
                  .get())
              .data()?["duracaoM"];
          var tempoAdversario = (await FirebaseFirestore.instance
                  .collection("usuarios")
                  .doc(idAdversario)
                  .get())
              .data()?["duracaoM"];

          if (meuTempoFinal != null && tempoAdversario != null) {
            DateTime meuTempo = (meuTempoFinal as Timestamp).toDate();
            DateTime adversarioTempo = (tempoAdversario as Timestamp).toDate();

            if (meuTempo.isBefore(adversarioTempo)) {
              updateMensagem(userId,
                  "Empate nos pontos, mas você terminou primeiro!\nVitória! 🥳");
              updateWin(true);
            } else {
              updateMensagem(userId,
                  "Empate nos pontos, mas o adversário terminou primeiro.\n Você perdeu.☹️");
            }
          } else {
            updateMensagem(userId,
                "Empate! \nNão foi possível verificar quem terminou primeiro. 😐");
          }
        }
        return;
      }
    }
  }
}
