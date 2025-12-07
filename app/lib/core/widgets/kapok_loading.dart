import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';
import 'roots_loading_animation.dart';

/// Kapok-branded loading widget with roots animation
class KapokLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const KapokLoading({
    super.key,
    this.message,
    this.size = 80.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final loadingMessage = message ?? AppLocalizations.of(context).loading;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RootsLoadingAnimation(
            size: size,
            color: color ?? AppColors.primary,
          ),
          if (loadingMessage.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              loadingMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

