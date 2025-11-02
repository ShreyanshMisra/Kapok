import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Map page showing interactive map with task markers
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Map'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show map filters
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // TODO: Navigate to tasks list view
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Map page - To be implemented with Mapbox integration'),
      ),
    );
  }
}
