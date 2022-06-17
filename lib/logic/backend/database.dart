import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  const Database._();
  static FirebaseAuth get auth {
    return FirebaseAuth.instance;
  }

  static FirebaseFirestore get firestore {
    return FirebaseFirestore.instance;
  }
}
