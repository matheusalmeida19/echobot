import 'package:echobot_application/constants/colors.dart';
import 'package:echobot_application/data/firestor.dart';
import 'package:echobot_application/screens/edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:echobot_application/model/notes_model.dart';

class Task_Widget extends StatefulWidget {
  Note _note;
  Task_Widget(this._note, {super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  @override
  Widget build(BuildContext context) {
    bool isDone = widget._note.isDon;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget._note.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Checkbox(
                          activeColor: colorDarkBlue,
                          value: isDone,
                          onChanged: (value) {
                            setState(() {
                              isDone = !isDone;
                            });
                            Firestore_Datasource().isdone(
                              widget._note.id,
                              isDone,
                            );
                          },
                        ),
                      ],
                    ),
                    Text(
                      widget._note.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Spacer(),
                    edit_time(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget edit_time() {
    // Largura padrão para os botões "Time" e "Editar"
    const double standardWidth = 85;
    // Largura maior para o botão "Apagar" para acomodar o ícone e o texto sem cortar
    const double deleteWidth = 95;
    // Espaçamento uniforme e reduzido entre os botões
    const double spacing = 8;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 1. Botão da Hora
          Container(
            width: standardWidth, // 85 pixels
            height: 28,
            decoration: BoxDecoration(
              color: colorDarkBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Image.asset('assets/icon_time.png'),
                  SizedBox(width: 5),
                  Text(
                    widget._note.time,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: spacing), // Espaçamento: 8
          // 2. Botão de Editar
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Edit_Screen(widget._note),
                ),
              );
            },
            child: Container(
              width: standardWidth, // 85 pixels
              height: 28,
              decoration: BoxDecoration(
                color: colorDarkBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Image.asset('assets/icon_edit.png'),
                    SizedBox(width: 5),
                    Text(
                      'Editar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: spacing), // Espaçamento: 8
          // 3. Botão de Apagar (95 pixels de largura para caber o texto)
          GestureDetector(
            onTap: () {
              // Função de exclusão
              Firestore_Datasource().delet_note(widget._note.id);
            },
            child: Container(
              // Usamos 95 pixels, que é um bom tamanho para a palavra "Apagar"
              width: 95,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(18),
              ),
              // *** MUDANÇA AQUI: Usando Center para alinhamento **
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço
                  children: [
                    Icon(Icons.delete, color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Apagar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
