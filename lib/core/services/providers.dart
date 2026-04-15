import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../../models/models.dart';

// ── Services ───────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// ── Auth State ─────────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) {
  return ref.read(authServiceProvider).getCurrentUserModel();
});

final isAdminProvider = Provider<bool>((ref) {
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

final runEventProvider = StreamProvider.family<RunEventModel?, String>((ref, eventId) {
  return ref.read(firestoreServiceProvider)
      .eventSlotsStream(eventId)
      .asyncMap((_) => ref.read(firestoreServiceProvider).getRunEvent(eventId));
});

// ── Slots ──────────────────────────────────────────────────────
final eventSlotsProvider = StreamProvider.family<List<SlotModel>, String>((ref, eventId) {
  return ref.read(firestoreServiceProvider).eventSlotsStream(eventId);
});

final userHasSlotProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) {
  return ref.read(firestoreServiceProvider).hasUserClaimedSlot(
    params['eventId']!,
    params['userId']!,
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
