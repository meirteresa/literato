// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:literato/models/models.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:literato/utils/decos.dart';

class UsuarioController {
  final Usuario _user = Usuario();
  Timer? _debounce;

  Future<void> salvarUsuario(BuildContext context, String nome, String email, String senha, Function(String?) updateNomeError, Function(String?) updateEmailError, Function(String?) updateSenhaError) async {
    bool sucesso = await _validateAndSubmit(context, nome, email, senha, updateEmailError, updateNomeError, updateSenhaError);
    if (sucesso) {
      await _user.salvarUsuarionoBanco(nome, email, senha);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário cadastrado com sucesso!")),
      );
      Navigator.pushReplacementNamed(context, '/homepage');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao cadastrar. Tente novamente!")),
      );
    }
  }

  // Função para validar todos os campos
  Future <bool> _validateAndSubmit(BuildContext context, String nome, String email, String senha, Function(String?) updateEmailError, Function(String?) updateNomeError, Function(String?) updateSenhaError) async {
    final nomeError = _validateNome(nome);
    final emailError = _validateEmail(email);
    final senhaError = _validateSenha(senha);

    updateNomeError(null);
    updateEmailError(null);
    updateSenhaError(null);

    if (nomeError == null && emailError == null && senhaError == null) {
      return true;

    } else {
        updateNomeError(nomeError);
        updateSenhaError(senhaError);
        updateEmailError( emailError);
      return false;
    }
  }

  Future<void> _checkEmail(String email, Function(String?) updateEmailError) async {
    updateEmailError(null); // Inicia a verificação e limpa o erro

    try {
      // Verifica se há métodos de login vinculados ao e-mail no Firebase Auth
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        updateEmailError('Este e-mail já está cadastrado.');
      } else {
        updateEmailError(null); // Nenhum erro encontrado
      }
    } catch (e) {
      print("Erro ao verificar e-mail: $e");
      updateEmailError('Erro ao verificar e-mail.');
    }
  }

  Future<String> _checkEmail2(String email) async {
    String erro; // Inicia a verificação e limpa o erro

    try {
      // Verifica se há métodos de login vinculados ao e-mail no Firebase Auth
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        erro = "Este e-mail já está cadastrado.";
      } else {
        erro = "";
      }
    } catch (e) {
      erro = "Erro ao verificar e-mail: $e";
      erro = "Erro ao verificar e-mail.";
    }

    return erro;
  }

   void onEmailChanged(String value, Function(String?) updateEmailError) {
    final error = _validateEmail(value);
    if (error == null) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 150), () {
        _checkEmail(value, updateEmailError);
      });
    } else {
      updateEmailError(error);
    }
  }

  void onEmailChanged2(String value, Function(String?) updateEmailError2) async {
    final error = _validateEmail(value);
    if (error == null) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 150), () {
        _checkEmail2(value);
      });
    } else {
      updateEmailError2(error);
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


  Future<bool> verificarLogin(String email, String senha) async {
    try {
      // Tenta autenticar o usuário no Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      return true; // Login bem-sucedido
    } on FirebaseAuthException catch (e) {
      print('Erro ao verificar login: ${e.message}');
      return false; // Falha no login
    }
  }

  dynamic mostrarDialogo(BuildContext context, Function(String?) updateEmailError2, String? error) {
    showDialog(
      context: context,
      builder: (context) => dialogo(context, updateEmailError2, error),
    );
  }

    // Exibir diálogo de confirmação de saída
  Widget dialogo(BuildContext context, Function(String?) updateEmailError2, String? error) {
    final TextEditingController _emailController = TextEditingController();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enviar email de redefinição para: '),
            SizedBox(height: 20),
            Container(
              height: 100,
              child: 
            TextField(
              controller: _emailController,
                onChanged: (value) {
                  onEmailChanged2(value, updateEmailError2);
                },
              decoration: inputDecoration(null, error, "Email", Icons.email_outlined),
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    redefinirSenha(context, _emailController.text);
                  },
                  child: const Text('Confirmar'),
                ),
                TextButton(
                  onPressed: () async {
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
  }


  Future<void> sucesso(BuildContext context, String mensagem) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          content: Text(mensagem,
              style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Ok",
                      style: TextStyle(
                          color: roxo,
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  Future<void> redefinirSenha(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      sucesso(context, "E-mail de redefinição enviado.");
    } on FirebaseAuthException catch (e) {
      print("Erro ao redefinir senha: ${e.message}");
      sucesso(context, "Erro ao enviar e-mail de redefinição.");
    }
  }


  Future<void> validarLogin(BuildContext context, String email, String senha, Function(String?) updateEmailError, Function(String?) updateSenhaError) async {
    final emailError = _validateEmail(email);
    final senhaError = _validateSenha(senha);

    updateEmailError(null);
    updateSenhaError(null);

    if (emailError == null && senhaError == null) {
      bool loginValido = await verificarLogin(email, senha);

      if (loginValido) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: senha);
        Navigator.pushNamed(context, '/homepage');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Não foi possível realizar o login.")),
        );
        updateSenhaError("Email ou senha inválidos");
        updateEmailError("Email ou senha inválidos");
      }
    } else {
        updateSenhaError(senhaError);
        updateEmailError(emailError);
    }
  }
}

