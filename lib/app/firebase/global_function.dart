import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;
User? get user => auth.currentUser;