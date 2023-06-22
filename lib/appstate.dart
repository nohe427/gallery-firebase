import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gallery/firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  late FirebaseAuth auth;
  User? _currentUser;
  User? get currentUser => _currentUser;

  StreamController<bool> _loggedIn = StreamController.broadcast();
  Stream<bool> get loggedIn => _loggedIn.stream;

  Completer<bool> _isLoggedIn = Completer();
  Future<bool> get isLoggedIn => _isLoggedIn.future;

  String test = "blah";
  String get testString => test;

  TextEditingController usernameController =
      TextEditingController(text: 'me@you.com');
  TextEditingController passwordController =
      TextEditingController(text: 'mypassword');

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      _currentUser = auth.currentUser;
      _isLoggedIn.complete(true);
      _loggedIn.add(true);
    } else {
      _currentUser = null;
      _isLoggedIn.complete(false);
      _loggedIn.add(false);
    }

    auth.userChanges().listen((User? user) {
      if (user == null) {
        _currentUser = null;
        _loggedIn.add(false);
      } else {
        _currentUser = user;
        _loggedIn.add(true);
      }
      notifyListeners();
    });
  }

  Future<UserCredential> signIn() async {
    return auth.signInWithEmailAndPassword(
        email: usernameController.text, password: passwordController.text);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
