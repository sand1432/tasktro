import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/booking/providers/booking_provider.dart';
import '../widgets/service_category_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/active_booking_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated && authProvider.user != null) {
      context.read<BookingProvider>().loadBookings(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final userName = authProvider.user?.fullName.split(' ').first ?? 'there';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $userName!',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'What needs fixing today?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error),
                    onPressed: () => context.push('/emergency'),
                    tooltip: 'Emergency',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),

              // AI Analyze Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => context.push('/ai-analyze'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.aiGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI Problem Solver',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Describe your issue and get instant AI diagnosis with cost estimates',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'Start Analysis',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.flash_on,
                              label: 'Instant\nBooking',
                              color: AppColors.warning,
                              onTap: () => context.push('/create-booking'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.schedule,
                              label: 'Schedule\nLater',
                              color: AppColors.info,
                              onTap: () => context.push('/create-booking'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.video_call,
                              label: 'Video\nInspect',
                              color: AppColors.secondary,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.history,
                              label: 'Past\nBookings',
                              color: AppColors.success,
                              onTap: () => context.go('/bookings'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Active Bookings
              if (bookingProvider.activeBookings.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Bookings',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => context.go('/bookings'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final booking = bookingProvider.activeBookings[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ActiveBookingCard(
                          booking: booking,
                          onTap: () => context.push('/booking/${booking.id}'),
                        ),
                      );
                    },
                    childCount: bookingProvider.activeBookings.length.clamp(0, 3),
                  ),
                ),
              ],

              // Popular Services
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Popular Services',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  delegate: SliverChildListDelegate([
                    ServiceCategoryCard(
                      icon: Icons.plumbing,
                      title: 'Plumbing',
                      subtitle: 'From \$50',
                      color: AppColors.info,
                      onTap: () => context.push('/ai-analyze'),
                    ),
                    ServiceCategoryCard(
                      icon: Icons.electrical_services,
                      title: 'Electrical',
                      subtitle: 'From \$60',
                      color: AppColors.warning,
                      onTap: () => context.push('/ai-analyze'),
                    ),
                    ServiceCategoryCard(
                      icon: Icons.hvac,
                      title: 'HVAC',
                      subtitle: 'From \$80',
                      color: AppColors.success,
                      onTap: () => context.push('/ai-analyze'),
                    ),
                    ServiceCategoryCard(
                      icon: Icons.cleaning_services,
                      title: 'Cleaning',
                      subtitle: 'From \$40',
                      color: AppColors.secondary,
                      onTap: () => context.push('/ai-analyze'),
                    ),
                    ServiceCategoryCard(
                      icon: Icons.roofing,
                      title: 'Roofing',
                      subtitle: 'From \$100',
                      color: AppColors.error,
                      onTap: () => context.push('/ai-analyze'),
                    ),
                    ServiceCategoryCard(
                      icon: Icons.format_paint,
                      title: 'Painting',
                      subtitle: 'From \$45',
                      color: AppColors.accent,
                      onTap: () => context.push('/ai-analyze'),
                    ),
                  ]),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
