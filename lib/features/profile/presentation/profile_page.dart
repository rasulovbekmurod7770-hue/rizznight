import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../models/models.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ref
        .read(firestoreServiceProvider)
        .getUser(widget.uid)
        .catchError((e) => null);
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile =
        ref.read(authServiceProvider).currentUser?.uid == widget.uid;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return RzScaffold(
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(80),
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 1),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('User not found.',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return _ProfileContent(
            user: snapshot.data!,
            isOwnProfile: isOwnProfile,
            isDesktop: isDesktop,
          );
        },
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserModel user;
  final bool isOwnProfile;
  final bool isDesktop;

  const _ProfileContent({
    required this.user,
    required this.isOwnProfile,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isDesktop ? 80 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _Avatar(name: user.name),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since ${user.joinedAt.year}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const RzStarDivider(),
          const SizedBox(height: 48),

          // Stat cards
          isDesktop
              ? Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: user.totalKm.toStringAsFixed(1),
                        unit: 'KM',
                        label: 'TOTAL EARNED',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        value: '${user.runsAttended}',
                        unit: '',
                        label: 'RUNS ATTENDED',
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : Row(
                  children: [
                    _StatCard(
                      value: user.totalKm.toStringAsFixed(1),
                      unit: 'KM',
                      label: 'TOTAL EARNED',
                    ),
                    const Spacer(),
                    _StatCard(
                      value: '${user.runsAttended}',
                      unit: '',
                      label: 'TOTAL RUNS',
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

          const SizedBox(height: 40),

          // Info note
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2), width: 0.5),
            ),
            child: Row(
              children: [
                const Text('✦',
                    style: TextStyle(color: AppColors.primary, fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Each run attended = +${AppConstants.kmPerAttendance.toStringAsFixed(0)} KM added to your total.',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const RzStarDivider(),
          const SizedBox(height: 32),

          // Sign Out Button properly placed at the bottom of the profile
          if (isOwnProfile)
            Center(
              child: RzButton(
                label: 'SIGN OUT',
                outline: true,
                onTap: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go(AppRoutes.landing);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      width: 72,
      height: 72,
      color: AppColors.primary.withOpacity(0.15),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  const _StatCard(
      {required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: '  $unit',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}