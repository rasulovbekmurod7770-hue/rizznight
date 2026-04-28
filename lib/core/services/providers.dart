import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import '../../models/models.dart';
import '../../core/constants/app_strings.dart';

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
  return ref
      .read(firestoreServiceProvider)
      .eventSlotsStream(eventId)
      .asyncMap(
          (_) => ref.read(firestoreServiceProvider).getRunEvent(eventId));
});

// ── Slots ──────────────────────────────────────────────────────
// ── Slots ──────────────────────────────────────────────────────
final eventSlotsProvider = StreamProvider.family<List<SlotModel>, String>((ref, eventId) {
  return ref.read(firestoreServiceProvider).eventSlotsStream(eventId);
});

// THE FIX: Accept a single String, then split it back into two pieces
final userHasSlotProvider = FutureProvider.family<bool, String>((ref, combinedIds) {
  final parts = combinedIds.split('_');
  return ref.read(firestoreServiceProvider).hasUserClaimedSlot(
        parts[0], // eventId
        parts[1], // userId
      );
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
