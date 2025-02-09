import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/functions/decos.dart';
import 'package:literato/controllers/controllers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UsuarioController _controller = UsuarioController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  
  late TapGestureRecognizer _tapGestureRecognizer;

  String? _emailError;
  String? _senhaError;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = _gotocadastro;
  }

  void _updateEmailError(String? error) {
    setState(() {
      _emailError = error;
    });
  }
  void _updateSenhaError(String? error) {
    setState(() {
      _senhaError = error;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  void _gotocadastro(){
    Navigator.pushNamed(context, '/cadastro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0D6B6),
      resizeToAvoidBottomInset: true,

      body: SingleChildScrollView(
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            //imagem
            Container(
              margin: const EdgeInsets.only(top: 50.0, bottom: 0.0),
              width: 150.0,
              height: 85.0,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: ExactAssetImage('images/logo5.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),

            // texto 2
            Container(
              margin: const EdgeInsets.only(top: 40.0),
              child: Stack(
                children: <Widget>[
                  Text('Faça login para jogar!', style: textoPrincipal1()),
                  Text('Faça login para jogar!', style: textoPrincipal2()),
                ],
              ),
            ),

            //"input" email
            Container(
              margin: const EdgeInsets.only(top: 90.0, bottom: 10.0),
              width: 300.0,
              child: TextField(
                controller: _emailController,
                cursorColor: Colors.black54,
                decoration: inputDecoration(null, _emailError, "Email", Icons.email_outlined),
              ),
            ),

            //"input" senha
            Container(
              margin: const EdgeInsets.only(top: 15.0, bottom: 45.0),
              width: 300.0,
              child: TextField(
                controller: _senhaController,
                obscureText: ! _senhaVisivel, 
                cursorColor: Colors.black54,
                decoration: inputDecoration(
                  null, 
                  _senhaError, 
                  "Senha", 
                  Icons.lock_open,
                  IconButton(
                    icon: Icon(_senhaVisivel 
                      ? Icons.visibility 
                      : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _senhaVisivel = !_senhaVisivel;
                      });
                    },
                  )
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8), 
                ],
              ),
            ),

            ElevatedButton(
              style: botaoEntrar(),
                onPressed: () {
                  final email = _emailController.text;
                  final senha = _senhaController.text;

                  _controller.validarLogin(context, email, senha, _updateEmailError, _updateSenhaError);
                },
              child: const Text('Entrar'),
            ),

            SizedBox(height: 40.0),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Não tem uma conta? ',
                    style: TextStyle(color: Colors.black87, fontSize: 16.0),
                  ),
                  TextSpan(
                    text: 'Inscreva-se.', 
                    style: TextStyle(color: Colors.blue[800], fontSize: 16.0),
                    recognizer: _tapGestureRecognizer,
                  ),
                ],
              ),
            ),

          ],

        ),
      ),
      ),

    );
  }
}
