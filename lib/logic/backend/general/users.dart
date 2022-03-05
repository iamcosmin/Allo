import 'package:cloud_firestore/cloud_firestore.dart';

class UserMethods {
  Future<Map<String, dynamic>?> getUsernamePairs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc('usernames')
        .get();
    return snapshot.data();
  }
}
