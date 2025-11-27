import 'package:echobot_application/constants/colors.dart';
import 'package:echobot_application/data/auth.dart';
import 'package:flutter/material.dart';
import 'package:echobot_application/auth/auth_page.dart';

class SignUp_Screen extends StatefulWidget {
  final VoidCallback show;

  const SignUp_Screen(this.show, {super.key});

  @override
  State<SignUp_Screen> createState() => _SignUp_ScreenState();
}

class _SignUp_ScreenState extends State<SignUp_Screen> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
  final PasswordConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
      setState(() {});
    });
    _focusNode3.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    PasswordConfirm.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
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
              SizedBox(height: 20),
              image(),
              SizedBox(height: 50),
              textfield(email, _focusNode1, 'Email', Icons.email),
              SizedBox(height: 10),

              textfield(password, _focusNode2, 'Senha', Icons.password, isPassword: true),
              SizedBox(height: 10),

              textfield(
                PasswordConfirm,
                _focusNode3,
                'Confirmar Senha',
                Icons.password,
                isPassword: true,
              ),
              SizedBox(height: 8),
              account(),
              SizedBox(height: 20),
              SignUP_bottom(),
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
            "Você já tem uma conta?",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: widget.show,
            //  Acessibilidade: Semantics para o botão Entrar (alternar tela)
            child: Semantics(
              label: 'Botão Entrar',
              hint: 'Toque duas vezes para ir para a tela de login.',
              button: true,
              child: Text(
                'Entrar',
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

  Widget SignUP_bottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: () {

          AuthenticationRemote().register(
            email.text,
            password.text,
            PasswordConfirm.text,
          );
        },

        child: Semantics(
          label: 'Botão Criar Conta',
          hint: 'Toque duas vezes para finalizar o cadastro.',
          button: true,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: colorDarkBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Criar conta',
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
            // Usando o parâmetro isPassword
            obscureText: isPassword,
            style: TextStyle(fontSize: 18, color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(
                iconss,
                color: _focusNode.hasFocus ? colorDarkBlue : Color(0xffc5c5c5),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              hintText: typeName,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xffc5c5c5), width: 2.0),
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
          decoration: BoxDecoration(
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
