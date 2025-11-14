import 'package:echobot_application/data/firestor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthenticationDatasource {
  Future<void> register(String email, String password, String PasswordConfirm);
  Future<void> login(String email, String password);
  Future<User?> signInWithGoogle();
}

final GoogleSignIn _googleSignIn = GoogleSignIn();

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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        Firestore_Datasource().CreateUser(userCredential.user?.email ?? '');
      }

      return userCredential.user;
    } catch (e) {
      print("Erro no Login com Google: $e");
      return null;
    }
  }
}
