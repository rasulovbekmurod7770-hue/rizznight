import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/providers.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/models.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage>
    with SingleTickerProviderStateMixin {
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
    final isAdmin = ref.watch(isAdminProvider);
    final s = S(ref.watch(languageProvider));

    if (!isAdmin) {
      return RzScaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(80),
            child: Text(s.accessDenied,
                style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 24,
                    fontWeight: FontWeight.w900)),
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
                labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5),
                tabs: [
                  Tab(text: s.createRun),
                  Tab(text: s.attendance),
                  Tab(text: s.invites),
                  Tab(text: s.announcementsTab),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          const _CreateRunTab(),
          _AttendanceTab(tabController: _tabs, tabIndex: 1),
          const _InviteTab(),
          const _AnnouncementsTab(),
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
  final _titleRuCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _descRuCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleRuCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _descRuCtrl.dispose();
    super.dispose();
  }

  Future<void> _createRun() async {
    if (_titleCtrl.text.isEmpty || _locationCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(firestoreServiceProvider).createRunEvent(
            RunEventModel(
              id: '',
              title: _titleCtrl.text.trim(),
              titleRu: _titleRuCtrl.text.trim().isEmpty
                  ? null
                  : _titleRuCtrl.text.trim(),
              location: _locationCtrl.text.trim(),
              description: _descCtrl.text.trim().isEmpty
                  ? null
                  : _descCtrl.text.trim(),
              descriptionRu: _descRuCtrl.text.trim().isEmpty
                  ? null
                  : _descRuCtrl.text.trim(),
              date: _selectedDate,
              status: RunEventStatus.open,
            ),
          );
      _titleCtrl.clear();
      _titleRuCtrl.clear();
      _locationCtrl.clear();
      _descCtrl.clear();
      _descRuCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Run created!'),
            backgroundColor: AppColors.success));
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

  @override
  Widget build(BuildContext context) {
    final runs = ref.watch(runEventsProvider);
    final s = S(ref.watch(languageProvider));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.createNewRun,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                const SizedBox(height: 24),
                _AdminField(label: '${s.runTitle} (EN)', controller: _titleCtrl),
                const SizedBox(height: 12),
                _AdminField(label: '${s.runTitle} (RU)', controller: _titleRuCtrl),
                const SizedBox(height: 12),
                _AdminField(label: s.location, controller: _locationCtrl),
                const SizedBox(height: 12),
                _AdminField(label: '${s.description} (EN)', controller: _descCtrl, maxLines: 3),
                const SizedBox(height: 12),
                _AdminField(label: '${s.description} (RU)', controller: _descRuCtrl, maxLines: 3),
                const SizedBox(height: 16),
                // Date picker
                // Date & Time picker
                GestureDetector(
                  onTap: () async {
                    // 1. Pick the Date
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (_, child) => Theme(
                        data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                                primary: AppColors.primary)),
                        child: child!,
                      ),
                    );

                    // 2. If a date was picked, Pick the Time
                    if (pickedDate != null && mounted) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDate),
                        builder: (_, child) => Theme(
                          data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary)),
                          child: child!,
                        ),
                      );

                      // 3. Combine Date and Time and save it!
                      if (pickedTime != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 12),
                        Text(
                          // Notice the format now includes HH:mm so you can see your selected time!
                          DateFormat('EEE, MMM d yyyy · HH:mm').format(_selectedDate),
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _loading
                    ? const CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 1)
                    : RzButton(
                        label: s.createRunBtn,
                        onTap: _createRun,
                        fullWidth: true),
              ],
            ),
          ),
          const SizedBox(width: 48),
          // Run list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.allRunsAdmin,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                const SizedBox(height: 24),
                runs.when(
                  loading: () => const CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 1),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) => Column(
                    children: list.map((r) => _AdminRunRow(run: r)).toList(),
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
                Text(run.title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                if (run.titleRu != null)
                  Text(run.titleRu!,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                Text(DateFormat('MMM d, yyyy').format(run.date),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text('${run.slotsTaken}/${run.totalSlots}',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Tab 2: Attendance ──────────────────────────────────────────
class _AttendanceTab extends ConsumerStatefulWidget {
  final TabController tabController;
  final int tabIndex;

  const _AttendanceTab({
    required this.tabController,
    required this.tabIndex,
  });

  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab> {
  String? _selectedEventId;
  final Set<String> _attendedUserIds = {};
  bool _loading = false;
  bool _confirmed = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm(List<SlotModel> slots) async {
    if (_attendedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No runners marked as attended.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ref.read(firestoreServiceProvider).markAttendance(
            eventId: _selectedEventId!,
            attendedUserIds: _attendedUserIds.toList(),
            allSlots: slots,
          );
      if (mounted) {
        setState(() {
          _confirmed = true;
          _loading = false;
          _selectedEventId = null;
          _attendedUserIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Attendance saved. KM awarded successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final runs = ref.watch(runEventsProvider);
    final s = S(ref.watch(languageProvider));

    return AnimatedBuilder(
      animation: widget.tabController,
      builder: (context, _) {
        final isTabActive = widget.tabController.index == widget.tabIndex;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.markAttendance,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
              const SizedBox(height: 24),
              runs.when(
                loading: () => const CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 1),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) {
                  final eligible =
                      list.where((r) => !r.attendanceMarked).toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedEventId,
                    decoration: InputDecoration(labelText: s.selectRun),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    items: eligible
                        .map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(
                                  '${r.title} — ${DateFormat('MMM d').format(r.date)}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedEventId = v;
                      _attendedUserIds.clear();
                      _confirmed = false;
                      _searchCtrl.clear();
                    }),
                  );
                },
              ),
              if (_selectedEventId != null && isTabActive) ...[
                const SizedBox(height: 32),
                Consumer(builder: (_, ref, __) {
                  final slots =
                      ref.watch(eventSlotsProvider(_selectedEventId!));
                  return slots.when(
                    loading: () => const CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 1),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (list) {
                      if (list.isEmpty) {
                        return Text(s.noOneRegistered,
                            style: const TextStyle(
                                color: AppColors.textSecondary));
                      }
                      final filtered = _searchQuery.isEmpty
                          ? list
                          : list
                              .where((slot) => slot.userName
                                  .toLowerCase()
                                  .contains(_searchQuery))
                              .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${list.length} ${s.runnersRegistered}',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: s.isRu
                                  ? 'Поиск по имени...'
                                  : 'Search by name...',
                              prefixIcon: const Icon(Icons.search,
                                  color: AppColors.primary, size: 18),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () => _searchCtrl.clear(),
                                      child: const Icon(Icons.close,
                                          color: AppColors.textMuted,
                                          size: 16),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                s.isRu
                                    ? 'Бегун не найден.'
                                    : 'No runner found.',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 13),
                              ),
                            )
                          else
                            ...filtered.asMap().entries.map((entry) {
                              final i = entry.key;
                              final slot = entry.value;
                              final attended =
                                  _attendedUserIds.contains(slot.userId);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: attended
                                      ? AppColors.primary.withOpacity(0.08)
                                      : AppColors.surface,
                                  border: Border.all(
                                    color: attended
                                        ? AppColors.primary.withOpacity(0.4)
                                        : AppColors.border,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text('${i + 1}.',
                                        style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        slot.userName.toUpperCase(),
                                        style: TextStyle(
                                          color: attended
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (_confirmed)
                                      Icon(
                                        attended
                                            ? Icons.check_circle_outline
                                            : Icons.cancel_outlined,
                                        color: attended
                                            ? AppColors.success
                                            : AppColors.error,
                                        size: 18,
                                      )
                                    else
                                      Row(
                                        children: [
                                          _AttendBtn(
                                            label: '✓',
                                            active: attended,
                                            color: AppColors.success,
                                            onTap: () => setState(() =>
                                                _attendedUserIds
                                                    .add(slot.userId)),
                                          ),
                                          const SizedBox(width: 8),
                                          _AttendBtn(
                                            label: '✗',
                                            active: !attended,
                                            color: AppColors.error,
                                            onTap: () => setState(() =>
                                                _attendedUserIds
                                                    .remove(slot.userId)),
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
                                ? const CircularProgressIndicator(
                                    color: AppColors.primary, strokeWidth: 1)
                                : RzButton(
                                    label:
                                        '${s.confirmAttendance} ${_attendedUserIds.length}',
                                    onTap: () => _confirm(list),
                                    fullWidth: true,
                                  ),
                          if (_confirmed)
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: AppColors.success.withOpacity(0.1),
                              child: Text(
                                s.attendanceConfirmed,
                                style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }),
              ] else if (_selectedEventId != null) ...[
                const SizedBox(height: 32),
                Text(
                  s.isRu
                      ? 'Перейдите на вкладку «Посещаемость», чтобы загрузить список.'
                      : 'Switch to the Attendance tab to load the runner list.',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AttendBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _AttendBtn(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
              color: active ? color : AppColors.border, width: 0.5),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: active ? color : AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
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
      final code =
          await ref.read(firestoreServiceProvider).generateInviteCode();
      setState(() => _lastGenerated = code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codes = ref.watch(inviteCodesProvider);
    final s = S(ref.watch(languageProvider));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.invites,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(height: 24),
          _generating
              ? const CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 1)
              : RzButton(
                  label: '✦  GENERATE NEW CODE', onTap: _generate),
          if (_lastGenerated != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 1),
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NEW CODE GENERATED',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(_lastGenerated!,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
          const Text('ALL CODES',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 2)),
          const SizedBox(height: 16),
          codes.when(
            loading: () => const CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 1),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => Column(
              children: list
                  .map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                              color: AppColors.border, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Text(c.code,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              color: c.used
                                  ? AppColors.textMuted.withOpacity(0.1)
                                  : AppColors.success.withOpacity(0.1),
                              child: Text(
                                c.used ? 'USED' : 'AVAILABLE',
                                style: TextStyle(
                                    color: c.used
                                        ? AppColors.textMuted
                                        : AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
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
  final _titleRuCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _bodyRuCtrl = TextEditingController();
  bool _pinned = false;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleRuCtrl.dispose();
    _bodyCtrl.dispose();
    _bodyRuCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_titleCtrl.text.isEmpty || _bodyCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(firestoreServiceProvider).createAnnouncement(
            AnnouncementModel(
              id: '',
              title: _titleCtrl.text.trim(),
              titleRu: _titleRuCtrl.text.trim().isEmpty
                  ? null
                  : _titleRuCtrl.text.trim(),
              body: _bodyCtrl.text.trim(),
              bodyRu: _bodyRuCtrl.text.trim().isEmpty
                  ? null
                  : _bodyRuCtrl.text.trim(),
              postedAt: DateTime.now(),
              pinned: _pinned,
            ),
          );
      _titleCtrl.clear();
      _titleRuCtrl.clear();
      _bodyCtrl.clear();
      _bodyRuCtrl.clear();
      setState(() => _pinned = false);
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

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsProvider);
    final s = S(ref.watch(languageProvider));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.postAnnouncement,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                const SizedBox(height: 24),
                _AdminField(label: '${s.title} (EN)', controller: _titleCtrl),
                const SizedBox(height: 12),
                _AdminField(label: '${s.title} (RU)', controller: _titleRuCtrl),
                const SizedBox(height: 12),
                _AdminField(label: '${s.body} (EN)', controller: _bodyCtrl, maxLines: 4),
                const SizedBox(height: 12),
                _AdminField(label: '${s.body} (RU)', controller: _bodyRuCtrl, maxLines: 4),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: _pinned,
                      onChanged: (v) => setState(() => _pinned = v),
                      activeThumbColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(s.pinToTop,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 1)
                    : RzButton(label: s.postBtn, onTap: _post, fullWidth: true),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.allAnnouncements,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                const SizedBox(height: 24),
                announcements.when(
                  loading: () => const CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 1),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (list) => Column(
                    children: list
                        .map((a) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border(
                                    left: BorderSide(
                                        color: a.pinned
                                            ? AppColors.primary
                                            : AppColors.border,
                                        width: a.pinned ? 2 : 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(a.title,
                                            style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700)),
                                        if (a.titleRu != null)
                                          Text(a.titleRu!,
                                              style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12)),
                                        Text(a.body,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: AppColors.error),
                                    onPressed: () => ref
                                        .read(firestoreServiceProvider)
                                        .deleteAnnouncement(a.id),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
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

class _AdminField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  const _AdminField(
      {required this.label,
      required this.controller,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style:
              const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
