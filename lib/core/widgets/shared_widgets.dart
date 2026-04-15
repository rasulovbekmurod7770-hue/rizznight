import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
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
          // Logo
          GestureDetector(
            onTap: () => context.go(AppRoutes.landing),
            child: const RzLogo(),
          ),
          const Spacer(),
          if (isDesktop) ...[
            _NavLink('RUNS', () => context.go(AppRoutes.runs)),
            const SizedBox(width: 24),
            _NavLink('LEADERBOARD', () => context.go(AppRoutes.leaderboard)),
            const SizedBox(width: 24),
            _NavLink('ANNOUNCEMENTS', () => context.go(AppRoutes.announcements)),
            if (isAdmin) ...[
              const SizedBox(width: 24),
              _NavLink('ADMIN', () => context.go(AppRoutes.admin)),
            ],
            const SizedBox(width: 32),
            if (isLoggedIn)
              RzButton(
                label: 'MY PROFILE',
                onTap: () {
                  final uid = ref.read(authServiceProvider).currentUser?.uid;
                  if (uid != null) context.go('/profile/$uid');
                },
              )
            else
              RzButton(
                label: 'LOGIN',
                onTap: () => context.go(AppRoutes.login),
              ),
          ] else
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => _showMobileMenu(context, ref, isLoggedIn, isAdmin),
            ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context, WidgetRef ref, bool isLoggedIn, bool isAdmin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MobileNavItem('RUNS', () { Navigator.pop(context); context.go(AppRoutes.runs); }),
            _MobileNavItem('LEADERBOARD', () { Navigator.pop(context); context.go(AppRoutes.leaderboard); }),
            _MobileNavItem('ANNOUNCEMENTS', () { Navigator.pop(context); context.go(AppRoutes.announcements); }),
            if (isAdmin) _MobileNavItem('ADMIN', () { Navigator.pop(context); context.go(AppRoutes.admin); }),
            const Divider(color: AppColors.border),
            if (isLoggedIn)
              _MobileNavItem('MY PROFILE', () {
                Navigator.pop(context);
                final uid = ref.read(authServiceProvider).currentUser?.uid;
                if (uid != null) context.go('/profile/$uid');
              })
            else
              _MobileNavItem('LOGIN', () { Navigator.pop(context); context.go(AppRoutes.login); }),
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
        Text(
          '✦',
          style: TextStyle(color: AppColors.primary, fontSize: fontSize * 0.7),
        ),
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
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '✦',
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
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
          '✦ ${title}',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Footer ─────────────────────────────────────────────────────
class RzFooter extends StatelessWidget {
  const RzFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RzLogo(),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppConstants.motto,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '© 2025 RIZZNIGHT. ALL RIGHTS RESERVED.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
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
