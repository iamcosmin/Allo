import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final loginState = StateNotifierProvider<_LoginLogic, String?>((ref) {
  return _LoginLogic();
});

class _LoginLogic extends StateNotifier<String?> {
  _LoginLogic() : super(null);

  Future<bool> checkIfAccountExists(String email) async {
    return await FirebaseAuth.instance
        .fetchSignInMethodsForEmail(email)
        .then((value) {
      if (value.toString() == '[password]') {
        state = email;
        return true;
      } else {
        return false;
      }
    });
  }

  Future<void> login(String password) async {
    if (state != null) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: state!,
        password: password,
      );
    } else {
      throw Exception('There is no email.');
    }
  }
}
