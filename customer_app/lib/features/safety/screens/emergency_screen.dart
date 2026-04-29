import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/location/location_service.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _callEmergency() async {
    final uri = Uri(scheme: 'tel', path: '911');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _shareLocation(BuildContext context) async {
    final result = await LocationService.instance.getCurrentLocation();
    result.when(
      success: (position) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location shared: ${position.latitude}, ${position.longitude}',
            ),
          ),
        );
      },
      failure: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: ${e.message}')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emergency call
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emergency, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Emergency',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you are in immediate danger, call 911',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _callEmergency,
                    icon: const Icon(Icons.phone),
                    label: const Text('Call 911'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share location
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on, color: AppColors.info),
                ),
                title: const Text('Share Live Location'),
                subtitle: const Text('Share your location with emergency contacts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _shareLocation(context),
              ),
            ),
            const SizedBox(height: 12),

            // Report issue
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.report, color: AppColors.warning),
                ),
                title: const Text('Report a Problem'),
                subtitle: const Text('Report an issue with a provider'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),

            // Safety tips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text('Safety Tips',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SafetyTip('Always verify provider identity before letting them in'),
                    _SafetyTip('Keep the app open during the service for live tracking'),
                    _SafetyTip('Use in-app payments only - never pay cash'),
                    _SafetyTip('Take before/after photos of all work'),
                    _SafetyTip('Rate and review your provider after service'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTip extends StatelessWidget {
  const _SafetyTip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
