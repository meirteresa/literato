import 'package:flutter/material.dart';
import 'package:literato/utils/decos.dart';

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

