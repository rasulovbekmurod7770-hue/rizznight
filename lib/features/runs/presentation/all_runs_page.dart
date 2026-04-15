import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/providers.dart';
import '../../../models/models.dart';

class AllRunsPage extends ConsumerWidget {
  const AllRunsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(runEventsProvider);
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
            const RzSectionHeader(title: 'ALL RUNS'),
            const SizedBox(height: 8),
            const Text(
              'UPCOMING & PAST EVENTS',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 40),
            runs.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1)),
              error: (_, __) => const Text('Error loading runs.', style: TextStyle(color: AppColors.error)),
              data: (list) {
                if (list.isEmpty) {
                  return const Text('No runs yet. Check back soon.', style: TextStyle(color: AppColors.textSecondary));
                }
                return Column(
                  children: list.map((run) => _RunListCard(run: run)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RunListCard extends StatelessWidget {
  final RunEventModel run;
  const _RunListCard({required this.run});

  Color get statusColor {
    switch (run.status) {
      case RunEventStatus.open: return AppColors.success;
      case RunEventStatus.completed: return AppColors.textMuted;
      case RunEventStatus.closed: return AppColors.error;
      default: return AppColors.primary;
    }
  }

  String get statusLabel {
    switch (run.status) {
      case RunEventStatus.open: return 'OPEN';
      case RunEventStatus.completed: return 'COMPLETED';
      case RunEventStatus.closed: return 'CLOSED';
      default: return 'UPCOMING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/runs/${run.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (run.isFull)
                        const Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    run.title.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('MMM d, yyyy · HH:mm').format(run.date)} · ${run.location}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${run.slotsTaken}/${run.totalSlots}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'SLOTS',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
