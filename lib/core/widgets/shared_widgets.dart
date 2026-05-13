import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../routing/app_router.dart';
import '../services/providers.dart';

// ── Rizznight Navbar ───────────────────────────────────────────
class RzNavbar extends ConsumerWidget implements PreferredSizeWidget {
  const RzNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.navbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider).valueOrNull != null;
    final isAdmin = ref.watch(isAdminProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final lang = ref.watch(languageProvider);
    final s = S(lang);

    return Container(
      height: AppConstants.navbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A), width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppConstants.desktopPadding : AppConstants.mobilePadding,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.landing),
            child: const RzLogo(),
          ),
          const Spacer(),
          if (isDesktop) ...[
            _NavLink(s.runs, () => context.go(AppRoutes.runs)),
            const SizedBox(width: 24),
            _NavLink(s.leaderboard, () => context.go(AppRoutes.leaderboard)),
            const SizedBox(width: 24),
            _NavLink(s.announcements, () => context.go(AppRoutes.announcements)),
            if (isAdmin) ...[
              const SizedBox(width: 24),
              _NavLink(s.admin, () => context.go(AppRoutes.admin)),
            ],
            const SizedBox(width: 24),
            // Language toggle for desktop
            _LangToggle(),
            const SizedBox(width: 24),
            if (isLoggedIn)
              RzButton(
                label: s.myProfile,
                onTap: () {
                  final uid = ref.read(authServiceProvider).currentUser?.uid;
                  if (uid != null) context.go('/profile/$uid');
                },
              )
            else
              RzButton(
                label: s.login,
                onTap: () => context.go(AppRoutes.login),
              ),
          ] else
            // Mobile: language toggle OUTSIDE hamburger, visible always
            Row(
              children: [
                _LangToggle(),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                  onPressed: () =>
                      _showMobileMenu(context, ref, isLoggedIn, isAdmin, s),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context, WidgetRef ref, bool isLoggedIn,
      bool isAdmin, S s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MobileNavItem(s.runs,
                () { Navigator.pop(context); context.go(AppRoutes.runs); }),
            _MobileNavItem(s.leaderboard,
                () { Navigator.pop(context); context.go(AppRoutes.leaderboard); }),
            _MobileNavItem(s.announcements,
                () { Navigator.pop(context); context.go(AppRoutes.announcements); }),
            if (isAdmin)
              _MobileNavItem(s.admin,
                  () { Navigator.pop(context); context.go(AppRoutes.admin); }),
            const Divider(color: AppColors.border),
            if (isLoggedIn)
              _MobileNavItem(s.myProfile, () {
                Navigator.pop(context);
                final uid = ref.read(authServiceProvider).currentUser?.uid;
                if (uid != null) context.go('/profile/$uid');
              })
            else
              _MobileNavItem(s.login,
                  () { Navigator.pop(context); context.go(AppRoutes.login); }),
          ],
        ),
      ),
    );
  }
}

// ── Language Toggle Button ─────────────────────────────────────
class _LangToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final isEn = lang == AppLanguage.en;

    return GestureDetector(
      onTap: () => ref.read(languageProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1),
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EN',
              style: TextStyle(
                color: isEn ? AppColors.primary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isEn ? FontWeight.w900 : FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '|',
                style: TextStyle(color: AppColors.border, fontSize: 11),
              ),
            ),
            Text(
              'RU',
              style: TextStyle(
                color: !isEn ? AppColors.primary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: !isEn ? FontWeight.w900 : FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MobileNavItem(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ── Rizznight Logo ─────────────────────────────────────────────
class RzLogo extends StatelessWidget {
  final double fontSize;
  const RzLogo({super.key, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('✦',
            style: TextStyle(color: AppColors.primary, fontSize: fontSize * 0.7)),
        const SizedBox(width: 8),
        Text(
          AppConstants.appName,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

// ── Primary Button ─────────────────────────────────────────────
class RzButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outline;
  final bool fullWidth;

  const RzButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outline = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: outline
          ? OutlinedButton(onPressed: onTap, child: Text(label))
          : ElevatedButton(onPressed: onTap, child: Text(label)),
    );
  }
}

// ── Star Divider ───────────────────────────────────────────────
class RzStarDivider extends StatelessWidget {
  const RzStarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
         Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16),
          child: Text('✦',
              style: TextStyle(color: AppColors.primary, fontSize: 14)),
        ),
         Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
      ],
    );
  }
}

// ── Section Header ─────────────────────────────────────────────
class RzSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const RzSectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✦ $title',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ],
    );
  }
}

// ── Footer ─────────────────────────────────────────────────────
class RzFooter extends ConsumerWidget {
  const RzFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S(ref.watch(languageProvider));
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: isDesktop ? 80 : 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const RzLogo(),
          _footerRight(s),
        ],
      ),
    );
  }

  Widget _footerRight(S s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
       const Text(
          AppConstants.motto,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.allRightsReserved,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ── Page Scaffold ──────────────────────────────────────────────
class RzScaffold extends StatelessWidget {
  final Widget body;
  final bool showFooter;

  const RzScaffold({super.key, required this.body, this.showFooter = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RzNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            body,
            if (showFooter) const RzFooter(),
          ],
        ),
      ),
    );
  }
}
