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
final leaderboardProvider = StreamProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.read(firestoreServiceProvider).leaderboardStream();
});

// ── Run Events ─────────────────────────────────────────────────
final runEventsProvider = StreamProvider.autoDispose<List<RunEventModel>>((ref) {
  return ref.read(firestoreServiceProvider).runEventsStream();
});

final nextRunProvider = StreamProvider.autoDispose<RunEventModel?>((ref) {
  return ref.read(firestoreServiceProvider).nextRunStream();
});

final runEventProvider = StreamProvider.autoDispose.family<RunEventModel?, String>((ref, eventId) {
  return ref.read(firestoreServiceProvider).runEventStream(eventId);
});

// ── Slots ──────────────────────────────────────────────────────
// Note: When using .family, autoDispose goes right in the middle!
final eventSlotsProvider = StreamProvider.autoDispose.family<List<SlotModel>, String>((ref, eventId) {
  return ref.read(firestoreServiceProvider).eventSlotsStream(eventId);
});

final userHasSlotProvider = FutureProvider.autoDispose.family<bool, String>((ref, combinedIds) {
  // We split the string back into two pieces
  final parts = combinedIds.split('_'); 
  return ref.read(firestoreServiceProvider).hasUserClaimedSlot(
    parts[0], // eventId
    parts[1], // userId
  );
});

// ── Announcements ──────────────────────────────────────────────
final announcementsProvider = StreamProvider.autoDispose<List<AnnouncementModel>>((ref) {
  return ref.read(firestoreServiceProvider).announcementsStream();
});

// ── Invite Codes ───────────────────────────────────────────────
final inviteCodesProvider = StreamProvider.autoDispose<List<InviteCodeModel>>((ref) {
  return ref.read(firestoreServiceProvider).inviteCodesStream();
});

// ── Club Stats ─────────────────────────────────────────────────
final clubStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.read(firestoreServiceProvider).getClubStats();
});