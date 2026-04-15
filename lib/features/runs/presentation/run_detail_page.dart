import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/providers.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/models.dart';

class RunDetailPage extends ConsumerStatefulWidget {
  final String eventId;
  const RunDetailPage({super.key, required this.eventId});

  @override
  ConsumerState<RunDetailPage> createState() => _RunDetailPageState();
}

class _RunDetailPageState extends ConsumerState<RunDetailPage> {
  bool _loading = false;

  Future<void> _claimSlot(RunEventModel event) async {
    final user = await ref.read(authServiceProvider).getCurrentUserModel();
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(firestoreServiceProvider).claimSlot(
        eventId: event.id,
        userId: user.uid,
        userName: user.name,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✦  SLOT CLAIMED! See you at the run.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancelSlot() async {
    final user = await ref.read(authServiceProvider).getCurrentUserModel();
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(firestoreServiceProvider).cancelSlot(
        eventId: widget.eventId,
        userId: user.uid,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slot cancelled.'), backgroundColor: AppColors.surface),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(runEventProvider(widget.eventId));
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return RzScaffold(
      body: eventAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(80),
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
          ),
        ),
        error: (_, __) => const Center(child: Text('Run not found.', style: TextStyle(color: AppColors.textSecondary))),
        data: (event) {
          if (event == null) return const SizedBox.shrink();
          return _buildContent(event, isDesktop);
        },
      ),
    );
  }

  Widget _buildContent(RunEventModel event, bool isDesktop) {
    final currentUser = ref.read(authServiceProvider).currentUser;
    final hasSlotAsync = currentUser != null
        ? ref.watch(userHasSlotProvider({'eventId': event.id, 'userId': currentUser.uid}))
        : const AsyncData(false);
    final slots = ref.watch(eventSlotsProvider(event.id));

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isDesktop ? 80 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go('/runs'),
            child: const Text(
              '← ALL RUNS',
              style: TextStyle(color: AppColors.primary, fontSize: 12, letterSpacing: 2),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            event.title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow(icon: Icons.calendar_today_outlined, text: DateFormat('EEEE, MMM d · HH:mm').format(event.date)),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.location_on_outlined, text: '${event.location}${event.locationDetail != null ? " · ${event.locationDetail}" : ""}'),
          if (event.description != null) ...[
            const SizedBox(height: 24),
            Text(
              event.description!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
            ),
          ],
          const SizedBox(height: 40),
          const Divider(color: AppColors.border, thickness: 0.5),
          const SizedBox(height: 32),
          // Slot bar
          Row(
            children: [
              Text(
                '${event.slotsTaken} / ${event.totalSlots}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SLOTS TAKEN',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            child: LinearProgressIndicator(
              value: event.fillPercent,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                event.fillPercent > 0.8 ? AppColors.error : AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 28),
          // Claim / Cancel button
          if (event.status == RunEventStatus.open || event.status == RunEventStatus.upcoming)
            hasSlotAsync.when(
              loading: () => const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
              error: (_, __) => const SizedBox.shrink(),
              data: (hasClaimed) => _loading
                  ? const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1)
                  : hasClaimed
                      ? RzButton(label: '✗  CANCEL MY SLOT', onTap: _cancelSlot, outline: true)
                      : event.isFull
                          ? RzButton(label: 'JOIN WAITLIST', onTap: () {})
                          : RzButton(label: '✦  GRAB MY SLOT', onTap: () => _claimSlot(event)),
            )
          else if (event.status == RunEventStatus.completed)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 0.5)),
              child: const Text(
                'THIS RUN IS COMPLETED. ATTENDANCE HAS BEEN MARKED.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1),
              ),
            ),
          const SizedBox(height: 48),
          // Registered runners list
          const Text(
            'REGISTERED RUNNERS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          slots.when(
            loading: () => const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
            error: (_, __) => const SizedBox.shrink(),
            data: (slotList) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slotList.map((s) => _RunnerChip(name: s.userName)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 15),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ],
    );
  }
}

class _RunnerChip extends StatelessWidget {
  final String name;
  const _RunnerChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(
        name,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      ),
    );
  }
}
