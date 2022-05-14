import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  const Database();
  static FirebaseAuth get auth {
    return FirebaseAuth.instance;
  }

  static FirebaseFirestore get storage {
    return FirebaseFirestore.instance;
  }
}
