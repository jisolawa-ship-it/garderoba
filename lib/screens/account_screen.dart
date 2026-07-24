import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final user = wardrobe.user;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Konto', style: displayFont(fontSize: 26)),
        foregroundColor: AppColors.ink,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user == null) ...[
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zaloguj się kontem Google',
                    style: displayFont(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Twoja szafa i stylizacje zostaną zapisane w chmurze — nie '
                    'stracisz ich przy aktualizacji, ponownej instalacji aplikacji '
                    'ani zmianie telefonu.',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: wardrobe.isSyncing
                          ? null
                          : () => wardrobe.signInWithGoogle(),
                      icon: const Icon(Icons.login),
                      label: const Text('Zaloguj przez Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.paper,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _panel(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.wineSoft,
                    backgroundImage:
                        user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.displayName?.isNotEmpty == true
                                    ? user.displayName![0]
                                    : user.email?[0] ?? '?')
                                .toUpperCase(),
                            style: const TextStyle(color: AppColors.wine, fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Zalogowana',
                          style: displayFont(fontSize: 16),
                        ),
                        if (user.email != null)
                          Text(
                            user.email!,
                            style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        wardrobe.isSyncing
                            ? Icons.sync
                            : (wardrobe.syncError != null ? Icons.error_outline : Icons.cloud_done_outlined),
                        size: 18,
                        color: wardrobe.syncError != null ? AppColors.wine : AppColors.sage,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          wardrobe.isSyncing
                              ? 'Synchronizowanie…'
                              : wardrobe.syncError ??
                                  (wardrobe.lastSyncedAt != null
                                      ? 'Zsynchronizowano o ${_fmtTime(wardrobe.lastSyncedAt!)}'
                                      : 'Jeszcze nie synchronizowano'),
                          style: TextStyle(
                            fontSize: 12,
                            color: wardrobe.syncError != null ? AppColors.wine : AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: wardrobe.isSyncing ? null : () => wardrobe.syncNow(),
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Synchronizuj teraz'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.line),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => wardrobe.signOut(),
                icon: const Icon(Icons.logout, color: AppColors.wine, size: 18),
                label: const Text('Wyloguj się', style: TextStyle(color: AppColors.wine)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}
