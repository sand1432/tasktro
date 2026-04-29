import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/booking_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/booking_provider.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      context.read<BookingProvider>().loadBookings(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    final activeBookings = bookingProvider.bookings
        .where((b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.inProgress)
        .toList();

    final completedBookings = bookingProvider.bookings
        .where((b) => b.status == BookingStatus.completed)
        .toList();

    final cancelledBookings = bookingProvider.bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${activeBookings.length})'),
            Tab(text: 'Completed (${completedBookings.length})'),
            Tab(text: 'Cancelled (${cancelledBookings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingList(
            bookings: activeBookings,
            emptyMessage: 'No active bookings',
            isLoading: bookingProvider.isLoading,
          ),
          _BookingList(
            bookings: completedBookings,
            emptyMessage: 'No completed bookings yet',
            isLoading: bookingProvider.isLoading,
          ),
          _BookingList(
            bookings: cancelledBookings,
            emptyMessage: 'No cancelled bookings',
            isLoading: bookingProvider.isLoading,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ai-analyze'),
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    this.isLoading = false,
  });

  final List<BookingModel> bookings;
  final String emptyMessage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 64, color: AppColors.textSecondaryLight),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final userId = context.read<AuthProvider>().user?.id;
        if (userId != null) {
          await context.read<BookingProvider>().loadBookings(userId);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _BookingCard(booking: booking);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingModel booking;

  Color _statusColor(BookingStatus status) {
    return switch (status) {
      BookingStatus.pending => AppColors.warning,
      BookingStatus.confirmed => AppColors.info,
      BookingStatus.inProgress => AppColors.primary,
      BookingStatus.completed => AppColors.success,
      BookingStatus.cancelled => AppColors.error,
      BookingStatus.disputed => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/booking/${booking.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName ?? 'Service',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _statusColor(booking.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.status.displayName,
                      style: TextStyle(
                        color: _statusColor(booking.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (booking.providerName != null)
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 4),
                    Text(booking.providerName!),
                  ],
                ),
              if (booking.scheduledAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 4),
                    Text(DateFormatter.formatDateTime(booking.scheduledAt!)),
                  ],
                ),
              ],
              if (booking.estimatedCostMin != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16),
                    Text(DateFormatter.formatPriceRange(
                      booking.estimatedCostMin!,
                      booking.estimatedCostMax ?? booking.estimatedCostMin!,
                    )),
                    if (booking.isLocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock,
                                size: 12, color: AppColors.success),
                            SizedBox(width: 2),
                            Text(
                              'Locked',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
