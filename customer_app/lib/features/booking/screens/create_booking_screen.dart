import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../data/models/booking_model.dart';
import '../../../features/ai_assistant/providers/ai_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/booking_provider.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  BookingType _bookingType = BookingType.scheduled;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _lockPrice = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _createBooking() async {
    final authProvider = context.read<AuthProvider>();
    final aiProvider = context.read<AiProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (authProvider.user == null) return;

    final analysis = aiProvider.currentAnalysis;
    DateTime? scheduledAt;

    if (_bookingType == BookingType.scheduled) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')),
        );
        return;
      }
      scheduledAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final booking = BookingModel(
      id: const Uuid().v4(),
      userId: authProvider.user!.id,
      providerId: '',
      serviceId: analysis?.suggestedServiceCategory ?? '',
      status: BookingStatus.pending,
      bookingType: _bookingType,
      description: analysis?.problem ?? _notesController.text,
      scheduledAt: scheduledAt,
      address: _addressController.text.isNotEmpty
          ? _addressController.text
          : authProvider.user!.address,
      latitude: authProvider.user!.latitude,
      longitude: authProvider.user!.longitude,
      estimatedCostMin: analysis?.estimatedCostMin,
      estimatedCostMax: analysis?.estimatedCostMax,
      isLocked: _lockPrice,
      lockedPrice: _lockPrice
          ? (analysis?.estimatedCostMax ?? analysis?.estimatedCostMin)
          : null,
      lockedAt: _lockPrice ? DateTime.now() : null,
      aiRequestId: analysis?.id,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      serviceName: analysis?.suggestedServiceCategory,
    );

    final result = await bookingProvider.createBooking(booking);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully!')),
      );
      context.go('/bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final analysis = aiProvider.currentAnalysis;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: bookingProvider.isLoading,
        message: 'Creating booking...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AI Summary (if available)
              if (analysis != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text('AI Analysis Summary',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(analysis.problem),
                      const SizedBox(height: 8),
                      Text(
                        'Est. ${DateFormatter.formatPriceRange(analysis.estimatedCostMin, analysis.estimatedCostMax)}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Booking Type
              Text('Booking Type',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.flash_on,
                      title: 'Instant',
                      subtitle: '30-60 min',
                      isSelected: _bookingType == BookingType.instant,
                      color: AppColors.warning,
                      onTap: () =>
                          setState(() => _bookingType = BookingType.instant),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.schedule,
                      title: 'Scheduled',
                      subtitle: 'Pick date & time',
                      isSelected: _bookingType == BookingType.scheduled,
                      color: AppColors.info,
                      onTap: () =>
                          setState(() => _bookingType = BookingType.scheduled),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date & Time (for scheduled)
              if (_bookingType == BookingType.scheduled) ...[
                Text('Schedule',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_selectedDate != null
                            ? DateFormatter.formatDate(_selectedDate!)
                            : 'Select Date'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select Time'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Address
              Text('Service Address',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter service address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Notes
              Text('Additional Notes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any additional details...',
                ),
              ),
              const SizedBox(height: 20),

              // Price Lock
              if (analysis != null) ...[
                SwitchListTile(
                  title: const Text('Lock Price'),
                  subtitle: Text(
                    'Lock the estimated price of ${DateFormatter.formatCurrency(analysis.estimatedCostMax)} to avoid price changes',
                  ),
                  value: _lockPrice,
                  onChanged: (v) => setState(() => _lockPrice = v),
                  activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
              ],

              // Submit
              ElevatedButton(
                onPressed: _createBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(
                  _bookingType == BookingType.instant
                      ? 'Book Instantly'
                      : 'Schedule Booking',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : null)),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
