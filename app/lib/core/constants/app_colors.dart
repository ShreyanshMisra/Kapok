import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32); // Forest Green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF1976D2); // Blue
  static const Color secondaryLight = Color(0xFF42A5F5);
  static const Color secondaryDark = Color(0xFF0D47A1);
  
  // Task Severity Colors
  static const Color severity1 = Color(0xFF4CAF50); // Low - Green
  static const Color severity2 = Color(0xFF8BC34A); // Low-Medium - Light Green
  static const Color severity3 = Color(0xFFFFC107); // Medium - Amber
  static const Color severity4 = Color(0xFFFF9800); // High - Orange
  static const Color severity5 = Color(0xFFF44336); // Critical - Red
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Map Colors
  static const Color mapPin = Color(0xFF2E7D32);
  static const Color mapPinSelected = Color(0xFF1976D2);
  static const Color mapPinCompleted = Color(0xFF4CAF50);
  
  // Role Colors
  static const Color medical = Color(0xFFE91E63);
  static const Color engineering = Color(0xFF9C27B0);
  static const Color carpentry = Color(0xFF795548);
  static const Color plumbing = Color(0xFF00BCD4);
  static const Color construction = Color(0xFFFF5722);
  static const Color electrical = Color(0xFFFFC107);
  static const Color supplies = Color(0xFF607D8B);
  static const Color transportation = Color(0xFF3F51B5);
  static const Color other = Color(0xFF9E9E9E);
  
  // Account Type Colors
  static const Color admin = Color(0xFF9C27B0);
  static const Color teamLeader = Color(0xFF1976D2);
  static const Color teamMember = Color(0xFF4CAF50);
  
  // Offline/Online Status
  static const Color offline = Color(0xFFF44336);
  static const Color online = Color(0xFF4CAF50);
  static const Color syncing = Color(0xFFFF9800);
  
  // Private constructor to prevent instantiation
  AppColors._();
}

