import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Location picker page for selecting task locations
class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: const Text('Select Location'),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Location Picker page - To be implemented with Mapbox integration'),
      ),
    );
  }
}
