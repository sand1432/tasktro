import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final booking = bookingProvider.bookings
        .where((b) => b.id == bookingId)
        .firstOrNull;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text('Booking not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          if (booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.confirmed)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'cancel') {
                  _showCancelDialog(context, bookingProvider);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Cancel Booking'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _StatusCard(booking: booking),
            const SizedBox(height: 16),

            // Service Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _InfoRow(
                        icon: Icons.home_repair_service,
                        label: booking.serviceName ?? 'Service'),
                    if (booking.description != null)
                      _InfoRow(
                          icon: Icons.description,
                          label: booking.description!),
                    if (booking.address != null)
                      _InfoRow(icon: Icons.location_on, label: booking.address!),
                    if (booking.scheduledAt != null)
                      _InfoRow(
                        icon: Icons.schedule,
                        label: DateFormatter.formatDateTime(
                            booking.scheduledAt!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Provider Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Provider',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.providerName ?? 'Provider',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const Row(
                                children: [
                                  Icon(Icons.star,
                                      color: AppColors.warning, size: 16),
                                  SizedBox(width: 2),
                                  Text('4.8 (120 reviews)'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () =>
                              context.push('/chat/${booking.id}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Pricing
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pricing',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (booking.estimatedCostMin != null)
                      _PriceRow(
                        label: 'Estimated',
                        value: DateFormatter.formatPriceRange(
                          booking.estimatedCostMin!,
                          booking.estimatedCostMax ?? booking.estimatedCostMin!,
                        ),
                      ),
                    if (booking.isLocked && booking.lockedPrice != null)
                      _PriceRow(
                        label: 'Locked Price',
                        value: DateFormatter.formatCurrency(
                            booking.lockedPrice!),
                        isLocked: true,
                      ),
                    if (booking.finalCost != null)
                      _PriceRow(
                        label: 'Final Cost',
                        value: DateFormatter.formatCurrency(
                            booking.finalCost!),
                        isFinal: true,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (booking.status == BookingStatus.completed) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/report/${booking.id}'),
                      icon: const Icon(Icons.description),
                      label: const Text('View Report'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/review/${booking.id}'),
                      icon: const Icon(Icons.star),
                      label: const Text('Leave Review'),
                    ),
                  ),
                ],
              ),
            ],
            if (booking.status == BookingStatus.confirmed) ...[
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Track Provider'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, BookingProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
            'Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.cancelBooking(bookingId);
              Navigator.pop(ctx);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final color = switch (booking.status) {
      BookingStatus.pending => AppColors.warning,
      BookingStatus.confirmed => AppColors.info,
      BookingStatus.inProgress => AppColors.primary,
      BookingStatus.completed => AppColors.success,
      _ => AppColors.error,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            booking.status == BookingStatus.completed
                ? Icons.check_circle
                : Icons.info,
            color: color,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.status.displayName,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Text(
                booking.bookingType == BookingType.instant
                    ? 'Instant Booking'
                    : 'Scheduled Booking',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isLocked = false,
    this.isFinal = false,
  });

  final String label;
  final String value;
  final bool isLocked;
  final bool isFinal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(label),
              if (isLocked) ...[
                const SizedBox(width: 4),
                const Icon(Icons.lock, size: 14, color: AppColors.success),
              ],
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              fontSize: isFinal ? 18 : 14,
              color: isFinal ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
