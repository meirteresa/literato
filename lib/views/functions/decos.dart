import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/individual.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//cores
const amarelo1 = Color(0xFFFBF6A4);
const amarelo2 = Color.fromARGB(255, 252, 200, 116);
const rosa1 = Color(0xF4F08484);
const rosa2 = Color(0xFFF29985);
const verde = Color(0xFFA0D6B6);
const branco = Color(0xFFFFFFFF);
const transparente = Color(0x00000000);

//funções
dynamic inputDecoration(String? help, String? erro, String hintText, [IconData? icon, IconButton? suffixnIcon]){
  var deco = InputDecoration(
  prefixIcon: icon != null
      ? Padding(
          padding: EdgeInsetsDirectional.only(start: 12.0, end: 10.0),
          child: Icon(icon),
        )
      : null,
    suffixIcon: suffixnIcon,
    hintText: hintText,
    hintStyle: const TextStyle(
      fontSize: 16.0, 
      color: Colors.grey, 
    ),
    helperText: help,
    helperStyle: const TextStyle(
      fontSize: 13.0, 
      color: Colors.black87,
    ),  
    helperMaxLines: 3,

    filled: true,
    fillColor: Colors.white,   
    focusColor: Colors.white, 
    hoverColor: Colors.white,                   
    
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF30BA96)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF30BA96)),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF30BA96)),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF30BA96)),
    ),
    disabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF30BA96)),
    ),
    errorText: erro,
    errorStyle: TextStyle(
      fontSize: 13.0,
      color: Colors.red,
      fontWeight: FontWeight.w300, 
    ),
    errorMaxLines: 3,
  );
  return deco;
}


dynamic textoPrincipal1(){
  var deco = TextStyle(
                fontSize: 18,
                fontFamily: 'CosmicOcto-Medium',
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = const Color.fromARGB(255, 250, 243, 121),
              );

  return deco;
}

dynamic textoPrincipal2(){
  var deco = TextStyle(
                fontSize: 18,
                fontFamily: 'CosmicOcto-Medium',
                color: rosa1,
              );

  return deco;
}

dynamic botaoEntrar(){
  var deco = ButtonStyle(
                elevation: MaterialStateProperty.resolveWith<double>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return 1.5; 
                  } else if (states.contains(MaterialState.pressed)) {
                    return 1.0;
                  }
                  return 0.0;
                }),
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white; // Cor de fundo ao passar o mouse
                  }
                  return Colors.white; // Cor padrão
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Color(0x8A30BA95); // Cor de fundo ao passar o mouse
                  }
                  return Color(0xFF30BA96); // Cor padrão
                }),
                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 16.0),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );

  return deco;
}

dynamic botaoModoJogo(Color cor, bool ehAmarelo){
  var deco = ButtonStyle(
                elevation: MaterialStateProperty.resolveWith<double>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return 0.0; 
                  } else if (states.contains(MaterialState.pressed)) {
                    return 0.0;
                  }
                  return 0.0;
                }),
                padding: MaterialStateProperty.all(
                  EdgeInsets.all(20.0),
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.white; // Cor de fundo ao passar o mouse
                  }
                  return Colors.white; // Cor padrão
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return cor;
                  }
                  return cor; // Cor padrão
                }),

                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 20.0, fontFamily: 'MightySouly', textBaseline: TextBaseline.ideographic),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: corBorda(ehAmarelo),
                    width: 0,
                  ),
                )
              );

  return deco;
}

dynamic corBorda(bool ehAmarelo){
  Color cor = ehAmarelo ? Color.fromARGB(201, 243, 164, 164) : Color.fromARGB(255, 252, 200, 116);
  return cor;
}

//Confirmação no menu da home para SAIR
dynamic sair(BuildContext context){
  var deco = Dialog(
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

   return deco;
}

//app bar home
dynamic barraMenu(BuildContext context){
  var barraMenu = AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
         systemNavigationBarColor: Colors.purple[300], // Navigation bar
         statusBarColor: Colors.purple[300], // Status bar
        ),
          toolbarHeight: 95,
          backgroundColor: Colors.purple[300],
          leading: IconButton(
            padding: EdgeInsets.only(left: 25, right: 0, top: 20, bottom: 20),
            icon: Icon(Icons.help_outline_rounded, color: branco),
            onPressed: () {},
            iconSize: 32,
          ),
          actions: [
            PopupMenuButton(
              color: branco,
              offset: Offset(0, 62),
              menuPadding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
              padding: EdgeInsets.only(left: 0, right: 25, top: 20, bottom: 20),
              icon: Icon(Icons.account_circle_sharp, color: branco, size: 32),
              onSelected: (value) {
                if (value == "MudarIcone") {
                  // Lógica para mudar o ícone
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
            )
          ),
      );

  return barraMenu;
}

List<PopupMenuEntry<Object?>> itemBuilder(BuildContext context) {
  return [
    PopupMenuItem(
      value: "MudarIcone",
      child: Text("Mudar ícone do perfil", 
                  style: TextStyle(
                    fontSize: 15,
                    color: roxo,
                    fontFamily: 'Lato',
                  ),
              ),
    ),
    PopupMenuItem(
      value: "Sair",
      child: Text("Sair da conta", 
                  style: TextStyle(
                    fontSize: 15,
                    color: roxo,
                    fontFamily: 'Lato',
                  ),
              ),
    ),
  ];
}

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
              onPressed: () {},
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

dynamic boxDeco(){
  return BoxDecoration(
          // border: Border(right: BorderSide(color: rosa1)),
          color: transparente,
        );
}

dynamic letrasBox(String letra){
  DecoratedBox(
    decoration: boxDeco(),
    child: decoLetras(letra),
  );
  SizedBox(
    height: 52,
    child: VerticalDivider(color: rosa1, thickness: 2.5),
  );
}

dynamic decoLetras(String letra){
  return Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(letra, style: TextStyle(
            fontSize: 22,
            color: rosa1,
            fontFamily: 'MightySouly',
          ),),
        );
}

dynamic respostaDeco(String hint){
  var deco = InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontSize: 15.0, 
      color: Colors.white70, 
    ),
    
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        width: 3, 
        color: Color.fromARGB(255, 186, 104, 200),
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        width: 3, 
        color: Color.fromARGB(255, 186, 104, 200),
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        width: 3, 
        color: Color.fromARGB(255, 186, 104, 200),
      ),
    ),
    
    // helperText: help,
    // helperStyle: const TextStyle(
    //   fontSize: 13.0, 
    //   color: Colors.black87,
    // ),  
    // helperMaxLines: 3,

    filled: false,
    // fillColor: Colors.white,   
    // focusColor: Colors.white, 
    // hoverColor: Colors.white,                   
    
    // errorText: erro,
    // errorStyle: TextStyle(
    //   fontSize: 13.0,
    //   color: Colors.red,
    //   fontWeight: FontWeight.w300, 
    // ),
    // errorMaxLines: 3,
  );
  return deco;
}

dynamic botaoEnviar(){
  var deco = ButtonStyle(
                elevation: MaterialStateProperty.resolveWith<double>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return 0.0; 
                  } else if (states.contains(MaterialState.pressed)) {
                    return 0.0;
                  }
                  return 0.0;
                }),
                padding: MaterialStateProperty.all(
                  EdgeInsets.all(5.0),
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return rosa1; // Cor de fundo ao passar o mouse
                  }
                  return rosa1; // Cor padrão
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return rosa1;
                  }
                  return rosa1; // Cor padrão
                }),

                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                // side: MaterialStateProperty.all(
                //   BorderSide(
                //     color: corBorda(ehAmarelo),
                //     width: 0,
                //   ),
                // )
              );

  return deco;
}

dynamic pontos(String frase, String fonte, double tamanho, bool ehQntd){
  return Padding(
          padding: paddingCaixaPontos(ehQntd),
          child: Text(frase, style: TextStyle(
            fontSize: tamanho,
            color: Colors.white,
            fontFamily: fonte,
          ),),
        );
}

dynamic boxPontos(){
  return BoxDecoration(
          color: roxo,
          border: Border(
            top: BorderSide(color: Colors.white, width: 1.8),
          ),
          borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(150,30)
            )
        );
}

dynamic paddingCaixaPontos(bool ehQntd){
   EdgeInsets padding = ehQntd ? EdgeInsets.only(left:30, top: 13, bottom: 13) : EdgeInsets.all(13);
  return padding;
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

//Caixa pedindo confirmaçao desistencia
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

//Caixa pedindo confirmaçao desistencia
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

// Caixa de diálogo mostrando a pontuação e se é especial
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

