import 'package:echobot_application/constants/colors.dart';
import 'package:echobot_application/data/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login_Screen extends StatefulWidget {
  final VoidCallback show;


  const Login_Screen({required this.show, super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void initState() {
    super.initState();

    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {

    email.dispose();
    password.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              image(),
              const SizedBox(height: 50),
              textfield(email, _focusNode1, 'Email', Icons.email),
              const SizedBox(height: 10),
              textfield(
                password,
                _focusNode2,
                'Senha',
                Icons.password,
                isPassword: true,
              ),
              const SizedBox(height: 8),
              account(),
              const SizedBox(height: 20),
              Login_bottom(), // SEMANTICS Adicionado no botão Entrar

              const SizedBox(height: 20),
              googleSignInButton(context),
            ],
          ),
        ),
      ),
    );
  }




  Widget account() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Não tem conta?",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: widget.show,

            child: Semantics(
              label: 'Criar Conta',
              hint: 'Toque duas vezes para ir para a tela de cadastro',
              button: true,
              child: Text(
                'Criar Conta',
                style: TextStyle(
                  color: colorDarkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget Login_bottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(

        onTap: () async {
          try {

            await AuthenticationRemote().login(email.text, password.text);


          } on FirebaseAuthException catch (e) {

            String errorMessage = "Erro na credencial. Tente novamente.";

            if (e.code == 'wrong-password' || e.code == 'user-not-found') {
              errorMessage =
              "Credenciais inválidas. Verifique seu e-mail e senha.";
            } else if (e.code == 'too-many-requests') {
              errorMessage =
              "Muitas tentativas falhas. Tente novamente mais tarde.";
            }

            if (mounted) {

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(errorMessage)));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ocorreu um erro inesperado: $e")),
              );
            }
          }
        },

        child: Semantics(
          label: 'Botão Entrar',
          hint: 'Toque duas vezes para realizar o login com email e senha.',
          button: true,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: colorDarkBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Entrar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget googleSignInButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),

      child: Semantics(
        label: 'Entrar com Google',
        button: true,
        child: ElevatedButton.icon(
          onPressed: () async {
            User? user = await AuthenticationRemote().signInWithGoogle();

            if (user != null) {

            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Falha ou cancelamento do Login com Google'),
                  ),
                );
              }
            }
          },

          icon: Image.asset('assets/google.png', height: 25.0),
          label: const Text(
            'Entrar com Google',
            style: TextStyle(fontSize: 18, color: colorDarkBlue),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget textfield(
      TextEditingController _controller,
      FocusNode _focusNode,
      String typeName,
      IconData iconss, {
        bool isPassword = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      child: Semantics(
        label: typeName,
        textField: true,
        obscured: isPassword,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: isPassword,
            style: const TextStyle(fontSize: 18, color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(
                iconss,
                color: _focusNode.hasFocus
                    ? colorDarkBlue
                    : const Color(0xffc5c5c5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              hintText: typeName,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xffc5c5c5),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorDarkBlue, width: 2.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget image() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      child: Semantics(
        label: 'Logo do Echobot, um assistente de voz.',
        image: true,
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/ECHOBOT_LOGO.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}