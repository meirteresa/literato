import 'package:flutter/material.dart';
import 'dart:async';
import 'package:literato/utils/decos.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

