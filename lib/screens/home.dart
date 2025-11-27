import 'package:echobot_application/constants/colors.dart';
import 'package:echobot_application/screens/add_note_screen.dart';
import 'package:echobot_application/widgets/stream_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:echobot_application/data/auth.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import necessário para tratar FirebaseAuthException do app

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}


class _Home_ScreenState extends State<Home_Screen> {

  bool show = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorDarkBlue,

      appBar: AppBar(

        title: const Text(
            'Echobot - Tarefas',
            style: TextStyle(color: Colors.white)
        ),
        backgroundColor: colorDarkBlue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),

            tooltip: 'Sair da Conta',
            onPressed: () async {
              try {
                await AuthenticationRemote().signOutUser();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                      (Route<dynamic> route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Falha ao sair. Tente novamente.')),
                );
              }
            },
          ),
        ],
      ),

      floatingActionButton: Visibility(
        visible: show,
        child: Semantics(
          label: 'Botão Adicionar Nova Tarefa',
          hint: 'Toque duas vezes para criar uma nova anotação ou tarefa.',
          button: true,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Add_creen()),
              );
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              setState(() {
                show = true;
              });
            }
            if (notification.direction == ScrollDirection.reverse) {
              setState(() {
                show = false;
              });
            }
            return true;
          },

          child: SingleChildScrollView(
            child: Column(
              children: [
                Stream_note(false),

                Semantics(
                  label: 'Seção de tarefas pendentes.',
                  header: true,
                  child: Text(
                    'Coleção de Tarefas',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Stream_note(true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}