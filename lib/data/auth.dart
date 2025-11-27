import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:echobot_application/data/firestor.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart' as calendar;



class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _innerClient = http.Client();

  GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {

    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _innerClient.send(request);
  }
}


abstract class AuthenticationDatasource {
  Future<void> register(String email, String password, String PasswordConfirm);
  Future<void> login(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> signOutUser();
}


final List<String> _calendarScopes = <String>[
  'email',
  'https://www.googleapis.com/auth/calendar.events',
];

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _calendarScopes);



class AuthenticationRemote extends AuthenticationDatasource {


  @override
  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception("Erro desconhecido durante o login: $e");
    }
  }


  @override
  Future<void> register(
      String email,
      String password,
      String PasswordConfirm,
      ) async {
    if (PasswordConfirm == password) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      )
          .then((value) {
        Firestore_Datasource().CreateUser(email);
      });
    }
  }


  @override
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        Firestore_Datasource().CreateUser(userCredential.user?.email ?? '');
      }
      return userCredential.user;
    } catch (e) {
      print("Erro no Login com Google: $e");
      return null;
    }
  }

  @override
  Future<void> signOutUser() async {
    try {

      await _googleSignIn.signOut();


      await FirebaseAuth.instance.signOut();

      print("Usuário deslogado com sucesso.");

    } catch (e) {
      print("Erro ao deslogar: $e");

      throw e;
    }
  }

  // Criação de Evento no Google Calendar
  Future<bool> createCalendarEventWithDate(
      String accessToken,
      String eventTitle,
      String eventDescription,
      DateTime selectedDate,
      ) async {
    try {
      final client = GoogleAuthClient(accessToken);
      final calendarApi = calendar.CalendarApi(client);

      final start = calendar.EventDateTime(dateTime: selectedDate);
      final end = calendar.EventDateTime(dateTime: selectedDate.add(const Duration(hours: 1)));

      final event = calendar.Event(
        summary: eventTitle,
        description: eventDescription,
        start: start,
        end: end,
      );

      await calendarApi.events.insert(event, 'primary');
      return true;
    } catch (e) {
      print('❌ Erro ao criar evento no calendário: $e');
      return false;
    }
  }
}