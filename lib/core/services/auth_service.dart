import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => AppConstants.adminUids.contains(currentUser?.uid);

  // ── Sign Up ────────────────────────────────────────────────
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final user = UserModel(
      uid: uid,
      name: name,
      email: email,
      joinedAt: DateTime.now(),
    );

    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(user.toMap());
    await credential.user!.updateDisplayName(name);

    return user;
  }

  // ── Sign In ────────────────────────────────────────────────
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ── Sign Out ───────────────────────────────────────────────
  Future<void> signOut() async => await _auth.signOut();

  // ── Validate Invite Code ───────────────────────────────────
  Future<bool> validateInviteCode(String code) async {
    final query = await _db
        .collection(AppConstants.inviteCodesCollection)
        .where('code', isEqualTo: code.toUpperCase())
        .where('used', isEqualTo: false)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // ── Get Current User Model ─────────────────────────────────
  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(currentUser!.uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  // ── Password Reset ─────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
