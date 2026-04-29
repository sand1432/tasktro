import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    // In production, this would fetch the report from the repository
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Report header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 48),
                  const SizedBox(height: 8),
                  Text('Service Completed',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Booking #${bookingId.substring(0, 8)}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary
            _ReportSection(
              title: 'Summary',
              icon: Icons.description,
              child: const Text(
                'The service has been completed successfully. All identified issues have been addressed.',
              ),
            ),
            const SizedBox(height: 12),

            // Work performed
            _ReportSection(
              title: 'Work Performed',
              icon: Icons.build,
              child: Column(
                children: [
                  _WorkItem('Inspected the issue area'),
                  _WorkItem('Diagnosed the root cause'),
                  _WorkItem('Performed necessary repairs'),
                  _WorkItem('Tested and verified the fix'),
                  _WorkItem('Cleaned up the work area'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Cost breakdown
            _ReportSection(
              title: 'Cost Breakdown',
              icon: Icons.receipt_long,
              child: Column(
                children: [
                  _CostRow('Service Fee', DateFormatter.formatCurrency(85.0)),
                  _CostRow('Parts & Materials', DateFormatter.formatCurrency(35.0)),
                  _CostRow('Labor (2 hours)', DateFormatter.formatCurrency(120.0)),
                  const Divider(),
                  _CostRow('Total', DateFormatter.formatCurrency(240.0),
                      isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Warranty
            _ReportSection(
              title: 'Warranty',
              icon: Icons.verified_user,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('90-day warranty on all work performed'),
                  const SizedBox(height: 4),
                  Text(
                    'Expires: ${DateFormatter.formatDate(DateTime.now().add(const Duration(days: 90)))}',
                    style: const TextStyle(color: AppColors.success),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recommendations
            _ReportSection(
              title: 'Preventive Recommendations',
              icon: Icons.lightbulb_outline,
              child: Column(
                children: [
                  _WorkItem('Schedule regular maintenance every 6 months'),
                  _WorkItem('Replace filters as recommended by manufacturer'),
                  _WorkItem('Monitor for any recurring issues'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Before/After
            Text('Before & After',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo, color: Colors.grey, size: 40),
                          SizedBox(height: 4),
                          Text('Before', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo, color: Colors.grey, size: 40),
                          SizedBox(height: 4),
                          Text('After', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _WorkItem extends StatelessWidget {
  const _WorkItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow(this.label, this.value, {this.isBold = false});

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  : null),
          Text(value,
              style: isBold
                  ? const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary)
                  : null),
        ],
      ),
    );
  }
}
