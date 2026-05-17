import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class ScanPreviewFrame extends StatelessWidget {
  const ScanPreviewFrame({
    super.key,
    this.imageFile,
  });

  final File? imageFile;

  bool get _hasImage => imageFile != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        118,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF303830),
            Color(0xFF121612),
          ],
        ),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _hasImage
              ? _SelectedImagePreview(
                  key: const ValueKey('selected-image-preview'),
                  imageFile: imageFile!,
                )
              : const _EmptyScanPreview(
                  key: ValueKey('empty-scan-preview'),
                ),
        ),
      ),
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({
    super.key,
    required this.imageFile,
  });

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x11000000),
                  Color(0x88000000),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.xl,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.image,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Image selected. Ready to analyze.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyScanPreview extends StatelessWidget {
  const _EmptyScanPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _ScanGridPainter(),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Colors.transparent,
                  Color(0x77000000),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            height: 210,
            width: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
                width: 1.4,
              ),
            ),
            child: const Stack(
              children: [
                _CornerIndicator(
                  alignment: Alignment.topLeft,
                ),
                _CornerIndicator(
                  alignment: Alignment.topRight,
                ),
                _CornerIndicator(
                  alignment: Alignment.bottomLeft,
                ),
                _CornerIndicator(
                  alignment: Alignment.bottomRight,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.scanLine,
                size: 28,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Place your food inside the frame',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Use gallery upload now. Camera support will be added later.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerIndicator extends StatelessWidget {
  const _CornerIndicator({
    required this.alignment,
  });

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;

    const spacing = 42.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}