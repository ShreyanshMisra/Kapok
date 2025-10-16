import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Location picker page for selecting task locations
class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Select Location'),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Location Picker page - To be implemented with Mapbox integration'),
      ),
    );
  }
}
