import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// About page with information about Kapok and NCTDR
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('About'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/kapok_icon.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kapok',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Disaster Relief Coordination App',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Mission section
            _buildSection(
              context,
              'Our Mission',
              'Kapok is designed to help coordinate volunteers for disaster relief efforts. The app enables teams to work together efficiently during crisis situations by providing real-time task management, team coordination, and location-based services.',
              Icons.flag,
            ),
            const SizedBox(height: 24),
            
            // NCTDR section
            _buildSection(
              context,
              'A Fair Resolution, LLC',
              'A Fair Resolution, LLC is an organization that supports developing technology for conflict management. It works to create innovative solutions that help communities resolve disputes and coordinate resources during challenging times.',
              Icons.business,
            ),
            const SizedBox(height: 24),
            
            // Features section
            _buildSection(
              context,
              'Key Features',
              '• Real-time task management and assignment\n'
              '• Team creation and member coordination\n'
              '• Location-based task mapping\n'
              '• Offline-first functionality for remote areas\n'
              '• Multi-language support (English & Spanish)\n'
              '• Role-based access control\n'
              '• Secure authentication and data protection',
              Icons.star,
            ),
            const SizedBox(height: 24),
            
            // Technology section
            _buildSection(
              context,
              'Technology',
              'Kapok is built using modern mobile technologies including Flutter for cross-platform development, Firebase for backend services, and Mapbox for location services. The app is designed to work reliably even in areas with limited internet connectivity.',
              Icons.phone_android,
            ),
            const SizedBox(height: 24),
            
            // Contact section
            _buildSection(
              context,
              'Contact & Support',
              'For technical support, feature requests, or general inquiries, please contact A Fair Resolution, LLC.',
              Icons.contact_support,
            ),
            const SizedBox(height: 32),
            
            // Version info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Built with ❤️ for disaster relief coordination',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Legal section
            _buildSection(
              context,
              'Legal',
              'This application is developed for the organization A Fair Resolution, LLC. All rights reserved. The app is designed to assist in disaster relief coordination and should be used responsibly.',
              Icons.gavel,
            ),
          ],
        ),
      ),
    );
  }

  /// Build a section with icon, title, and content
  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
