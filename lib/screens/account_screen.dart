import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

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
        title: Text('Profil', style: displayFont(fontSize: 22)),
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
                      onPressed: wardrobe.isSyncing || wardrobe.isSigningIn
                          ? null
                          : () => wardrobe.signInWithGoogle(),
                      icon: wardrobe.isSigningIn
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        wardrobe.isSigningIn ? 'Logowanie…' : 'Zaloguj przez Google',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                  ),
                  if (wardrobe.syncError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      wardrobe.syncError!,
                      style: const TextStyle(color: AppColors.wine, fontSize: 12, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            _panel(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage:
                        user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.displayName?.isNotEmpty == true
                                    ? user.displayName![0]
                                    : user.email?[0] ?? '?')
                                .toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.displayName ?? 'Zalogowana',
                                style: displayFont(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (wardrobe.isPremium) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
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
          const SizedBox(height: 14),
          _panel(
            child: Row(
              children: [
                const Icon(Icons.settings_outlined, size: 20, color: AppColors.inkSoft),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ustawienia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Wkrótce - do rozbudowy',
                          style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _panel({required Widget child}) {
    return GlassCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
