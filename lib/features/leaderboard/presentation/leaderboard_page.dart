import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/providers.dart';
import '../../../models/models.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return RzScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 60,
          horizontal: isDesktop ? 80 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RzSectionHeader(title: 'LEADERBOARD'),
            const SizedBox(height: 8),
            const Text(
              'WHO RUNS TASHKENT',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ranked by total KM earned through attendance.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 48),
            leaderboard.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1)),
              error: (_, __) => const Text('Error loading leaderboard.'),
              data: (entries) {
                if (entries.isEmpty) {
                  return const Text('No runners yet.', style: TextStyle(color: AppColors.textSecondary));
                }
                // Top 3 podium
                final top3 = entries.take(3).toList();
                final rest = entries.skip(3).toList();

                return Column(
                  children: [
                    // Podium
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (top3.length > 1)
                            Expanded(child: _PodiumBlock(entry: top3[1], height: 160)),
                          Expanded(child: _PodiumBlock(entry: top3[0], height: 200)),
                          if (top3.length > 2)
                            Expanded(child: _PodiumBlock(entry: top3[2], height: 130)),
                        ],
                      )
                    else
                      Column(children: top3.map((e) => _PodiumBlock(entry: e, height: 100)).toList()),
                    const SizedBox(height: 48),
                    const RzStarDivider(),
                    const SizedBox(height: 32),
                    // Table header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: const [
                          SizedBox(width: 48, child: Text('RANK', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.5))),
                          Expanded(child: Text('RUNNER', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.5))),
                          SizedBox(width: 80, child: Text('RUNS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.5), textAlign: TextAlign.center)),
                          SizedBox(width: 100, child: Text('TOTAL KM', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.5), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.border, thickness: 0.5),
                    // Rest of table
                    ...rest.map((e) => _LeaderboardRow(entry: e)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumBlock extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  const _PodiumBlock({required this.entry, required this.height});

  String get medal {
    switch (entry.rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '${entry.rank}';
    }
  }

  Color get accentColor {
    switch (entry.rank) {
      case 1: return AppColors.gold;
      case 2: return AppColors.silver;
      case 3: return AppColors.bronze;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/profile/${entry.uid}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: entry.rank == 1 ? accentColor.withOpacity(0.5) : AppColors.border,
            width: entry.rank == 1 ? 1 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(medal, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
            Text(
              entry.name.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.totalKm.toStringAsFixed(1)} KM',
              style: TextStyle(
                color: accentColor,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/profile/${entry.uid}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Text(
                entry.name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                '${entry.runsAttended}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '${entry.totalKm.toStringAsFixed(1)} km',
                style: const TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w700),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
