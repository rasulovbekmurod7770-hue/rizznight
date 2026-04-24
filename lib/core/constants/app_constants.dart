class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'RIZZNIGHT';
  static const String motto = "WE DON'T RUN. WE RAVE.";
  static const String city = "Tashkent's most competitive running crew";

  // Run Config
  static const int maxSlotsPerRun = 100;
  static const double kmPerAttendance = 3.0;

  // Google Drive
  static const String photosAlbumUrl =
      'https://drive.google.com/drive/folders/1JCk3cvGUliTBaIfDbzNJruGCp62Iv5hr?usp=drive_link';
  static const String photosAlbumLabel = 'VIEW ALL PHOTOS';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String runEventsCollection = 'run_events';
  static const String slotsCollection = 'slots';
  static const String announcementsCollection = 'announcements';
  static const String leaderboardCollection = 'leaderboard';
  static const String waitlistCollection = 'waitlist';
  static const String inviteCodesCollection = 'invite_codes';

  // Admin UIDs — replace with real Firebase UIDs after setup
  static const List<String> adminUids = [
  's88LODbZzDYrndnb9mV7A3GA4sO2',
  'brSn1uSOhKfXpeqP6VjB7GrCYrD2'
];

  // Layout
  static const double maxContentWidth = 1200.0;
  static const double navbarHeight = 64.0;
  static const double sectionPadding = 80.0;
  static const double mobilePadding = 20.0;
  static const double desktopPadding = 80.0;
}
