import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'deepenwell_service.dart';
import '../constants/app_constants.dart';
import '../../models/models.dart';

export '../../core/constants/app_strings.dart';

// ── Services ───────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// ── Auth State ─────────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) {
  return ref.read(authServiceProvider).getCurrentUserModel();
});

final isAdminProvider = Provider<bool>((ref) {
  // 1. Tell Riverpod to "watch" the login state so this updates dynamically!
  ref.watch(authStateProvider); 
  
  // 2. Now return the admin status
  return ref.read(authServiceProvider).isAdmin;
});

// ── Leaderboard ────────────────────────────────────────────────
final leaderboardProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  return ref.read(firestoreServiceProvider).leaderboardStream();
});

// ── Run Events ─────────────────────────────────────────────────
final runEventsProvider = StreamProvider<List<RunEventModel>>((ref) {
  return ref.read(firestoreServiceProvider).runEventsStream();
});

final nextRunProvider = StreamProvider<RunEventModel?>((ref) {
  return ref.read(firestoreServiceProvider).nextRunStream();
});

final runEventProvider =
    StreamProvider.family<RunEventModel?, String>((ref, eventId) {
  return FirebaseFirestore.instance
      .collection(AppConstants.runEventsCollection)
      .doc(eventId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    try {
      return RunEventModel.fromDoc(doc);
    } catch (e) {
      return null;
    }
  });
});

// ── Slots ──────────────────────────────────────────────────────
// ── Slots ──────────────────────────────────────────────────────
final eventSlotsProvider = StreamProvider.family<List<SlotModel>, String>((ref, eventId) {
  return ref.read(firestoreServiceProvider).eventSlotsStream(eventId);
});

// ── Announcements ──────────────────────────────────────────────
final announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return ref.read(firestoreServiceProvider).announcementsStream();
});

// ── Invite Codes ───────────────────────────────────────────────
final inviteCodesProvider = StreamProvider<List<InviteCodeModel>>((ref) {
  return ref.read(firestoreServiceProvider).inviteCodesStream();
});

// ── Club Stats ─────────────────────────────────────────────────
final clubStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(firestoreServiceProvider).getClubStats();
});

// ── DeepenWell ─────────────────────────────────────────────────
final deepenWellServiceProvider =
    Provider<DeepenWellService>((ref) => DeepenWellService());
