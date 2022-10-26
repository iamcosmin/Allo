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

class SignupItems {
  const SignupItems({
    required this.email,
    required this.name,
    required this.username,
  });
  final String? email;
  final String? name;
  final String? username;

  factory SignupItems.nullByDefault() {
    return const SignupItems(name: null, username: null, email: null);
  }

  SignupItems copyWith({
    String? email,
    String? name,
    String? username,
  }) {
    return SignupItems(
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}

final signupState =
    StateNotifierProvider.autoDispose<_SignupLogic, SignupItems>((ref) {
  return _SignupLogic();
});

class _SignupLogic extends StateNotifier<SignupItems> {
  _SignupLogic() : super(SignupItems.nullByDefault());

  void addEmail(String? email) => state = state.copyWith(email: email);

  void addName(String? name) => state = state.copyWith(name: name);
  void addUsername(String? username) =>
      state = state.copyWith(username: username);
}
