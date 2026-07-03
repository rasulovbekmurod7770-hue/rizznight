import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'deepenwell_service.dart';
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
  ref.watch(authStateProvider);
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
  return ref.read(firestoreServiceProvider).runEventStream(eventId);
});

// ── Slots ──────────────────────────────────────────────────────
/// Params for [myClaimedSlotProvider].
typedef MyClaimSlotKey = ({String eventId, String userId});

/// One-time check: has this user claimed a slot? (max 1 doc read)
final myClaimedSlotProvider =
    FutureProvider.autoDispose.family<bool, MyClaimSlotKey>((ref, key) {
  if (key.userId.isEmpty) return Future.value(false);
  return ref
      .read(firestoreServiceProvider)
      .hasUserClaimedSlot(key.eventId, key.userId);
});

/// One-time fetch of registered runners for display (bounded by limit).
final eventSlotsPreviewProvider =
    FutureProvider.autoDispose.family<List<SlotModel>, String>((ref, eventId) {
  return ref.read(firestoreServiceProvider).getEventSlots(eventId);
});

/// Admin attendance tab only — live listener on all slots for an event.
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
