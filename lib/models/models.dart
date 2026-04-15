import 'package:cloud_firestore/cloud_firestore.dart';

// ─── User Model ───────────────────────────────────────────────
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final double totalKm;
  final int runsAttended;
  final bool isAdmin;
  final DateTime joinedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.totalKm = 0,
    this.runsAttended = 0,
    this.isAdmin = false,
    required this.joinedAt,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      photoUrl: d['photoUrl'],
      totalKm: (d['totalKm'] ?? 0).toDouble(),
      runsAttended: d['runsAttended'] ?? 0,
      isAdmin: d['isAdmin'] ?? false,
      joinedAt: (d['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'totalKm': totalKm,
        'runsAttended': runsAttended,
        'isAdmin': isAdmin,
        'joinedAt': Timestamp.fromDate(joinedAt),
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    double? totalKm,
    int? runsAttended,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      totalKm: totalKm ?? this.totalKm,
      runsAttended: runsAttended ?? this.runsAttended,
      isAdmin: isAdmin ?? this.isAdmin,
      joinedAt: joinedAt,
    );
  }
}

// ─── Run Event Model ──────────────────────────────────────────
enum RunEventStatus { upcoming, open, closed, completed }

class RunEventModel {
  final String id;
  final String title;
  final String location;
  final String? locationDetail;
  final DateTime date;
  final int totalSlots;
  final int slotsTaken;
  final RunEventStatus status;
  final String? description;
  final bool attendanceMarked;

  const RunEventModel({
    required this.id,
    required this.title,
    required this.location,
    this.locationDetail,
    required this.date,
    this.totalSlots = 100,
    this.slotsTaken = 0,
    this.status = RunEventStatus.upcoming,
    this.description,
    this.attendanceMarked = false,
  });

  int get slotsAvailable => totalSlots - slotsTaken;
  bool get isFull => slotsTaken >= totalSlots;
  double get fillPercent => slotsTaken / totalSlots;

  factory RunEventModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RunEventModel(
      id: doc.id,
      title: d['title'] ?? '',
      location: d['location'] ?? '',
      locationDetail: d['locationDetail'],
      date: (d['date'] as Timestamp).toDate(),
      totalSlots: d['totalSlots'] ?? 100,
      slotsTaken: d['slotsTaken'] ?? 0,
      status: RunEventStatus.values.firstWhere(
        (s) => s.name == (d['status'] ?? 'upcoming'),
        orElse: () => RunEventStatus.upcoming,
      ),
      description: d['description'],
      attendanceMarked: d['attendanceMarked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'location': location,
        'locationDetail': locationDetail,
        'date': Timestamp.fromDate(date),
        'totalSlots': totalSlots,
        'slotsTaken': slotsTaken,
        'status': status.name,
        'description': description,
        'attendanceMarked': attendanceMarked,
      };
}

// ─── Slot Model ───────────────────────────────────────────────
class SlotModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final DateTime claimedAt;
  final bool attended;

  const SlotModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.claimedAt,
    this.attended = false,
  });

  factory SlotModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SlotModel(
      id: doc.id,
      eventId: d['eventId'] ?? '',
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? '',
      claimedAt: (d['claimedAt'] as Timestamp).toDate(),
      attended: d['attended'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'eventId': eventId,
        'userId': userId,
        'userName': userName,
        'claimedAt': Timestamp.fromDate(claimedAt),
        'attended': attended,
      };
}

// ─── Announcement Model ───────────────────────────────────────
class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final DateTime postedAt;
  final bool pinned;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.postedAt,
    this.pinned = false,
  });

  factory AnnouncementModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      postedAt: (d['postedAt'] as Timestamp).toDate(),
      pinned: d['pinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'postedAt': Timestamp.fromDate(postedAt),
        'pinned': pinned,
      };
}

// ─── Leaderboard Entry ────────────────────────────────────────
class LeaderboardEntry {
  final String uid;
  final String name;
  final String? photoUrl;
  final double totalKm;
  final int runsAttended;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.totalKm,
    required this.runsAttended,
    required this.rank,
  });
}

// ─── Invite Code Model ────────────────────────────────────────
class InviteCodeModel {
  final String id;
  final String code;
  final bool used;
  final String? usedBy;
  final DateTime createdAt;

  const InviteCodeModel({
    required this.id,
    required this.code,
    this.used = false,
    this.usedBy,
    required this.createdAt,
  });

  factory InviteCodeModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return InviteCodeModel(
      id: doc.id,
      code: d['code'] ?? '',
      used: d['used'] ?? false,
      usedBy: d['usedBy'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'code': code,
        'used': used,
        'usedBy': usedBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
