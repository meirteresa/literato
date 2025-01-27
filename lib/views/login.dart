import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/functions/decos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
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

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  
  late TapGestureRecognizer _tapGestureRecognizer;

  String? _emailError;
  String? _senhaError;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = _gotocadastro;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  void _gotocadastro(){
    Navigator.pushNamed(context, '/cadastro');
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

  void _validateAndSubmit() async {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _senhaError = _validateSenha(_senhaController.text);
    });

    if (_emailError == null && _senhaError == null) {
      bool loginValido = await verificarLogin(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      if (loginValido) {
        Navigator.pushNamed(context, '/homepage');
      } else {
        setState(() {
          _emailError = 'Email ou senha inválidos.';
          _senhaError = 'Email ou senha inválidos.';
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("login"), backgroundColor: const Color(0xFFF9BF64)),
      backgroundColor: const Color(0xFFA0D6B6),
      resizeToAvoidBottomInset: true,

      body: SingleChildScrollView(
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

              // // Texto de boas-vindas
              // Container(
              //   margin: const EdgeInsets.only(top: 30.0),
              //   child: Stack(
              //     children: <Widget>[
              //       Text('Bem vindo ao', style: textoPrincipal1()),
              //       Text('Bem vindo ao', style: textoPrincipal2()),
              //     ],
              //   ),
              // ),

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
                obscureText: true, 
                cursorColor: Colors.black54,
                decoration: inputDecoration(null, _senhaError, "Senha", Icons.lock_open),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8), 
                ],
              ),
            ),

            ElevatedButton(
              style: botaoEntrar(),
              onPressed: _validateAndSubmit,
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