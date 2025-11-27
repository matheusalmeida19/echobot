import 'package:echobot_application/constants/colors.dart';
import 'package:echobot_application/data/firestor.dart';
import 'package:echobot_application/screens/edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:echobot_application/model/notes_model.dart';
import 'package:flutter/services.dart';

class Task_Widget extends StatefulWidget {
  final Note _note;
  const Task_Widget(this._note, {super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {

  // Função para mostrar o diálogo de confirmação de CONCLUSÃO
  Future<void> _showCompleteConfirmationDialog(bool currentStatus) async {
    final newStatus = !currentStatus;

    // O texto da mensagem muda dependendo se estamos marcando ou desmarcando
    final title = newStatus ? "Marcar como Concluída?" : "Marcar como Pendente?";
    final content = newStatus
        ? "Confirma que a tarefa '${widget._note.title}' foi finalizada?"
        : "Deseja reverter o status para pendente?";

    // O rótulo do botão de ação
    final actionButtonText = newStatus ? "CONCLUIR" : "REVERTER";

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              // Confirmação bem-sucedida: Atualiza o status
              HapticFeedback.lightImpact();
              Firestore_Datasource().isdone(widget._note.id, newStatus);
              setState(() {}); // Atualiza o estado visual
              Navigator.pop(ctx);
            },
            child: Text(
                actionButtonText,
                style: TextStyle(
                    color: newStatus ? Colors.green.shade600 : colorDarkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isDone = widget._note.isDon;

    Color cardColor = isDone ? Colors.grey.shade200 : Colors.white;
    Color textColor = isDone ? Colors.grey.shade600 : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Semantics(
        label: "${widget._note.title}, ${widget._note.subtitle}. Status: ${isDone ? 'Concluída' : 'Pendente'}. Toque duas vezes para alterar o status.",
        container: true,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: cardColor,
            border: isDone ? Border.all(color: Colors.transparent) : Border.all(color: colorDarkBlue, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget._note.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget._note.subtitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDone ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildActionButtons(isDone),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // O CHECKBOX GIGANTE (Agora chama a função de confirmação)
                GestureDetector(
                  // 🎯 MUDANÇA PRINCIPAL AQUI:
                  onTap: () {
                    _showCompleteConfirmationDialog(isDone);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDone ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone ? Colors.green : Colors.grey.shade400,
                        width: 3,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 35)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // O restante do código (botões de ação e diálogos de apagar)
  // permanece o mesmo do que eu te enviei anteriormente, garantindo
  // a acessibilidade e segurança dos outros botões.

  // ... (edit_time(), _buildActionButtons(), _buildBadge(), _showDeleteDialog() etc.)
  // Você deve manter as outras funções auxiliares aqui para que o código funcione!

  // Para fins de brevidade, estou omitindo as funções auxiliares neste bloco
  // Mas certifique-se de mantê-las no seu arquivo!

  Widget _buildActionButtons(bool isDone) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildBadge(
            icon: Icons.access_time,
            text: widget._note.time,
            color: colorDarkBlue
        ),
        Semantics(
          label: "Editar tarefa",
          button: true,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Edit_Screen(widget._note)),
              );
            },
            child: _buildBadge(
                icon: Icons.edit,
                text: "Editar",
                color: colorDarkBlue,
                isButton: true
            ),
          ),
        ),
        Semantics(
          label: "Apagar tarefa",
          button: true,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              _showDeleteDialog();
            },
            child: _buildBadge(
                icon: Icons.delete,
                text: "Apagar",
                color: Colors.red.shade700,
                isButton: true
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({required IconData icon, required String text, required Color color, bool isButton = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isButton ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tem certeza?"),
        content: const Text("Você vai apagar esta tarefa permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {
              Firestore_Datasource().delet_note(widget._note.id);
              Navigator.pop(ctx);
            },
            child: const Text("APAGAR", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}