import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/icon_circle_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/scan_action_bar.dart';
import '../widgets/scan_preview_frame.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedImage;

  Future<void> _pickImageFromGallery() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );

    if (!mounted || pickedImage == null) return;

    setState(() {
      _selectedImage = pickedImage;
    });
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _onAnalyzePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dummy analyzing flow will be added in the next stage.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedImage = _selectedImage != null;

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ScanPreviewFrame(
                imageFile: hasSelectedImage
                    ? File(_selectedImage!.path)
                    : null,
              ),
            ),

            Positioned(
              top: AppSpacing.lg,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: _ScanTopBar(
                hasSelectedImage: hasSelectedImage,
                onClosePressed: hasSelectedImage ? _clearSelectedImage : null,
              ),
            ),

            if (hasSelectedImage)
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: PrimaryButton(
                  label: 'Analyze Food',
                  icon: LucideIcons.sparkles,
                  onPressed: _onAnalyzePressed,
                ),
              )
            else
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: ScanActionBar(
                  onCapturePressed: () {},
                  onGalleryPressed: _pickImageFromGallery,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScanTopBar extends StatelessWidget {
  const _ScanTopBar({
    required this.hasSelectedImage,
    required this.onClosePressed,
  });

  final bool hasSelectedImage;
  final VoidCallback? onClosePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconCircleButton(
          icon: LucideIcons.x,
          onPressed: onClosePressed ?? () {},
          backgroundColor: Colors.white.withValues(alpha: 0.14),
          foregroundColor: Colors.white,
        ),
        const Spacer(),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            hasSelectedImage ? 'Preview' : 'Food Scan',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}