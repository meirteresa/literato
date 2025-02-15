import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:literato/models/models.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MapaController {
  double _roundCoordinate(double value, int decimals) {
    double mod = pow(10.0, decimals) as double;
    return ((value * mod).roundToDouble()) / mod;
  }

  Future<List<Map<String, dynamic>>> getPlayersLocation() async {
    QuerySnapshot playersSnapshot =
        await FirebaseFirestore.instance.collection('usuarios').get();

    // Convertendo os documentos do Firestore para uma lista de mapas
    List<Map<String, dynamic>> playersList = playersSnapshot.docs
        .map((doc) {
          var data = doc.data() as Map<String, dynamic>;

          return {
            'id': doc.id,
            'nome': data['nome'] ?? 'Anônimo',
            'latitude': _roundCoordinate(data['latitude'] ?? 0.0, 2),
            'longitude': _roundCoordinate(data['longitude'] ?? 0.0, 2),
            'partidaIniciada': (data['palavrasEncontradasM']?.length ?? 0) > 0,
            'ganhou': (data['palavrasEncontradasM']?.length ?? 0) == 21,
            'desistiu': !(data['partida_validaM'] ?? false) &&
                (data['palavrasEncontradasM']?.length ?? 0) < 21,
          };
        })
        .where((player) => player['partidaIniciada'])
        .toList();

    return playersList;
  }
}
