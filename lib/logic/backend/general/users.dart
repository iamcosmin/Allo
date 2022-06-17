import 'package:allo/logic/backend/database.dart';

class UserMethods {
  final db = Database.firestore;
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
  Future<Map<String, dynamic>?> getUsernamePairs() async {
    final snapshot =
        await Database.firestore.collection('users').doc('usernames').get();
    return snapshot.data();
  }
}
