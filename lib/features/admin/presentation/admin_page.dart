import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rizznight/core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/providers.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../models/models.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Guard: only admins
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return RzScaffold(
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(80),
            child: Text('ACCESS DENIED', style: TextStyle(color: AppColors.error, fontSize: 24, fontWeight: FontWeight.w900)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(112),
        child: Column(
          children: [
            const RzNavbar(),
            Container(
              color: AppColors.surface,
              child: TabBar(
                controller: _tabs,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                tabs: const [
                  Tab(text: 'RUNS'),
                  Tab(text: 'ATTENDANCE'),
                  Tab(text: 'INVITES'),
                  Tab(text: 'ANNOUNCEMENTS'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _CreateRunTab(),
          _AttendanceTab(),
          _InviteTab(),
          _AnnouncementsTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Create Run ──────────────────────────────────────────
class _CreateRunTab extends ConsumerStatefulWidget {
  const _CreateRunTab();

  @override
  ConsumerState<_CreateRunTab> createState() => _CreateRunTabState();
}

class _CreateRunTabState extends ConsumerState<_CreateRunTab> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _loading = false;

  Future<void> _createRun() async {
    if (_titleCtrl.text.isEmpty || _locationCtrl.text.isEmpty) return;
    setState(() => _loading = true);

    try {
      await ref.read(firestoreServiceProvider).createRunEvent(
        RunEventModel(
          id: '',
          title: _titleCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          date: _selectedDate,
          status: RunEventStatus.open,
        ),
      );
      _titleCtrl.clear();
      _locationCtrl.clear();
      _descCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Run created!'), backgroundColor: AppColors.success),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final runs = ref.watch(runEventsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create form
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CREATE NEW RUN', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 24),
                _AdminField(label: 'RUN TITLE', controller: _titleCtrl),
                const SizedBox(height: 16),
                _AdminField(label: 'LOCATION', controller: _locationCtrl),
                const SizedBox(height: 16),
                _AdminField(label: 'DESCRIPTION (OPTIONAL)', controller: _descCtrl, maxLines: 3),
                const SizedBox(height: 16),
                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (_, child) => Theme(
                        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary)),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 16),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEE, MMM d yyyy').format(_selectedDate),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _loading
                    ? const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1)
                    : RzButton(label: '✦  CREATE RUN', onTap: _createRun, fullWidth: true),
              ],
            ),
          ),
          const SizedBox(width: 48),
          // Run list
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ALL RUNS', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 24),
                runs.when(
                  loading: () => const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) => Column(
                    children: list.map((run) => _AdminRunRow(run: run)).toList(),
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

class _AdminRunRow extends StatelessWidget {
  final RunEventModel run;
  const _AdminRunRow({required this.run});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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
                Text(run.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                Text(DateFormat('MMM d, yyyy').format(run.date), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text('${run.slotsTaken}/${run.totalSlots}', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Tab 2: Attendance ──────────────────────────────────────────
class _AttendanceTab extends ConsumerStatefulWidget {
  const _AttendanceTab();

  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab> {
  String? _selectedEventId;
  final Set<String> _attendedUserIds = {};
  bool _loading = false;
  bool _confirmed = false;

  Future<void> _confirm(List<SlotModel> slots) async {
    setState(() => _loading = true);
    try {
      await ref.read(firestoreServiceProvider).markAttendance(
        eventId: _selectedEventId!,
        attendedUserIds: _attendedUserIds.toList(),
        allSlotIds: slots.map((s) => s.id).toList(),
      );
      setState(() => _confirmed = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved. KM awarded.'), backgroundColor: AppColors.success),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final runs = ref.watch(runEventsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MARK ATTENDANCE', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 24),
          runs.when(
            loading: () => const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) {
              final eligible = list.where((r) => !r.attendanceMarked).toList();
              return DropdownButtonFormField<String>(
                value: _selectedEventId,
                decoration: const InputDecoration(labelText: 'SELECT RUN'),
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                items: eligible.map((r) => DropdownMenuItem(
                  value: r.id,
                  child: Text('${r.title} — ${DateFormat('MMM d').format(r.date)}'),
                )).toList(),
                onChanged: (v) => setState(() {
                  _selectedEventId = v;
                  _attendedUserIds.clear();
                  _confirmed = false;
                }),
              );
            },
          ),
          if (_selectedEventId != null) ...[
            const SizedBox(height: 32),
            Consumer(builder: (_, ref, __) {
              final slots = ref.watch(eventSlotsProvider(_selectedEventId!));
              return slots.when(
                loading: () => const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) {
                  if (list.isEmpty) return const Text('No one registered for this run.', style: TextStyle(color: AppColors.textSecondary));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${list.length} RUNNERS REGISTERED',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2),
                      ),
                      const SizedBox(height: 16),
                      // Runner list with checkboxes
                      ...list.asMap().entries.map((entry) {
                        final i = entry.key;
                        final slot = entry.value;
                        final attended = _attendedUserIds.contains(slot.userId);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: attended ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                            border: Border.all(
                              color: attended ? AppColors.primary.withOpacity(0.4) : AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}.',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  slot.userName.toUpperCase(),
                                  style: TextStyle(
                                    color: attended ? AppColors.primary : AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_confirmed)
                                Icon(
                                  attended ? Icons.check_circle_outline : Icons.cancel_outlined,
                                  color: attended ? AppColors.success : AppColors.error,
                                  size: 18,
                                )
                              else
                                Row(
                                  children: [
                                    _AttendBtn(
                                      label: '✓',
                                      active: attended,
                                      color: AppColors.success,
                                      onTap: () => setState(() => _attendedUserIds.add(slot.userId)),
                                    ),
                                    const SizedBox(width: 8),
                                    _AttendBtn(
                                      label: '✗',
                                      active: !attended,
                                      color: AppColors.error,
                                      onTap: () => setState(() => _attendedUserIds.remove(slot.userId)),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 28),
                      if (!_confirmed)
                        _loading
                            ? const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1)
                            : RzButton(
                                label: '✦  CONFIRM & AWARD +${AppConstants.kmPerAttendance.toStringAsFixed(0)}KM TO ${_attendedUserIds.length} RUNNERS',
                                onTap: () => _confirm(list),
                                fullWidth: true,
                              ),
                      if (_confirmed)
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: AppColors.success.withOpacity(0.1),
                          child: const Text(
                            '✓ ATTENDANCE CONFIRMED. KM AWARDED.',
                            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, letterSpacing: 1),
                          ),
                        ),
                    ],
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _AttendBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _AttendBtn({required this.label, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: active ? color : AppColors.border, width: 0.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: active ? color : AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ── Tab 3: Invites ─────────────────────────────────────────────
class _InviteTab extends ConsumerStatefulWidget {
  const _InviteTab();

  @override
  ConsumerState<_InviteTab> createState() => _InviteTabState();
}

class _InviteTabState extends ConsumerState<_InviteTab> {
  bool _generating = false;
  String? _lastGenerated;

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final code = await ref.read(firestoreServiceProvider).generateInviteCode();
      setState(() => _lastGenerated = code);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codes = ref.watch(inviteCodesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INVITE CODES', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 24),
          _generating
              ? const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1)
              : RzButton(label: '✦  GENERATE NEW CODE', onTap: _generate),
          if (_lastGenerated != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NEW CODE GENERATED', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(
                    _lastGenerated!,
                    style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4),
                  ),
                  const SizedBox(height: 4),
                  const Text('Share this code with the runner.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
          const Text('ALL CODES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 16),
          codes.when(
            loading: () => const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => Column(
              children: list.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Text(c.code, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 2, fontFamily: 'monospace')),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: c.used ? AppColors.textMuted.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                      child: Text(
                        c.used ? 'USED' : 'AVAILABLE',
                        style: TextStyle(
                          color: c.used ? AppColors.textMuted : AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 4: Announcements ───────────────────────────────────────
class _AnnouncementsTab extends ConsumerStatefulWidget {
  const _AnnouncementsTab();

  @override
  ConsumerState<_AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends ConsumerState<_AnnouncementsTab> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _pinned = false;
  bool _loading = false;

  Future<void> _post() async {
    if (_titleCtrl.text.isEmpty || _bodyCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(firestoreServiceProvider).createAnnouncement(
        AnnouncementModel(
          id: '',
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          postedAt: DateTime.now(),
          pinned: _pinned,
        ),
      );
      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() => _pinned = false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('POST ANNOUNCEMENT', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 24),
                _AdminField(label: 'TITLE', controller: _titleCtrl),
                const SizedBox(height: 16),
                _AdminField(label: 'BODY', controller: _bodyCtrl, maxLines: 4),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: _pinned,
                      onChanged: (v) => setState(() => _pinned = v),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Pin to top', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1)
                    : RzButton(label: '✦  POST', onTap: _post, fullWidth: true),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ALL ANNOUNCEMENTS', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 24),
                announcements.when(
                  loading: () => const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) => Column(
                    children: list.map((a) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(left: BorderSide(color: a.pinned ? AppColors.primary : AppColors.border, width: a.pinned ? 2 : 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                                Text(a.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            onPressed: () => ref.read(firestoreServiceProvider).deleteAnnouncement(a.id),
                          ),
                        ],
                      ),
                    )).toList(),
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

// ── Shared Admin Field ─────────────────────────────────────────
class _AdminField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  const _AdminField({required this.label, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
