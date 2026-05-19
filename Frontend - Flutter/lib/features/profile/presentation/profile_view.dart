import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../models/user.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isProvider = user.role == UserRole.provider;
    final initials =
        '${user.firstName?.isNotEmpty == true ? user.firstName![0] : ''}${user.lastName?.isNotEmpty == true ? user.lastName![0] : ''}'
            .toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar + name header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF003A9E), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials.isEmpty ? 'U' : initials,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isProvider) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.isVerified == true
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.isVerified == true
                            ? '✓ Verified Provider'
                            : 'Pending Verification',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: user.isVerified == true
                              ? const Color(0xFF15803D)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Account card
            _ProfileCard(
              title: 'Account',
              icon: Icons.person_outline,
              children: [
                _ProfileRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email ?? '—',
                ),
                if (user.phone != null)
                  _ProfileRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: user.phone!,
                  ),
                _ProfileRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Credits',
                  value:
                      'PKR ${(user.creditBalance ?? 0.0).toStringAsFixed(0)}',
                  valueColor: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Provider Info card
            if (isProvider) ...[
              _ProfileCard(
                title: 'Provider Info',
                icon: Icons.work_outline,
                children: [
                  if (user.bio != null && user.bio!.isNotEmpty)
                    _ProfileRow(
                      icon: Icons.description_outlined,
                      label: 'Bio',
                      value: user.bio!,
                    ),
                  _ProfileRow(
                    icon: Icons.star_outline,
                    label: 'Rating',
                    value: (user.rating ?? 0.0).toStringAsFixed(1),
                  ),
                  _ProfileRow(
                    icon: Icons.check_circle_outline,
                    label: 'Jobs Done',
                    value: '${user.totalJobs ?? 0}',
                  ),
                  // Active toggle
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.toggle_on_outlined,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Status',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Available for new bookings',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: user.isActive ?? true,
                          onChanged: (val) {
                            ref
                                .read(authControllerProvider.notifier)
                                .updateProfile(isActive: val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Settings card
            _ProfileCard(
              title: 'Settings',
              icon: Icons.settings_outlined,
              children: [
                _SettingsRow(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRouter.editProfile),
                ),
                _SettingsRow(
                  icon: Icons.logout,
                  label: 'Logout',
                  destructive: true,
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRouter.login);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFDC2626) : AppTheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!destructive)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
