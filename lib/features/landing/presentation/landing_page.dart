import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/providers.dart';
import '../../../models/models.dart';

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
          _SocialSection(),
        ],
      ),
    );
  }
}

// ── Hero ───────────────────────────────────────────────────────
class _HeroSection extends ConsumerWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider).valueOrNull != null;
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final s = S(ref.watch(languageProvider));

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 600),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✦',
                      style: TextStyle(color: AppColors.primary, fontSize: 24)),
                  const SizedBox(height: 24),
                  Text(
                    s.heroLine1,
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
                    s.heroLine2,
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
                  Text(
                    s.heroSub,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  RzButton(
                    label: isLoggedIn ? s.claimSpot : s.requestInvite,
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

// ── Next Run ───────────────────────────────────────────────────
class _NextRunSection extends ConsumerWidget {
  const _NextRunSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextRun = ref.watch(nextRunProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final s = S(ref.watch(languageProvider));

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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RzSectionHeader(title: s.nextRun),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '✦',
                        style: TextStyle(color: AppColors.primary, fontSize: 32),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        s.isRu
                            ? 'ЗАБЕГОВ НЕТ. МЫ ОТДЫХАЕМ.\nСЛЕДИТЕ ЗА СЛЕДУЮЩИМ ДРОПОМ.'
                            : 'NO UPCOMING RUNS.\nWE ARE RESTING.\nSTAY TUNED FOR THE NEXT DROP.',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return _NextRunCard(run: run, s: s, isDesktop: isDesktop);
        },
      ),
    );
  }
}

class _NextRunCard extends StatelessWidget {
  final RunEventModel run;
  final S s;
  final bool isDesktop;
  const _NextRunCard({required this.run, required this.s, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d · HH:mm').format(run.date);
    final fillPercent = run.fillPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RzSectionHeader(title: s.nextRun),
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
                    Expanded(child: _RunInfo(run: run, dateStr: dateStr, s: s)),
                    const SizedBox(width: 60),
                    _SlotWidget(run: run, fillPercent: fillPercent, s: s),
                  ],
                )
              : Column(
                  children: [
                    _RunInfo(run: run, dateStr: dateStr, s: s),
                    const SizedBox(height: 24),
                    _SlotWidget(run: run, fillPercent: fillPercent, s: s),
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
  final S s;
  const _RunInfo({required this.run, required this.dateStr, required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          run.localizedTitle(s.isRu).toUpperCase(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 14),
          const SizedBox(width: 8),
          Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 14),
          const SizedBox(width: 8),
          Text(run.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
        if (run.localizedDescription(s.isRu) != null) ...[
          const SizedBox(height: 16),
          Text(
            run.localizedDescription(s.isRu)!,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
        const SizedBox(height: 20),
        RzButton(
          label: run.isFull ? s.joinWaitlist : s.grabSlot,
          onTap: () => context.go('/runs/${run.id}'),
        ),
      ],
    );
  }
}

class _SlotWidget extends StatelessWidget {
  final RunEventModel run;
  final double fillPercent;
  final S s;
  const _SlotWidget({required this.run, required this.fillPercent, required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          'OF ${run.totalSlots} ${s.slotsTaken}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2),
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
          run.isFull ? s.soldOut : '${run.slotsAvailable} ${s.spotsLeft}',
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
    final s = S(ref.watch(languageProvider));
    final isDesktop = MediaQuery.of(context).size.width > 768;

    final leaderName = leaderboard.valueOrNull?.isNotEmpty == true
        ? leaderboard.valueOrNull!.first.name.toUpperCase()
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
        data: (st) => Wrap(
          spacing: 60,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _StatItem(value: '${st['totalMembers']}', label: s.activeRunners),
            _StatItem(value: '${(st['totalKm'] as double).toStringAsFixed(0)} KM', label: s.totalClubKm),
            _StatItem(value: leaderName, label: s.leaderThisWeek),
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
        Text(value,
            style: const TextStyle(
                color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11, letterSpacing: 2)),
      ],
    );
  }
}

// ── Announcements ──────────────────────────────────────────────
class _AnnouncementsSection extends ConsumerWidget {
  const _AnnouncementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final s = S(ref.watch(languageProvider));

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
                  RzSectionHeader(title: s.announcementsTitle),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.announcements),
                    child: Text(s.viewAll,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...preview.map((a) => _AnnouncementCard(announcement: a, s: s)),
            ],
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final S s;
  const _AnnouncementCard({required this.announcement, required this.s});

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
                  announcement.localizedTitle(s.isRu).toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  announcement.localizedBody(s.isRu),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat('MMM d').format(announcement.postedAt),
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11, letterSpacing: 1),
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
    final s = S(ref.watch(languageProvider));

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  RzSectionHeader(
                      title: s.leaderboardTitle, subtitle: s.rankedByKm),
                  const Spacer(),
                  GestureDetector(
                    
                    onTap: () => context.go(AppRoutes.leaderboard),
                    child: Text(s.fullBoard,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2)),
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

class _PodiumCard extends ConsumerWidget {
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
      default: return '#${entry.rank}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S(ref.watch(languageProvider));
    return Container(
      width: 300  ,
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
          Text(entry.name.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('${entry.totalKm.toStringAsFixed(1)} KM',
              style: TextStyle(
                  color: medalColor, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('${entry.runsAttended} ${s.runsAttended.toUpperCase()}',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11, letterSpacing: 1)),
        ],
      ),
    );
  }
}

// ── Photos ─────────────────────────────────────────────────────
class _PhotosSection extends ConsumerWidget {
  const _PhotosSection();

  static const List<Map<String, String>> _photos = [
    {'url': 'assets/images/IMG_9034.jpg', 'label': 'RUN #1'},
    {'url': 'assets/images/IMG_8098.jpg', 'label': 'RUN #2'},
    {'url': 'assets/images/IMG_9035.jpg', 'label': 'RUN #3'},
    {'url': 'assets/images/IMG_9030.jpg', 'label': 'RUN #2'},
    {'url': 'assets/images/IMG_8081.jpg', 'label': 'RUN #1'},
    {'url': 'assets/images/IMG_8905.jpg', 'label': 'RUN #3'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final s = S(ref.watch(languageProvider));

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
          RzSectionHeader(title: s.momentsTitle, subtitle: s.momentsSub),
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
                  Image.asset(photo['url']!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surface,
                            child: const Center(
                                child: Text('✦',
                                    style: TextStyle(
                                        color: AppColors.primary, fontSize: 24))),
                          )),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: AppColors.background.withOpacity(0.7),
                      child: Text(photo['label']!,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5)),
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
class _DriveSection extends ConsumerWidget {
  const _DriveSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S(ref.watch(languageProvider));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: AppColors.surface,
      child: Column(
        children: [
          const Text('✦', style: TextStyle(color: AppColors.primary, fontSize: 28)),
          const SizedBox(height: 20),
          Text(s.allMemories,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(s.driveDesc,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          RzButton(
            label: s.viewAllPhotos,
            onTap: () => launchUrl(Uri.parse(AppConstants.photosAlbumUrl)),
          ),
          const SizedBox(height: 16),
          Text(s.opensInDrive,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10, letterSpacing: 2)),
        ],
      ),
    );
  }
}

// ── Social Section ─────────────────────────────────────────────
class _SocialSection extends ConsumerWidget {
  const _SocialSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final s = S(ref.watch(languageProvider));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? AppConstants.desktopPadding : AppConstants.mobilePadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        children: [
          const Text('✦', style: TextStyle(color: AppColors.primary, fontSize: 24)),
          const SizedBox(height: 20),
          Text(s.findUs,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(s.stayInLoop,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _SocialCard(
                icon: _InstagramIcon(),
                label: 'INSTAGRAM',
                sublabel: s.instaSublabel,
                buttonLabel: s.followUs,
                url: 'https://www.instagram.com/rizznight.run?igsh=MW8zOG84bmtnMW9kZA==',
              ),
              _SocialCard(
                icon: _TelegramIcon(),
                label: 'TELEGRAM',
                sublabel: s.telegramSublabel,
                buttonLabel: s.joinChannel,
                url: 'https://t.me/rizznight_run',
              ),
              _SocialCard(
                icon: _DonateIcon(),
                label: s.isRu ? 'ПОДДЕРЖКА' : 'SUPPORT US',
                sublabel: s.donateSublabel,
                buttonLabel: s.donate,
                url: 'https://t.me/Rizznight_donate_bot',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialCard extends StatefulWidget {
  final Widget icon;
  final String label;
  final String sublabel;
  final String buttonLabel;
  final String url;

  const _SocialCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.buttonLabel,
    required this.url,
  });

  @override
  State<_SocialCard> createState() => _SocialCardState();
}

class _SocialCardState extends State<_SocialCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 260,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
          border: Border.all(
            color: _hovered ? AppColors.primary : AppColors.border,
            width: _hovered ? 1 : 0.5,
          ),
        ),
        child: Column(
          children: [
            SizedBox(width: 56, height: 56, child: widget.icon),
            const SizedBox(height: 20),
            Text(widget.label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: 6),
            Text(widget.sublabel,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => launchUrl(Uri.parse(widget.url)),
                child: Text(widget.buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstagramIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _InstagramPainter());
}

class _InstagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(size.width * 0.25)),
      paint,
    );
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width * 0.27, paint);
    canvas.drawCircle(
        Offset(size.width * 0.72, size.height * 0.28), size.width * 0.06,
        Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TelegramIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _TelegramPainter());
}

class _TelegramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2 - 1, paint);
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.5, size.height * 0.75)
      ..lineTo(size.width * 0.38, size.height * 0.58)
      ..lineTo(size.width * 0.8, size.height * 0.3);
    canvas.drawPath(path, paint);
    canvas.drawPath(
        Path()
          ..moveTo(size.width * 0.38, size.height * 0.58)
          ..lineTo(size.width * 0.2, size.height * 0.5),
        paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DonateIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DonatePainter());
}

class _DonatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.38;
    final path = Path()
      ..moveTo(cx, cy + w * 0.9)
      ..cubicTo(cx - w * 1.8, cy, cx - w * 1.8, cy - w * 1.2, cx, cy - w * 0.3)
      ..cubicTo(cx + w * 1.8, cy - w * 1.2, cx + w * 1.8, cy, cx, cy + w * 0.9);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
    );
  }
}
