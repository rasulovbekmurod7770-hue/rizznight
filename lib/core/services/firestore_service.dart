import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ── Users ──────────────────────────────────────────────────
  Stream<UserModel> userStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromDoc(doc));
  }

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

  Future<void> claimSlot({
    required String eventId,
    required String userId,
    required String userName,
  }) async {
    final batch = _db.batch();

    // Add slot
    final slotRef = _db.collection(AppConstants.slotsCollection).doc();
    batch.set(
        slotRef,
        SlotModel(
          id: slotRef.id,
          eventId: eventId,
          userId: userId,
          userName: userName,
          claimedAt: DateTime.now(),
        ).toMap());

    // Increment slotsTaken
    final eventRef =
        _db.collection(AppConstants.runEventsCollection).doc(eventId);
    batch.update(eventRef, {'slotsTaken': FieldValue.increment(1)});

    await batch.commit();
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

  Stream<List<SlotModel>> eventSlotsStream(String eventId) {
    return _db
        .collection(AppConstants.slotsCollection)
        .where('eventId', isEqualTo: eventId)
        // .orderBy('claimedAt')
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

    for (final uid in attendedUserIds) {
      final userRef =
          _db.collection(AppConstants.usersCollection).doc(uid);
      batch.update(userRef, {
        'totalKm': FieldValue.increment(AppConstants.kmPerAttendance),
        'runsAttended': FieldValue.increment(1),
      });
    }

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
    final usersSnap = await _db.collection(AppConstants.usersCollection).get();
    double totalKm = 0;
    for (final doc in usersSnap.docs) {
      totalKm += (doc.data()['totalKm'] ?? 0).toDouble();
    }
    return {
      'totalMembers': usersSnap.docs.length,
      'totalKm': totalKm,
    };
  }
}
