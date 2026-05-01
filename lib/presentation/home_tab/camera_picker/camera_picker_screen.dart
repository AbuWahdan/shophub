import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/app/app_theme.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../widgets/widgets/app_button.dart';
import 'visual_search_loading_screen.dart';

class CameraPickerScreen extends StatefulWidget {
  const CameraPickerScreen({super.key});

  @override
  State<CameraPickerScreen> createState() => _CameraPickerScreenState();
}

class _CameraPickerScreenState extends State<CameraPickerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final hasPermission = await _ensurePermission(source);
      if (!mounted || !hasPermission) {
        return;
      }

      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (!mounted || picked == null) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VisualSearchLoadingScreen(imageFile: File(picked.path)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  Future<bool> _ensurePermission(ImageSource source) async {
    final status = source == ImageSource.camera
        ? await Permission.camera.request()
        : await _requestGalleryPermission();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    await _showPermissionDialog(
      title: source == ImageSource.camera
          ? 'Camera permission required'
          : 'Gallery permission required',
      message: source == ImageSource.camera
          ? 'Please allow camera access so you can capture a photo for visual search.'
          : 'Please allow photo access so you can choose an image for visual search.',
      openSettingsAction: status.isPermanentlyDenied || status.isRestricted,
    );
    return false;
  }

  Future<PermissionStatus> _requestGalleryPermission() async {
    final photoStatus = await Permission.photos.request();
    if (photoStatus.isGranted ||
        photoStatus.isLimited ||
        photoStatus.isPermanentlyDenied ||
        photoStatus.isRestricted) {
      return photoStatus;
    }

    if (Platform.isAndroid) {
      return Permission.storage.request();
    }

    return photoStatus;
  }

  Future<void> _showPermissionDialog({
    required String title,
    required String message,
    required bool openSettingsAction,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (openSettingsAction) {
                await openAppSettings();
              }
            },
            child: Text(openSettingsAction ? 'Open Settings' : 'OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visual Search')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.image_search_rounded,
                size: 88,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Search by image',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Take a photo or choose one from your gallery to find similar products.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: 'Take Photo',
                leading: _isPicking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt_outlined),
                onPressed: _isPicking
                    ? null
                    : () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _isPicking
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
