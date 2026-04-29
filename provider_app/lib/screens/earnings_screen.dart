import 'package:flutter/material.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total earnings card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Total Earnings',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('\$12,450.00',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _EarningStat(label: 'This Week', value: '\$1,240'),
                      _EarningStat(label: 'This Month', value: '\$4,850'),
                      _EarningStat(label: 'Jobs', value: '156'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Recent Transactions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _TransactionItem(
              service: 'Plumbing - Leak Repair',
              customer: 'John Smith',
              amount: '\$185.00',
              date: 'Today',
              isPending: false,
            ),
            _TransactionItem(
              service: 'Electrical - Outlet Install',
              customer: 'Jane Doe',
              amount: '\$120.00',
              date: 'Yesterday',
              isPending: true,
            ),
            _TransactionItem(
              service: 'HVAC - AC Service',
              customer: 'Bob Wilson',
              amount: '\$280.00',
              date: 'Apr 27',
              isPending: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningStat extends StatelessWidget {
  const _EarningStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.service,
    required this.customer,
    required this.amount,
    required this.date,
    required this.isPending,
  });

  final String service;
  final String customer;
  final String amount;
  final String date;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isPending ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
          child: Icon(
            isPending ? Icons.hourglass_bottom : Icons.check_circle,
            color: isPending ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(service, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$customer - $date'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text(isPending ? 'Pending' : 'Paid',
                style: TextStyle(
                    color: isPending ? Colors.orange : Colors.green,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
