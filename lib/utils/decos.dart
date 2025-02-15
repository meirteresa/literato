import 'package:flutter/material.dart';

//cores
const amarelo1 = Color(0xFFFBF6A4);
const amarelo2 = Color.fromARGB(255, 252, 200, 116);
const rosa1 = Color(0xF4F08484);
const rosa2 = Color(0xFFF29985);
const verde = Color(0xFFA0D6B6);
const branco = Color(0xFFFFFFFF);
const transparente = Color(0x00000000);
const amarelo = Color(0xFFF9BF64);
var roxo = Colors.purple[300];

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
                  EdgeInsets.symmetric(horizontal: 25.0, vertical: 18.0),
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
                  const TextStyle(fontSize: 15.0),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
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
          // borderRadius: BorderRadius.vertical(
          //     bottom: Radius.elliptical(150,30)
          //   )
        );
}

dynamic paddingCaixaPontos(bool ehQntd){
   EdgeInsets padding = ehQntd ? EdgeInsets.only(left:30, top: 13, bottom: 13) : EdgeInsets.all(13);
  return padding;
}

//Multiplayer
dynamic boxAdversarios(){
  return BoxDecoration(
          color: roxo,
          border: Border(
            top: BorderSide(color: Colors.white, width: 1.8),
          ),
          // borderRadius: BorderRadius.vertical(
          //     bottom: Radius.elliptical(150,30)
          //   )
        );
}

dynamic player(String nome, String pontuacao, bool ehLeft, String iconPath){
  return Padding(
          padding: playerPadding(ehLeft),
          child: Column(children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: branco,
                  backgroundImage: AssetImage('images/$iconPath'),
                  radius: 15,
                ),

                Padding(
                  padding: EdgeInsets.only(left:10),
                  child: Text(
                    nome, 
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Colors.white,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
              ]
            ),

            Padding(
              padding: pontosPadding(ehLeft),
              child: Text(pontuacao, style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
              ),),
            ),
            
            
          ]),
        );
}

dynamic playerPadding(bool ehLeft){
   EdgeInsets padding = ehLeft ? EdgeInsets.only(left:0, right: 45, top: 15) : EdgeInsets.only(left:35, right: 0, top: 15);
  return padding;
}

dynamic pontosPadding(bool ehLeft){
   EdgeInsets padding = ehLeft ? EdgeInsets.only(left:50, top: 8, bottom: 0) : EdgeInsets.only(right:45, top: 8, bottom: 0);
  return padding;
}
