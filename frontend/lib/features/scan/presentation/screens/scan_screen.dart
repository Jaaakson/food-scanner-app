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
import '../../data/repositories/food_scan_repository.dart';
import '../../models/food_prediction.dart';
import '../widgets/analyzing_overlay.dart';
import '../widgets/prediction_results_panel.dart';
import '../widgets/scan_action_bar.dart';
import '../widgets/scan_preview_frame.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    this.onCloseRequested,
  });

  final VoidCallback? onCloseRequested;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final ImagePicker _imagePicker = ImagePicker();
  final CameraRepository _cameraRepository = const CameraRepository();
  final FoodScanRepository _foodScanRepository = const FoodScanRepository();

  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;

  XFile? _selectedImage;
  String? _cameraErrorMessage;

  bool _isAnalyzing = false;
  List<FoodPrediction> _predictions = const [];
  FoodPrediction? _selectedPrediction;

  bool get _hasSelectedImage => _selectedImage != null;
  bool get _hasPredictions => _predictions.isNotEmpty;

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
      return;
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
    if (_isAnalyzing) return;

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );

    if (!mounted || pickedImage == null) return;

    setState(() {
      _selectedImage = pickedImage;
      _predictions = const [];
      _selectedPrediction = null;
    });
  }

  Future<void> _captureImage() async {
    if (_isAnalyzing) return;

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
        _predictions = const [];
        _selectedPrediction = null;
      });
    } on CameraException {
      if (!mounted) return;
      _showMessage('Failed to capture image.');
    }
  }

  Future<void> _analyzeSelectedImage() async {
    final image = _selectedImage;

    if (image == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _predictions = const [];
      _selectedPrediction = null;
    });

    try {
      final predictions = await _foodScanRepository.analyzeImage(image);

      if (!mounted) return;

      setState(() {
        _predictions = predictions;
        _isAnalyzing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      _showMessage('Failed to analyze image.');
    }
  }

  void _selectPrediction(FoodPrediction prediction) {
    setState(() {
      _selectedPrediction = prediction;
    });
  }

  void _clearSelectedPrediction() {
    setState(() {
      _selectedPrediction = null;
    });
  }

  void _clearSelectedImage() {
    if (_isAnalyzing) return;

    setState(() {
      _selectedImage = null;
      _predictions = const [];
      _selectedPrediction = null;
    });
  }

  void _scanAgain() {
    if (_isAnalyzing) return;

    setState(() {
      _selectedImage = null;
      _predictions = const [];
      _selectedPrediction = null;
    });
  }

  void _saveResult() {
    final prediction = _selectedPrediction;

    if (prediction == null) return;

    _showMessage('${prediction.name} saved locally as dummy result.');
  }

  void _handleClosePressed() {
    if (_isAnalyzing) return;

    if (_hasSelectedImage || _hasPredictions) {
      _clearSelectedImage();
      return;
    }

    widget.onCloseRequested?.call();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
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
              top: AppSpacing.xl,
              left: AppSpacing.xxl,
              right: AppSpacing.xl,
              child: _ScanTopBar(
                hasSelectedImage: hasSelectedImage,
                hasPredictions: _hasPredictions,
                onClosePressed: _handleClosePressed,
              ),
            ),
            if (hasSelectedImage && !_hasPredictions)
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: PrimaryButton(
                  label: 'Analyze Food',
                  icon: LucideIcons.sparkles,
                  isLoading: _isAnalyzing,
                  onPressed: _isAnalyzing ? null : _analyzeSelectedImage,
                ),
              )
            else if (!hasSelectedImage)
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: ScanActionBar(
                  onCapturePressed: _captureImage,
                  onGalleryPressed: _pickImageFromGallery,
                ),
              ),
            if (_hasPredictions)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PredictionResultsPanel(
                  predictions: _predictions,
                  selectedPrediction: _selectedPrediction,
                  onPredictionSelected: _selectPrediction,
                  onClearSelection: _clearSelectedPrediction,
                  onSavePressed: _saveResult,
                  onScanAgainPressed: _scanAgain,
                ),
              ),
            if (_isAnalyzing) const AnalyzingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _ScanTopBar extends StatelessWidget {
  const _ScanTopBar({
    required this.hasSelectedImage,
    required this.hasPredictions,
    required this.onClosePressed,
  });

  final bool hasSelectedImage;
  final bool hasPredictions;
  final VoidCallback onClosePressed;

  String get _title {
    if (hasPredictions) return 'Analyzed';
    if (hasSelectedImage) return 'Preview';
    return 'Food Scan';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconCircleButton(
              icon: LucideIcons.x,
              onPressed: onClosePressed,
              backgroundColor: Colors.black.withValues(alpha: 0.24),
              foregroundColor: Colors.white,
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Text(
                  _title,
                  key: ValueKey<String>(_title),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}