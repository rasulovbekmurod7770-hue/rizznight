import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  DocumentReference<Map<String, dynamic>> get _clubStatsRef => _db
      .collection(AppConstants.metaCollection)
      .doc(AppConstants.clubStatsDocId);

  // ── Users ──────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    return doc.exists ? UserModel.fromDoc(doc) : null;
  }

  // ── Leaderboard ────────────────────────────────────────────
  Stream<List<LeaderboardEntry>> leaderboardStream() {
    return _db
        .collection(AppConstants.usersCollection)
        .orderBy('totalKm', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
      return snap.docs.asMap().entries.map((entry) {
        final user = UserModel.fromDoc(entry.value);
        return LeaderboardEntry(
          uid: user.uid,
          name: user.name,
          photoUrl: user.photoUrl,
          totalKm: user.totalKm,
          runsAttended: user.runsAttended,
          rank: entry.key + 1,
        );
      }).toList();
    });
  }

  // ── Run Events ─────────────────────────────────────────────
  Stream<List<RunEventModel>> runEventsStream() {
    return _db
        .collection(AppConstants.runEventsCollection)
        .where('attendanceMarked', isEqualTo: false)
        .orderBy('date', descending: false)
        .limit(AppConstants.runEventsQueryLimit)
        .snapshots()
        .map((snap) => snap.docs.map(RunEventModel.fromDoc).toList());
  }

  Stream<RunEventModel?> nextRunStream() {
    return _db
        .collection(AppConstants.runEventsCollection)
        .where('attendanceMarked', isEqualTo: false)
        .orderBy('date')
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : RunEventModel.fromDoc(snap.docs.first));
  }

  Stream<RunEventModel?> runEventStream(String eventId) {
    return _db
        .collection(AppConstants.runEventsCollection)
        .doc(eventId)
        .snapshots()
        .map((doc) => doc.exists ? RunEventModel.fromDoc(doc) : null);
  }

  Future<RunEventModel?> getRunEvent(String eventId) async {
    final doc = await _db
        .collection(AppConstants.runEventsCollection)
        .doc(eventId)
        .get();
    return doc.exists ? RunEventModel.fromDoc(doc) : null;
  }

  Future<void> createRunEvent(RunEventModel event) async {
    final data = event.toMap();
    data['attendanceMarked'] = false;
    data['status'] = 'open';
    await _db.collection(AppConstants.runEventsCollection).add(data);
  }

  Future<void> updateRunEvent(String eventId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.runEventsCollection)
        .doc(eventId)
        .update(data);
  }

  // ── Slots ──────────────────────────────────────────────────
  Future<bool> hasUserClaimedSlot(String eventId, String userId) async {
    final query = await _db
        .collection(AppConstants.slotsCollection)
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<List<SlotModel>> getEventSlots(
    String eventId, {
    int limit = AppConstants.eventSlotsPreviewLimit,
  }) async {
    final query = await _db
        .collection(AppConstants.slotsCollection)
        .where('eventId', isEqualTo: eventId)
        .limit(limit)
        .get();
    return query.docs.map(SlotModel.fromDoc).toList();
  }

  Future<void> claimSlot({
    required String eventId,
    required String userId,
    required String userName,
  }) async {
    final eventRef = _db
        .collection(AppConstants.runEventsCollection)
        .doc(eventId);

    await _db.runTransaction((transaction) async {
      // Read the event inside the transaction
      final eventSnap = await transaction.get(eventRef);

      if (!eventSnap.exists) {
        throw Exception('Run event not found.');
      }

      final slotsTaken = eventSnap.data()?['slotsTaken'] ?? 0;
      final totalSlots = eventSnap.data()?['totalSlots'] ?? 100;

      if (slotsTaken >= totalSlots) {
        throw Exception('No slots available.');
      }

      // Check for existing slot INSIDE the transaction
      final existingSlots = await _db
          .collection(AppConstants.slotsCollection)
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingSlots.docs.isNotEmpty) {
        throw Exception('You already have a slot for this run.');
      }

      // All checks passed — create slot and increment counter
      final slotRef = _db.collection(AppConstants.slotsCollection).doc();

      transaction.set(slotRef, {
        'eventId': eventId,
        'userId': userId,
        'userName': userName,
        'claimedAt': FieldValue.serverTimestamp(),
        'attended': false,
      });

      transaction.update(eventRef, {
        'slotsTaken': FieldValue.increment(1),
      });
    });
  }

  Future<void> cancelSlot({
    required String eventId,
    required String userId,
  }) async {
    final query = await _db
        .collection(AppConstants.slotsCollection)
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final batch = _db.batch();
    batch.delete(query.docs.first.reference);

    final eventRef =
        _db.collection(AppConstants.runEventsCollection).doc(eventId);
    batch.update(eventRef, {'slotsTaken': FieldValue.increment(-1)});

    await batch.commit();
  }

  /// Admin attendance only — live listener on all slots for an event.
  Stream<List<SlotModel>> eventSlotsStream(String eventId) {
    return _db
        .collection(AppConstants.slotsCollection)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snap) => snap.docs.map(SlotModel.fromDoc).toList());
  }

  // ── Attendance (Admin) ─────────────────────────────────────
  Future<void> markAttendance({
    required String eventId,
    required List<String> attendedUserIds,
    required List<SlotModel> allSlots,
  }) async {
    final batch = _db.batch();

    for (final slot in allSlots) {
      final attended = attendedUserIds.contains(slot.userId);
      batch.update(
        _db.collection(AppConstants.slotsCollection).doc(slot.id),
        {'attended': attended},
      );
    }

    final kmAwarded =
        attendedUserIds.length * AppConstants.kmPerAttendance;

    for (final uid in attendedUserIds) {
      final userRef =
          _db.collection(AppConstants.usersCollection).doc(uid);
      batch.update(userRef, {
        'totalKm': FieldValue.increment(AppConstants.kmPerAttendance),
        'runsAttended': FieldValue.increment(1),
      });
    }

    batch.set(
      _clubStatsRef,
      {'totalKm': FieldValue.increment(kmAwarded)},
      SetOptions(merge: true),
    );

    batch.update(
      _db.collection(AppConstants.runEventsCollection).doc(eventId),
      {'attendanceMarked': true, 'status': 'completed'},
    );

    await batch.commit();
  }

  // ── Announcements ──────────────────────────────────────────
  Stream<List<AnnouncementModel>> announcementsStream() {
    return _db
        .collection(AppConstants.announcementsCollection)
        .orderBy('pinned', descending: true)
        .orderBy('postedAt', descending: true)
        .limit(AppConstants.announcementsQueryLimit)
        .snapshots()
        .map((snap) => snap.docs.map(AnnouncementModel.fromDoc).toList());
  }

  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    await _db
        .collection(AppConstants.announcementsCollection)
        .add(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection(AppConstants.announcementsCollection).doc(id).delete();
  }

  // ── Invite Codes (Admin) ───────────────────────────────────
  Future<String> generateInviteCode() async {
    final code = _uuid.v4().substring(0, 8).toUpperCase();
    await _db.collection(AppConstants.inviteCodesCollection).add(
          InviteCodeModel(
            id: '',
            code: code,
            createdAt: DateTime.now(),
          ).toMap(),
        );
    return code;
  }

  Stream<List<InviteCodeModel>> inviteCodesStream() {
    return _db
        .collection(AppConstants.inviteCodesCollection)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.inviteCodesQueryLimit)
        .snapshots()
        .map((snap) => snap.docs.map(InviteCodeModel.fromDoc).toList());
  }

  // ── DeepenWell ─────────────────────────────────────────────
  Future<void> updateDeepenWellUsername(
      String uid, String username) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'deepenwellUsername': username});
  }

  // ── Club Stats ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getClubStats() async {
    final doc = await _clubStatsRef.get();
    if (!doc.exists) {
      return {'totalMembers': 0, 'totalKm': 0.0};
    }
    final data = doc.data()!;
    return {
      'totalMembers': data['totalMembers'] ?? 0,
      'totalKm': (data['totalKm'] ?? 0).toDouble(),
    };
  }
}
