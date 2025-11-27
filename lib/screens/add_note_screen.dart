import 'package:echobot_application/data/firestor.dart';
import 'package:flutter/material.dart';
import 'package:echobot_application/constants/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:echobot_application/data/auth.dart';

class Event {
  final String title;
  const Event(this.title);
  @override
  String toString() => title;
}

class Add_creen extends StatefulWidget {
  const Add_creen({super.key});

  @override
  State<Add_creen> createState() => _Add_creenState();
}

class _Add_creenState extends State<Add_creen> {
  final title = TextEditingController();
  final subtitle = TextEditingController();
  final AuthenticationRemote _authRemote = AuthenticationRemote();

  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  int indexx = 0;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;


  bool _isLoadingToken = true;
  String? _currentAccessToken;

  final Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _checkGoogleTokenStatus();
  }

  @override
  void dispose() {
    title.dispose();
    subtitle.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }


  Future<String?> _getGoogleAccessToken() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['https://www.googleapis.com/auth/calendar.events']
    );
    final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      return googleAuth.accessToken;
    }
    return null;
  }

  Future<void> _checkGoogleTokenStatus() async {
    String? token = await _getGoogleAccessToken();
    setState(() {
      _currentAccessToken = token;
      _isLoadingToken = false;
    });
  }


  Future<void> _handleGoogleSignInForCalendar() async {
    try {
      User? user = await _authRemote.signInWithGoogle();

      if (user != null) {
        await _checkGoogleTokenStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login com Google realizado! Agenda autorizada.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login com Google cancelado ou falhou.')),
        );
      }
    } catch (e) {
      print("Erro ao tentar login com Google: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de autenticação: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorDarkBlue,
      body: SafeArea(
        child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Título da Tela com Semantics (para contexto)
                      Semantics(
                        header: true,
                        label: 'Tela de Adicionar Nova Tarefa',
                        child: Text(
                          'Adicionar Tarefa',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorWhite),
                        ),
                      ),
                      const SizedBox(height: 20),
                      title_widgets(),
                      const SizedBox(height: 20),
                      subtite_wedgite(),
                      const SizedBox(height: 20),
                      if (_isLoadingToken)

                         Semantics(
                            label: 'Verificando status de sincronização com Google Calendar',
                            child: Center(child: CircularProgressIndicator(color: Colors.white))
                        )
                      else if (_currentAccessToken != null)
                        calendar_widget()
                      else
                        _buildGoogleLoginPrompt(),
                      const SizedBox(height: 20),
                      button(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }
        ),
      ),
    );
  }


  Widget _buildGoogleLoginPrompt() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [

          Semantics(
            label: 'Instrução para sincronização da agenda',
            child: const Text(
              'Para agendar a tarefa no Google Calendar, faça login para sincronizar a agenda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 15),

          Semantics(
            label: 'Entrar com Google e Autorizar Agenda',
            hint: 'Toque duas vezes para autenticar e permitir a sincronização com Google Calendar.',
            button: true,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(250, 50),
              ),
              onPressed: _handleGoogleSignInForCalendar,
              child: const Text('Entrar com Google e Autorizar Agenda', style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget calendar_widget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TableCalendar<Event>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false, titleCentered: true,
            titleTextStyle: TextStyle(color: colorDarkBlue, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          calendarStyle: CalendarStyle(
            weekendTextStyle: TextStyle(color: Colors.red),
            todayDecoration: BoxDecoration(color: Colors.blue.shade200, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: colorDarkBlue, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }


  Widget button() {

    if (_isLoadingToken) return Container();


    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        Semantics(
          label: 'Botão Adicionar Tarefa',
          hint: 'Salva a tarefa localmente e, se a agenda for autorizada, sincroniza com o Google Calendar.',
          button: true,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(170, 48),
            ),
            onPressed: () async {
              // Lógica de salvar e sincronizar (mantida)
              String eventTitle = title.text;
              String eventDescription = subtitle.text;


              if (_currentAccessToken != null) {
                if (_selectedDay == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecione um dia para sincronizar ou adicione a Task apenas localmente.')),
                  );
                  return;
                }

                DateTime dataSelecionada = _selectedDay!;
                String accessToken = _currentAccessToken!;


                bool success = await _authRemote.createCalendarEventWithDate(
                  accessToken,
                  eventTitle,
                  eventDescription,
                  dataSelecionada,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tarefa sincronizada com Google Calendar e salva localmente!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao sincronizar com Google Calendar. Salva apenas localmente.')),
                  );
                }
              } else {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarefa salva no Firestore. Login no Google necessário para sincronizar com Agenda.')),
                );
              }



              Firestore_Datasource().AddNote(eventDescription, eventTitle, indexx);


              Navigator.pop(context, true);
            },
            child: const Text('Adicionar Task', style: TextStyle(color: Colors.white)),
          ),
        ),

        Semantics(
          label: 'Botão Cancelar',
          hint: 'Toque duas vezes para descartar e voltar à tela inicial.',
          button: true,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(170, 48),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }


  Widget title_widgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      child: Semantics(
        label: 'Título da Tarefa',
        textField: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: title,
            focusNode: _focusNode1,
            style: TextStyle(fontSize: 18, color: Colors.black),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              hintText: 'Título da Tarefa',
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

  Padding subtite_wedgite() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      // Acessibilidade: Semantics para o campo Subtítulo
      child: Semantics(
        label: 'Subtítulo da Tarefa ou Detalhes',
        textField: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            maxLines: 3,
            controller: subtitle,
            focusNode: _focusNode2,
            style: TextStyle(fontSize: 18, color: Colors.black),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              hintText: 'Subtítulo',
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
}