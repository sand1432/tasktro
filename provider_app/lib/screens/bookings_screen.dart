import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingsList(type: 'upcoming'),
            _BookingsList(type: 'active'),
            _BookingsList(type: 'completed'),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (type == 'active') {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProviderBookingCard(
            service: 'Plumbing - Leak Repair',
            customer: 'John Smith',
            address: '123 Main St, Apt 4B',
            time: 'Now - In Progress',
            status: 'In Progress',
            statusColor: colorScheme.primary,
          ),
        ],
      );
    }

    if (type == 'upcoming') {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProviderBookingCard(
            service: 'Electrical - Outlet Install',
            customer: 'Jane Doe',
            address: '456 Oak Ave',
            time: 'Tomorrow, 2:00 PM',
            status: 'Confirmed',
            statusColor: Colors.blue,
          ),
          const SizedBox(height: 8),
          _ProviderBookingCard(
            service: 'HVAC - AC Maintenance',
            customer: 'Bob Wilson',
            address: '789 Pine Rd',
            time: 'Apr 30, 10:00 AM',
            status: 'Confirmed',
            statusColor: Colors.blue,
          ),
        ],
      );
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No completed bookings yet'),
        ],
      ),
    );
  }
}

class _ProviderBookingCard extends StatelessWidget {
  const _ProviderBookingCard({
    required this.service,
    required this.customer,
    required this.address,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  final String service;
  final String customer;
  final String address;
  final String time;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(service,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(customer),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(address),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(time),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Chat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation, size: 18),
                    label: const Text('Navigate'),
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
