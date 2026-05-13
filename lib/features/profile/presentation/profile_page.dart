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
        .getUser(widget.uid);
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
                  style: TextStyle(
                      color: AppColors.textSecondary)),
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
              if (isOwnProfile)
                RzButton(
                  label: 'SIGN OUT',
                  outline: true,
                  onTap: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) context.go(AppRoutes.landing);
                  },
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
                    Expanded(
                      child: _StatCard(
                        value: user.runsAttended > 0
                            ? (user.totalKm / user.runsAttended)
                                .toStringAsFixed(1)
                            : '0',
                        unit: 'KM/RUN',
                        label: 'AVG PER RUN',
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _StatCard(
                      value: user.totalKm.toStringAsFixed(1),
                      unit: 'KM',
                      label: 'TOTAL EARNED',
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      value: '${user.runsAttended}',
                      unit: '',
                      label: 'RUNS ATTENDED',
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      value: user.runsAttended > 0
                          ? (user.totalKm / user.runsAttended)
                              .toStringAsFixed(1)
                          : '0',
                      unit: 'KM/RUN',
                      label: 'AVG PER RUN',
                    ),
                  ],
                ),

          const SizedBox(height: 40),

          // Info note
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border:
                  Border.all(color: AppColors.primary.withOpacity(0.2), width: 0.5),
            ),
            child: Row(
              children: [
                const Text('✦',
                    style: TextStyle(color: AppColors.primary, fontSize: 16)),
                const SizedBox(width: 12),
                Text(
                  'Each run attended = +${AppConstants.kmPerAttendance.toStringAsFixed(0)} KM added to your total.',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const RzStarDivider(),
          const SizedBox(height: 32),
          _DeepenWellSection(
            user: user,
            isOwnProfile: isOwnProfile,
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

class _DeepenWellSection extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isOwnProfile;
  const _DeepenWellSection(
      {required this.user, required this.isOwnProfile});

  @override
  ConsumerState<_DeepenWellSection> createState() =>
      _DeepenWellSectionState();
}

class _DeepenWellSectionState
    extends ConsumerState<_DeepenWellSection> {
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  bool _searching = false;
  Map<String, dynamic>? _stats;
  String? _error;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.user.deepenwellUsername != null) {
      _usernameCtrl.text = widget.user.deepenwellUsername!;
      _loadStats(widget.user.deepenwellUsername!);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats(String username) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    final stats = await ref
        .read(deepenWellServiceProvider)
        .getUserChallengeStats(username);
    if (mounted) {
      setState(() {
        _stats = stats;
        _searching = false;
        if (stats != null && stats['found'] == false) {
          _error =
              'Username not found in the challenge leaderboard.';
        }
      });
    }
  }

  Future<void> _saveAndLoad() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .updateDeepenWellUsername(widget.user.uid, username);
      await _loadStats(username);
      setState(() => _editMode = false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUsername = widget.user.deepenwellUsername != null &&
        widget.user.deepenwellUsername!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✦ DEEPENWELL CHALLENGE',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'May 1–21 Run & Walk Challenge',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (widget.isOwnProfile)
              GestureDetector(
                onTap: () => setState(() => _editMode = !_editMode),
                child: Text(
                  _editMode ? 'CANCEL' : (hasUsername ? 'EDIT' : 'CONNECT'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Input field (only in edit mode or no username yet)
        if (widget.isOwnProfile &&
            (_editMode || !hasUsername)) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _usernameCtrl,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Enter your Deepenwell full name',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 1),
                    )
                  : RzButton(
                      label: 'CONNECT',
                      onTap: _saveAndLoad,
                    ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your full name exactly as it appears in Deepenwell.',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 20),
        ],

        // Error state
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border:
                  Border.all(color: AppColors.error, width: 0.5),
            ),
            child: Text(_error!,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 13)),
          ),

        // Loading state
        if (_searching)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 1),
            ),
          ),

        // Stats card
        if (_stats != null && _stats!['found'] == true && !_searching)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and position
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stats!['fio'] ?? '',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Deepenwell May Challenge',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Position badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: AppColors.primary.withOpacity(0.1),
                      child: Column(
                        children: [
                          Text(
                            '#${_stats!['position']}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'RANK',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(
                    color: AppColors.border, thickness: 0.5),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _DWStatItem(
                        value: (_stats!['total_distance_km'] as double)
                            .toStringAsFixed(1),
                        unit: 'KM',
                        label: 'TOTAL DISTANCE',
                      ),
                    ),
                    Expanded(
                      child: _DWStatItem(
                        value: _stats!['total_duration'] ?? '—',
                        unit: '',
                        label: 'TOTAL TIME',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DWStatItem(
                        value: (_stats!['total_points'] as num)
                            .toStringAsFixed(0),
                        unit: 'PTS',
                        label: 'POINTS',
                      ),
                    ),
                    Expanded(
                      child: _DWStatItem(
                        value: _stats!['activity_type'] ?? '—',
                        unit: '',
                        label: 'ACTIVITY',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Refresh button
                GestureDetector(
                  onTap: () => _loadStats(
                      widget.user.deepenwellUsername ?? ''),
                  child: const Text(
                    '↻  REFRESH STATS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Not connected state
        if (!hasUsername &&
            !_editMode &&
            !_searching &&
            _stats == null)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.border, width: 0.5),
            ),
            child: const Center(
              child: Text(
                'Connect your Deepenwell account\nto track your May Challenge progress.',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _DWStatItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  const _DWStatItem(
      {required this.value,
      required this.unit,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 2),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: '  $unit',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
