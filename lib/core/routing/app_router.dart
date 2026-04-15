import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers.dart';
import '../../features/landing/presentation/landing_page.dart';
import '../../features/auth/presentation/login_page.dart';
// import '../../features/auth/presentation/signup_page.dart';
import '../../features/runs/presentation/run_detail_page.dart';
import '../../features/runs/presentation/all_runs_page.dart';
import '../../features/leaderboard/presentation/leaderboard_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/admin/presentation/admin_page.dart';
import '../../features/announcements/presentation/announcements_page.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String runs = '/runs';
  static const String runDetail = '/runs/:id';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile/:uid';
  static const String admin = '/admin';
  static const String announcements = '/announcements';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.landing,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      // Protected routes
      final protectedRoutes = [
        AppRoutes.leaderboard,
        AppRoutes.admin,
        AppRoutes.runs,
      ];

      final isProtected = protectedRoutes.any(
        (r) => state.matchedLocation.startsWith(r),
      );

      if (!isLoggedIn && isProtected) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        builder: (_, __) => const LandingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.runs,
        builder: (_, __) => const AllRunsPage(),
      ),
      GoRoute(
        path: AppRoutes.runDetail,
        builder: (_, state) => RunDetailPage(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (_, __) => const LeaderboardPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, state) => ProfilePage(uid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (_, __) => const AdminPage(),
      ),
      GoRoute(
        path: AppRoutes.announcements,
        builder: (_, __) => const AnnouncementsPage(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          '404 — PAGE NOT FOUND',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ),
    ),
  );
});
