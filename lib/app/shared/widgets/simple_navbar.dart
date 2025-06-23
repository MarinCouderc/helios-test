import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helios/l10n/l10n.dart';

class SimpleNavbar extends StatelessWidget {
  const SimpleNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _NavButton(
                label: context.l10n.navbarWelcome,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                isActive: currentLocation == '/',
                onTap: () => context.go('/'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _NavButton(
                label: context.l10n.navbarUsers,
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                isActive: currentLocation == '/user-list',
                onTap: () => context.go('/user-list'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isActive 
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive 
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive 
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
