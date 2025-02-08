import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/individual.dart';

//cores
const amarelo1 = Color(0xFFFBF6A4);
const amarelo2 = Color.fromARGB(255, 252, 200, 116);
const rosa1 = Color(0xF4F08484);
const rosa2 = Color(0xFFF29985);
const verde = Color(0xFFA0D6B6);
const branco = Color(0xFFFFFFFF);
const transparente = Color(0x00000000);

//funções
dynamic inputDecoration(String? help, String? erro, String hintText, [IconData? icon]){
  var deco = InputDecoration(
  prefixIcon: icon != null
      ? Padding(
          padding: EdgeInsetsDirectional.only(start: 12.0, end: 10.0),
          child: Icon(icon),
        )
      : null,
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

dynamic sair(BuildContext context){
  var deco = Dialog(
    child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Deseja sair da conta?'),
                    const SizedBox(height: 15),
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
    ),
   );

   return deco;
}

dynamic barraMenu(BuildContext context){
  var barraMenu = AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
         systemNavigationBarColor: Colors.purple[300], // Navigation bar
         statusBarColor: Colors.purple[300], // Status bar
        ),
          toolbarHeight: 95,
          backgroundColor: Colors.purple[300],
          leading: IconButton(
            icon: Icon(Icons.help_outline_rounded, color: branco),
            onPressed: () {},
            iconSize: 32,
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.insert_chart_outlined_rounded, color: branco),
              iconSize: 32,
            ),
            IconButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => sair(context),
              ),
              icon: Icon(Icons.account_circle_sharp, color: branco),
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

dynamic barraMenuIndividual(BuildContext context){
  var barraMenu = AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.purple[300],
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: branco),
            onPressed: () => Navigator.of(context).pop(),
            iconSize: 32,
          ),
          actions: [
            IconButton(
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
