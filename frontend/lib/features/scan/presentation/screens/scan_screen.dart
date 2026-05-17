import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/icon_circle_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/repositories/camera_repository.dart';
import '../widgets/scan_action_bar.dart';
import '../widgets/scan_preview_frame.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final ImagePicker _imagePicker = ImagePicker();
  final CameraRepository _cameraRepository = const CameraRepository();

  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;

  XFile? _selectedImage;
  String? _cameraErrorMessage;

  bool get _hasSelectedImage => _selectedImage != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraFuture = _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    }

    if (state == AppLifecycleState.resumed && !_hasSelectedImage) {
      _initializeCameraFuture = _initializeCamera();
      setState(() {});
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await _cameraRepository.getAvailableCameras();
      final selectedCamera = _cameraRepository.getBackCamera(cameras);

      if (selectedCamera == null) {
        if (!mounted) return;

        setState(() {
          _cameraErrorMessage = 'No camera device found.';
        });
        return;
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController?.dispose();
      _cameraController = controller;

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _cameraErrorMessage = null;
      });
    } on CameraException catch (error) {
      if (!mounted) return;

      setState(() {
        _cameraErrorMessage = _mapCameraError(error);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _cameraErrorMessage = 'Failed to initialize camera.';
      });
    }
  }

  String _mapCameraError(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        return 'Camera permission is required to scan food.';
      default:
        return 'Failed to open camera.';
    }
  }

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

  Future<void> _captureImage() async {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      _showMessage('Camera is not ready yet.');
      return;
    }

    if (controller.value.isTakingPicture) {
      return;
    }

    try {
      final capturedImage = await controller.takePicture();

      if (!mounted) return;

      setState(() {
        _selectedImage = capturedImage;
      });
    } on CameraException {
      if (!mounted) return;
      _showMessage('Failed to capture image.');
    }
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedImage = _hasSelectedImage;

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder<void>(
                future: _initializeCameraFuture,
                builder: (context, snapshot) {
                  return ScanPreviewFrame(
                    imageFile: hasSelectedImage
                        ? File(_selectedImage!.path)
                        : null,
                    cameraController:
                        hasSelectedImage ? null : _cameraController,
                    cameraErrorMessage: _cameraErrorMessage,
                    isInitializingCamera:
                        snapshot.connectionState == ConnectionState.waiting &&
                            !hasSelectedImage,
                  );
                },
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
                  onCapturePressed: _captureImage,
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