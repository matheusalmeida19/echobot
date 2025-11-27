import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echobot_application/data/firestor.dart';
import 'package:echobot_application/widgets/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback

class Stream_note extends StatelessWidget {
  final bool done; // [Melhoria] Adicionado 'final'
  const Stream_note(this.done, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore_Datasource().stream(done),
      builder: (context, snapshot) {

        // [A11Y] Feedback de Carregamento com Semantics
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(semanticsLabel: "Carregando lista de tarefas..."),
          );
        }

        final noteslist = Firestore_Datasource().getNotes(snapshot);

        // [A11Y] Feedback de Lista Vazia
        if (noteslist.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Text(
                done ? "Nenhuma tarefa concluída." : "Nenhuma tarefa pendente.",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          // [A11Y] Usamos NeverScrollablePhysics para evitar problemas de rolagem dupla
          physics: const NeverScrollableScrollPhysics(),
          itemCount: noteslist.length,
          itemBuilder: (context, index) {
            final note = noteslist[index];

            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart, // Só permite deslizar da direita para a esquerda

              // [A11Y] Feedback visual de perigo (Fundo vermelho com ícone)
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white, size: 30),
              ),

              // [A11Y] Confirmação de segurança: Mostra um pop-up antes de apagar
              confirmDismiss: (direction) async {
                HapticFeedback.mediumImpact(); // Vibração de aviso
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Apagar tarefa?"),
                      content: const Text("Tem certeza que deseja apagar permanentemente?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("CANCELAR", style: TextStyle(fontSize: 16)),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.heavyImpact(); // Vibração forte ao apagar
                            Navigator.of(context).pop(true);
                          },
                          child: const Text("APAGAR", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  },
                );
              },

              onDismissed: (direction) {
                Firestore_Datasource().delet_note(note.id);
              },

              child: Task_Widget(note),
            );
          },
        );
      },
    );
  }
}