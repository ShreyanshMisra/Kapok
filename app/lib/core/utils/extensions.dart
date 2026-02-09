import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String extensions for common operations
extension StringExtensions on String {
  /// Capitalizes the first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalizes the first letter of each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Removes extra whitespace and normalizes spaces
  String normalize() {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Checks if string is a valid email
  bool get isEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }

  /// Checks if string is a valid phone number
  bool get isPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Converts string to title case
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Truncates string to specified length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Removes all non-alphanumeric characters
  String alphanumericOnly() {
    return replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  /// Converts string to slug format
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }
}

/// DateTime extensions for formatting and calculations
extension DateTimeExtensions on DateTime {
  /// Formats date to readable string
  String toReadableDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Formats date and time to readable string
  String toReadableDateTime() {
    return DateFormat('MMM dd, yyyy at h:mm a').format(this);
  }

  /// Formats time to readable string
  String toReadableTime() {
    return DateFormat('h:mm a').format(this);
  }

  /// Formats date to ISO string
  String toISOString() {
    return toUtc().toIso8601String();
  }

  /// Gets relative time (e.g., "2 hours ago")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 7) {
      return toReadableDate();
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Checks if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Checks if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  /// Gets start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Gets end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}

/// List extensions for common operations
extension ListExtensions<T> on List<T> {
  /// Safely gets element at index or returns null
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Removes duplicates from list
  List<T> removeDuplicates() {
    return toSet().toList();
  }

  /// Chunks list into smaller lists of specified size
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  /// Checks if list is not empty
  bool get isNotEmpty => length > 0;

  /// Gets first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Gets last element or null
  T? get lastOrNull => isEmpty ? null : last;
}

/// Map extensions for common operations
extension MapExtensions<K, V> on Map<K, V> {
  /// Safely gets value or returns null
  V? safeGet(K key) {
    return containsKey(key) ? this[key] : null;
  }

  /// Gets value or returns default
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key]! : defaultValue;
  }

  /// Removes null values
  Map<K, V> removeNulls() {
    return Map.fromEntries(
      entries.where((entry) => entry.value != null),
    );
  }
}

/// BuildContext extensions for common operations
extension BuildContextExtensions on BuildContext {
  /// Gets theme data
  ThemeData get theme => Theme.of(this);

  /// Gets text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Gets color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Gets media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Gets screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Gets screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Gets screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Checks if device is mobile
  bool get isMobile => screenWidth < 600;

  /// Checks if device is tablet
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Checks if device is desktop
  bool get isDesktop => screenWidth >= 1200;

  /// Shows snackbar with rounded, floating style
  void showSnackBar(String message, {Color? backgroundColor, Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor ?? const Color(0xFF013576),
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shows error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shows success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Navigates to route
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// Replaces current route
  Future<T?> replaceWith<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Pops current route
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Pops until route
  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }
}

/// Double extensions for common operations
extension DoubleExtensions on double {
  /// Rounds to specified decimal places
  double roundTo(int places) {
    final factor = pow(10, places);
    return (this * factor).round() / factor;
  }

  /// Formats as currency
  String toCurrency({String symbol = '\$', int decimalPlaces = 2}) {
    return '$symbol${toStringAsFixed(decimalPlaces)}';
  }

  /// Formats as percentage
  String toPercentage({int decimalPlaces = 1}) {
    return '${(this * 100).toStringAsFixed(decimalPlaces)}%';
  }

  /// Clamps value between min and max
  double clamp(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

/// Int extensions for common operations
extension IntExtensions on int {
  /// Formats with commas
  String get withCommas {
    return NumberFormat('#,###').format(this);
  }

  /// Converts to ordinal (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Converts to duration string
  String toDurationString() {
    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;
    final seconds = this % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
