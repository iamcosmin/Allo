import 'package:allo/logic/backend/database.dart';

class UserMethods {
  final db = Database.storage;
  Future returnUser({String? uid, String? username}) async {
    if (uid != null) {
      final usernames = await getUsernamePairs();
    } else if (username != null) {
    } else {
      throw Exception('You need to provide either an username or an uid.');
    }
  }

  @Deprecated(
    'This function is deprecated. Please use the new getAllUserIdentification.',
  )
  Future<Map<String, String>> getUsernamePairs() async {
    final snapshot =
        await Database.storage.collection('users').doc('usernames').get();
    if (snapshot.data() is Map<String, String>) {
      // ignore: cast_nullable_to_non_nullable
      return snapshot.data() as Map<String, String>;
    } else {
      throw Exception(
        'The username document should only have strings. Please contact the app administrator.',
      );
    }
  }
}
