import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/visual_search_repository.dart';
import '../../core/app/app_theme.dart';
import 'visual_search_results_screen.dart';

class VisualSearchLoadingScreen extends StatefulWidget {
  final File imageFile;

  const VisualSearchLoadingScreen({super.key, required this.imageFile});

  @override
  State<VisualSearchLoadingScreen> createState() =>
      _VisualSearchLoadingScreenState();
}

class _VisualSearchLoadingScreenState extends State<VisualSearchLoadingScreen> {
  late final VisualSearchRepository _visualSearchRepository;

  @override
  void initState() {
    super.initState();
    _visualSearchRepository = Get.find<VisualSearchRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSearch();
    });
  }

  Future<void> _runSearch() async {
    try {
      final products = await _visualSearchRepository.searchByImage(
        widget.imageFile,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VisualSearchResultsScreen(
            imageFile: widget.imageFile,
            products: products,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visual Search')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Finding similar products...',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We are analyzing your image and matching it against the catalog.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
