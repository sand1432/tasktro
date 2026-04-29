import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          Text('Appearance',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark theme'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleDarkMode(),
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(
                    localeProvider.locale.languageCode == 'en'
                        ? 'English'
                        : 'Espa\u00f1ol',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguagePicker(context, localeProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications
          Text('Notifications',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Booking updates, promotions'),
                  value: true,
                  onChanged: (_) {},
                  secondary: const Icon(Icons.notifications),
                ),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receipts, reports'),
                  value: true,
                  onChanged: (_) {},
                  secondary: const Icon(Icons.email),
                ),
                SwitchListTile(
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Booking confirmations'),
                  value: false,
                  onChanged: (_) {},
                  secondary: const Icon(Icons.sms),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy & Security
          Text('Privacy & Security',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Login'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About
          Text('About',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('App Version'),
                  trailing: Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Rate App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Delete account
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              trailing: provider.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                provider.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Espa\u00f1ol'),
              leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
              trailing: provider.locale.languageCode == 'es'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                provider.setLocale(const Locale('es'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
