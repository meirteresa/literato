import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/utils/decos.dart';
import 'package:literato/controllers/usuarioController.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final UsuarioController _controller = UsuarioController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  late TapGestureRecognizer _tapGestureRecognizer;

  String? _nomeError;
  String? _emailError;
  String? _senhaError;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _gotologin;
  }

  void _updateNomeError(String? error) {
    setState(() {
      _nomeError = error;
    });
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
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _gotologin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0D6B6),

      body: SingleChildScrollView(
        child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              // Imagem
              Container(
                margin: const EdgeInsets.only(top: 50.0, bottom: 0.0),
                width: 150.0,
                height: 85.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage('images/logo5.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              // Texto de inscrição
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Stack(
                  children: <Widget>[
                    Text('Inscreva-se para jogar!', style: textoPrincipal1()),
                    Text('Inscreva-se para jogar!', style: textoPrincipal2()),
                  ],
                ),
              ),

              // Campo Nome
              Container(
                margin: const EdgeInsets.only(top: 80.0, bottom: 10.0),
                width: 300.0,
                child: TextField(
                  controller: _nomeController,
                  decoration: inputDecoration(null, _nomeError, "Nome", Icons.person_rounded),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
                  ],
                ),
              ),

              // Campo Email
              Container(
                margin: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                width: 300.0,
                child: TextField(
                  controller: _emailController,
                  onChanged: (value) {
                    _controller.onEmailChanged(value, _updateEmailError);
                  },
                  decoration: inputDecoration(null, _emailError, "Email", Icons.email_outlined),
                ),
              ),

              // Campo Senha
              Container(
                margin: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                width: 300.0,
                height: 150.0,
                child: TextField(
                  controller: _senhaController,
                  obscureText: ! _senhaVisivel, 
                  cursorColor: Colors.black54,
                  decoration: inputDecoration(
                    "Digite uma senha de 8 dígitos, incluindo um número, uma letra maiúscula e um caractere especial", 
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

              // Botão de cadastro
              ElevatedButton(
                style: botaoEntrar(),
                onPressed: () {
                  final nome = _nomeController.text;
                  final email = _emailController.text;
                  final senha = _senhaController.text;

                  _controller.salvarUsuario(context, nome, email, senha, _updateNomeError, _updateEmailError, _updateSenhaError);
                },
                child: const Text('Cadastrar'),
              ),

              const SizedBox(height: 40.0),

              // Link para login
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Já tem uma conta? ',
                      style: TextStyle(color: Colors.black87, fontSize: 16.0),
                    ),
                    TextSpan(
                      text: 'Faça login.',
                      style: TextStyle(color: Colors.blue[800], fontSize: 16.0, fontWeight: FontWeight.w500),
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
