import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

/// Registers Firebase SDK singletons so features can inject them instead of
/// reaching for `FirebaseAuth.instance` directly (keeps them testable).
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
}
