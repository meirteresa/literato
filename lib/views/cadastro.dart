import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literato/views/functions/decos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';


class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

Future<void> salvarUsuario(String nome, String email, String senha) async {
  try {
    // Criar usuário no Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: senha);

    // Salvar dados adicionais no Firestore
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userCredential.user?.uid) // Salva usando o UID do Firebase
        .set({
      'nome': nome,
      'email': email,
      'senha': senha,
      'data_criacao': Timestamp.now(),
    });

    print("Usuário salvo com sucesso!");
  } catch (e) {
    throw Exception("Erro inesperado: $e");
  }
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  late TapGestureRecognizer _tapGestureRecognizer;

  String? _nomeError;
  String? _emailError;
  String? _senhaError;
  bool _isCheckingEmail = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _gotologin;
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

  Future<void> _checkEmail(String email) async {
    setState(() {
      _isCheckingEmail = true;
      _emailError = null; // Limpa o erro antes de verificar
    });

    try {
      // Consulta o Firestore para verificar se o e-mail já está cadastrado
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _emailError = 'Este e-mail já está cadastrado.';
        });
      }
    } catch (e) {
      print("Erro ao verificar e-mail: $e");
    } finally {
      setState(() {
        _isCheckingEmail = false;
      });
    }
  }

  void _onEmailChanged(String value) {
    final error = _validateEmail(value);
    if (error == null) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 150), () {
        _checkEmail(value);
      });
    } else {
      setState(() {
        _emailError = error;
      });
    }
  }

  // Validação do nome
  String? _validateNome(String nome) {
    if (nome.isEmpty) {
      return 'O nome não pode estar vazio.';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]{1,50}$').hasMatch(nome)) {
      return 'O nome deve conter apenas letras e espaços.';
    }
    return null;
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

  // Função para validar todos os campos
  void _validateAndSubmit() {
    setState(() {
      _nomeError = _validateNome(_nomeController.text);
      _emailError ??= _validateEmail(_emailController.text);
      _senhaError = _validateSenha(_senhaController.text);
    });

    if (_nomeError == null && _emailError == null && _senhaError == null) {
      salvarUsuario(
        _nomeController.text,
        _emailController.text,
        _senhaController.text,
      ).then((_) {
        Navigator.pushNamed(context, '/homepage'); // Navega para a página inicial
      }).catchError((error) {
        print("Erro: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0D6B6),
      body: Center(
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
                  onChanged: _onEmailChanged,
                  decoration: inputDecoration(null, _emailError, "Email", Icons.email_outlined),
                ),
              ),

              // Campo Senha
              Container(
                margin: const EdgeInsets.only(top: 15.0, bottom: 20.0),
                width: 300.0,
                height: 100.0,
                child: TextField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: inputDecoration("Digite uma senha de 8 dígitos, incluindo um número, uma letra maiúscula e um caractere especial", _senhaError, "Senha", Icons.lock_open),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(8), 
                  ],
                ),
              ),

              // Botão de cadastro
              ElevatedButton(
                style: botaoEntrar(),
                onPressed: _validateAndSubmit,
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
                      style: TextStyle(color: Colors.blue[800], fontSize: 16.0),
                      recognizer: _tapGestureRecognizer,
                    ),
                  ],
                ),
              ),
            ],
        ),
      ),
    );
  }
}
