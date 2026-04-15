import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/providers.dart';
import '../../../models/models.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
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
            const RzSectionHeader(title: 'ANNOUNCEMENTS'),
            const SizedBox(height: 8),
            const Text(
              'CLUB NEWS & UPDATES',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 40),
            announcements.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1)),
              error: (_, __) => const Text('Error loading.', style: TextStyle(color: AppColors.error)),
              data: (list) {
                if (list.isEmpty) {
                  return const Text('No announcements yet.', style: TextStyle(color: AppColors.textSecondary));
                }
                return Column(
                  children: list.map((a) => _FullAnnouncementCard(a: a)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FullAnnouncementCard extends StatelessWidget {
  final AnnouncementModel a;
  const _FullAnnouncementCard({required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(
            color: a.pinned ? AppColors.primary : AppColors.border,
            width: a.pinned ? 2 : 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (a.pinned) ...[
                const Text(
                  '✦ PINNED',
                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                DateFormat('MMM d, yyyy').format(a.postedAt),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            a.title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            a.body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
