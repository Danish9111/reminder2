import 'package:firebase_auth/firebase_auth.dart';

String? get currentUid {
  return FirebaseAuth.instance.currentUser?.uid;
}
