import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/providers.dart';
import '../../../models/models.dart';
import 'package:intl/intl.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RzScaffold(
      body: Column(
        children: [
          _HeroSection(),
          _NextRunSection(),
          _StatsStrip(),
          _AnnouncementsSection(),
          _LeaderboardPreview(),
          _PhotosSection(),
          _DriveSection(),
        ],
      ),
    );
  }
}

// ── Hero Section ───────────────────────────────────────────────
class _HeroSection extends ConsumerWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider).valueOrNull != null;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 600),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Stack(
        children: [
          // Grid pattern background
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Star
                  const Text(
                    '✦',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Motto
                  Text(
                    "WE DON'T RUN.",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isDesktop ? 88 : 48,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'WE RAVE.',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: isDesktop ? 88 : 48,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "TASHKENT'S MOST COMPETITIVE RUNNING CREW",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  RzButton(
                    label: isLoggedIn ? 'CLAIM YOUR SPOT' : 'SIGN UP',
                    onTap: () => isLoggedIn
                        ? context.go(AppRoutes.runs)
                        : context.go(AppRoutes.signup),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.04)
      ..strokeWidth = 0.5;

    const step = 50.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Next Run Section ───────────────────────────────────────────
class _NextRunSection extends ConsumerWidget {
  const _NextRunSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextRun = ref.watch(nextRunProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isDesktop ? AppConstants.desktopPadding : AppConstants.mobilePadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: nextRun.when(
        loading: () => const _SectionSkeleton(),
        error: (_, __) => const SizedBox.shrink(),
        data: (run) {
          if (run == null) {
            return const Center(
              child: Column(
                children: [
                   RzSectionHeader(title: 'NEXT RUN'),
                   SizedBox(height: 16),
                   Text(
                    'No upcoming runs announced yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return _NextRunCard(run: run);
        },
      ),
    );
  }
}

class _NextRunCard extends ConsumerWidget {
  final RunEventModel run;
  const _NextRunCard({required this.run});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final dateStr = DateFormat('EEEE, MMM d · HH:mm').format(run.date);
    final fillPercent = run.fillPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RzSectionHeader(title: 'NEXT RUN'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.5),
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _RunInfo(run: run, dateStr: dateStr)),
                    const SizedBox(width: 60),
                    _SlotWidget(run: run, fillPercent: fillPercent),
                  ],
                )
              : Column(
                  children: [
                    _RunInfo(run: run, dateStr: dateStr),
                    const SizedBox(height: 24),
                    _SlotWidget(run: run, fillPercent: fillPercent),
                  ],
                ),
        ),
      ],
    );
  }
}

class _RunInfo extends StatelessWidget {
  final RunEventModel run;
  final String dateStr;
  const _RunInfo({required this.run, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          run.title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 14),
            const SizedBox(width: 8),
            Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 14),
            const SizedBox(width: 8),
            Text(run.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        if (run.description != null) ...[
          const SizedBox(height: 16),
          Text(
            run.description!,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
        const SizedBox(height: 20),
        RzButton(
          label: run.isFull ? 'JOIN WAITLIST' : 'GRAB A SLOT',
          onTap: () => context.go('/runs/${run.id}'),
        ),
      ],
    );
  }
}

class _SlotWidget extends StatelessWidget {
  final RunEventModel run;
  final double fillPercent;
  const _SlotWidget({required this.run, required this.fillPercent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${run.slotsTaken}',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 64,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        Text(
          'OF ${run.totalSlots} SLOTS TAKEN',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 160,
          child: ClipRRect(
            child: LinearProgressIndicator(
              value: fillPercent,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                fillPercent > 0.8 ? AppColors.error : AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          run.isFull ? 'SOLD OUT' : '${run.slotsAvailable} SPOTS LEFT',
          style: TextStyle(
            color: run.isFull ? AppColors.error : AppColors.success,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Stats Strip ────────────────────────────────────────────────
class _StatsStrip extends ConsumerWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(clubStatsProvider);
    final leaderboard = ref.watch(leaderboardProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    final fastestPace = leaderboard.valueOrNull?.isNotEmpty == true
        ? '${leaderboard.valueOrNull!.first.totalKm.toStringAsFixed(0)} KM'
        : '—';

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 28,
        horizontal: isDesktop ? AppConstants.desktopPadding : AppConstants.mobilePadding,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: stats.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (s) => Wrap(
          spacing: 60,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _StatItem(value: '${s['totalMembers']}', label: 'ACTIVE RUNNERS'),
            _StatItem(value: '${(s['totalKm'] as double).toStringAsFixed(0)} KM', label: 'TOTAL CLUB KM'),
            _StatItem(value: fastestPace, label: 'LEADER THIS WEEK'),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Announcements Section ──────────────────────────────────────
class _AnnouncementsSection extends ConsumerWidget {
  const _AnnouncementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isDesktop ? AppConstants.desktopPadding : AppConstants.mobilePadding,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: announcements.when(
        loading: () => const _SectionSkeleton(),
        error: (_, __) => const SizedBox.shrink(),
        data: (list) {
          if (list.isEmpty) return const SizedBox.shrink();
          final preview = list.take(3).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const RzSectionHeader(title: 'ANNOUNCEMENTS'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.announcements),
                    child: const Text(
                      'VIEW ALL →',
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
              const SizedBox(height: 24),
              ...preview.map((a) => _AnnouncementCard(announcement: a)),
            ],
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(
            color: announcement.pinned ? AppColors.primary : AppColors.border,
            width: announcement.pinned ? 2 : 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  announcement.body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat('MMM d').format(announcement.postedAt),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Leaderboard Preview ────────────────────────────────────────
class _LeaderboardPreview extends ConsumerWidget {
  const _LeaderboardPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isDesktop ? AppConstants.desktopPadding : AppConstants.mobilePadding,
      ),
      color: AppColors.surface,
      child: leaderboard.when(
        loading: () => const _SectionSkeleton(),
        error: (_, __) => const SizedBox.shrink(),
        data: (entries) {
          final top3 = entries.take(3).toList();
          if (top3.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const RzSectionHeader(title: 'LEADERBOARD', subtitle: 'Ranked by total KM earned'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.leaderboard),
                    child: const Text(
                      'FULL BOARD →',
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
              const SizedBox(height: 32),
              isDesktop
                  ? Row(
                      children: top3
                          .map((e) => Expanded(child: _PodiumCard(entry: e)))
                          .toList(),
                    )
                  : Column(
                      children: top3.map((e) => _PodiumCard(entry: e)).toList(),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final LeaderboardEntry entry;
  const _PodiumCard({required this.entry});

  Color get medalColor {
    switch (entry.rank) {
      case 1: return AppColors.gold;
      case 2: return AppColors.silver;
      case 3: return AppColors.bronze;
      default: return AppColors.textMuted;
    }
  }

  String get medal {
    switch (entry.rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '${entry.rank}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: entry.rank == 1 ? AppColors.gold.withOpacity(0.4) : AppColors.border,
          width: entry.rank == 1 ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text(
            entry.name.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${entry.totalKm.toStringAsFixed(1)} KM',
            style: TextStyle(
              color: medalColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.runsAttended} RUNS ATTENDED',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photos Section ─────────────────────────────────────────────
class _PhotosSection extends StatelessWidget {
  const _PhotosSection();

  // Placeholder photos — replace URLs with your actual Google Drive direct image links
  static const List<Map<String, String>> _photos = [
    {'url': 'assets/images/IMG_8081.JPG', 'label': 'RUN #1'},
    {'url': 'assets/images/IMG_8098.JPG', 'label': 'RUN #2'},
    {'url': 'assets/images/IMG_8905.JPG', 'label': 'RUN #2'},
    {'url': 'assets/images/IMG_9030.JPG', 'label': 'RUN #1'},
    {'url': 'assets/images/IMG_9034.JPG', 'label': 'RUN #2'},
    {'url': 'assets/images/IMG_9035.JPG', 'label': 'RUN #1'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isDesktop ? AppConstants.desktopPadding : AppConstants.mobilePadding,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RzSectionHeader(title: 'MOMENTS', subtitle: 'From the streets of Tashkent'),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: _photos.length,
            itemBuilder: (_, i) {
              final photo = _photos[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    photo['url']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Text('✦', style: TextStyle(color: AppColors.primary, fontSize: 24)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: AppColors.background.withOpacity(0.7),
                      child: Text(
                        photo['label']!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Drive Section ──────────────────────────────────────────────
class _DriveSection extends StatelessWidget {
  const _DriveSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: AppColors.surface,
      child: Column(
        children: [
          const Text(
            '✦',
            style: TextStyle(color: AppColors.primary, fontSize: 28),
          ),
          const SizedBox(height: 20),
          const Text(
            'ALL OUR RUNS. ALL OUR MEMORIES.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Every run. Every face. Every finish line.\nBrowse the full photo archive on Google Drive.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          RzButton(
            label: '✦  VIEW ALL PHOTOS',
            onTap: () => launchUrl(Uri.parse(AppConstants.photosAlbumUrl)),
          ),
          const SizedBox(height: 16),
          const Text(
            'OPENS IN GOOGLE DRIVE',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton loader ────────────────────────────────────────────
class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 1,
      ),
    );
  }
}
