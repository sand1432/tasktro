import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../services/location/location_service.dart';
import '../providers/ai_provider.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  final _descriptionController = TextEditingController();
  final List<String> _selectedImages = [];
  bool _isRecordingVoice = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImages.add(image.path));
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImages.add(image.path));
    }
  }

  Future<void> _analyze() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your problem')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final aiProvider = context.read<AiProvider>();

    double? lat, lng;
    final locationResult = await LocationService.instance.getCurrentLocation();
    locationResult.when(
      success: (position) {
        lat = position.latitude;
        lng = position.longitude;
      },
      failure: (_) {},
    );

    final analysis = await aiProvider.analyzeIssue(
      description: _descriptionController.text.trim(),
      imageUrls: _selectedImages,
      userId: authProvider.user?.id,
      latitude: lat,
      longitude: lng,
    );

    if (analysis != null && mounted) {
      context.push('/ai-result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Problem Solver'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: aiProvider.isAnalyzing,
        message: 'Analyzing your problem...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
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
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Describe your issue using text, photos, or voice. Our AI will diagnose the problem and suggest solutions.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description input
              Text(
                'Describe Your Problem',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText:
                      'e.g., My kitchen faucet is leaking from the base. Water drips constantly when the faucet is on...',
                  alignLabelWithHint: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isRecordingVoice ? Icons.mic : Icons.mic_none,
                      color: _isRecordingVoice
                          ? AppColors.error
                          : AppColors.textSecondaryLight,
                    ),
                    onPressed: () {
                      setState(
                          () => _isRecordingVoice = !_isRecordingVoice);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image upload section
              Text(
                'Add Photos (Optional)',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ImagePickerButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: _takePhoto,
                  ),
                  const SizedBox(width: 12),
                  _ImagePickerButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: _pickImage,
                  ),
                ],
              ),

              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image,
                                  color: AppColors.primary),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedImages.removeAt(index)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Analyze button
              ElevatedButton(
                onPressed: _analyze,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.primary,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 20),
                    SizedBox(width: 8),
                    Text('Analyze with AI',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              if (aiProvider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    aiProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Safety disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI analysis is for guidance only. For safety-critical issues (gas leaks, electrical hazards), contact emergency services immediately.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  const _ImagePickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
