import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../error/exceptions.dart';
import '../utils/logger.dart';
import '../../data/models/task_model.dart';
import '../../data/models/team_model.dart';
import '../../data/models/user_model.dart';

/// Service for exporting disaster relief data to portable formats
///
/// Critical for emergency scenarios where:
/// - Infrastructure fails and cloud data is inaccessible
/// - Data needs to be shared with other relief organizations
/// - Backup is required before device loss/damage
///
/// Export formats:
/// - JSON: Machine-readable, preserves all data fidelity
/// - Human-readable structure for manual inspection if needed
class DataExportService {
  static DataExportService? _instance;
  static DataExportService get instance => _instance ??= DataExportService._();

  DataExportService._();

  /// Export tasks and teams to JSON file
  ///
  /// This operation works entirely offline using cached data.
  /// No network connectivity required.
  ///
  /// Returns the file path where data was exported.
  /// Throws DataExportException on failure.
  Future<String> exportToJson({
    required List<TaskModel> tasks,
    required List<TeamModel> teams,
    required UserModel currentUser,
  }) async {
    try {
      Logger.info('Starting data export to JSON', tag: 'EXPORT');

      // Validate input
      if (tasks.isEmpty && teams.isEmpty) {
        throw const DataExportException(
          message: 'No data to export. Please sync your tasks and teams first.',
        );
      }

      // Build export data structure
      final exportData = {
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'exportedBy': {
            'userId': currentUser.id,
            'userName': currentUser.name,
            'userEmail': currentUser.email,
          },
          'version': '1.0.0',
          'format': 'kapok-disaster-relief-export',
        },
        'summary': {
          'totalTasks': tasks.length,
          'completedTasks': tasks.where((t) => t.status.value == 'completed').length,
          'pendingTasks': tasks.where((t) => t.status.value == 'pending').length,
          'totalTeams': teams.length,
        },
        'teams': teams.map((team) => {
          'id': team.id,
          'name': team.teamName,
          'code': team.teamCode,
          'leaderName': currentUser.id == team.leaderId ? currentUser.name : 'Unknown',
          'memberCount': team.memberIds.length,
          'description': team.description,
          'isActive': team.isActive,
          'createdAt': team.createdAt.toIso8601String(),
        }).toList(),
        'tasks': tasks.map((task) => {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'priority': task.priority.value,
          'status': task.status.value,
          'assignedTo': task.assignedTo,
          'teamId': task.teamId,
          'location': {
            'latitude': task.latitude,
            'longitude': task.longitude,
            'address': task.address,
          },
          'createdAt': task.createdAt.toIso8601String(),
          'updatedAt': task.updatedAt.toIso8601String(),
          'dueDate': task.dueDate?.toIso8601String(),
          'completedAt': task.completedAt?.toIso8601String(),
        }).toList(),
      };

      // Convert to pretty JSON for human readability
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Generate filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filename = 'kapok_export_$timestamp.json';

      // Get app documents directory (works on all platforms)
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      Logger.info('Data exported successfully to: $filePath', tag: 'EXPORT');
      Logger.info('Export size: ${(jsonString.length / 1024).toStringAsFixed(2)} KB', tag: 'EXPORT');

      return filePath;
    } catch (e) {
      Logger.error('Error exporting data', tag: 'EXPORT', error: e);
      if (e is DataExportException) {
        rethrow;
      }
      throw DataExportException(
        message: 'Failed to export data: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Share exported file using native share dialog
  ///
  /// Allows user to:
  /// - Save to Files app
  /// - Share via email/messaging
  /// - Transfer to other devices
  ///
  /// Works offline - sharing mechanism is OS-level, not network-dependent.
  Future<void> shareExportedFile(String filePath) async {
    try {
      Logger.info('Sharing exported file: $filePath', tag: 'EXPORT');

      final file = File(filePath);
      if (!await file.exists()) {
        throw const DataExportException(
          message: 'Export file not found. Please export data again.',
        );
      }

      // Use share_plus to invoke native share sheet
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Kapok Disaster Relief Data Export',
        text: 'Emergency response data export from Kapok app',
      );

      Logger.info('Share result: ${result.status}', tag: 'EXPORT');
    } catch (e) {
      Logger.error('Error sharing file', tag: 'EXPORT', error: e);
      if (e is DataExportException) {
        rethrow;
      }
      throw DataExportException(
        message: 'Failed to share export file: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get list of previously exported files
  ///
  /// Returns list of export file paths, sorted by date (newest first).
  /// Useful for accessing historical exports.
  Future<List<String>> getExportHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);

      final files = await dir
          .list()
          .where((entity) =>
              entity is File &&
              entity.path.contains('kapok_export_') &&
              entity.path.endsWith('.json'))
          .map((entity) => entity.path)
          .toList();

      // Sort by filename (which includes timestamp) in reverse
      files.sort((a, b) => b.compareTo(a));

      return files;
    } catch (e) {
      Logger.error('Error getting export history', tag: 'EXPORT', error: e);
      return [];
    }
  }

  /// Delete old export files to free up space
  ///
  /// Keeps only the most recent [keepCount] exports.
  /// Useful for managing storage on resource-constrained devices.
  Future<void> cleanupOldExports({int keepCount = 5}) async {
    try {
      final files = await getExportHistory();

      if (files.length <= keepCount) {
        return; // Nothing to clean up
      }

      final filesToDelete = files.skip(keepCount);

      for (final filePath in filesToDelete) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          Logger.info('Deleted old export: $filePath', tag: 'EXPORT');
        }
      }

      Logger.info('Cleanup complete. Kept $keepCount most recent exports.', tag: 'EXPORT');
    } catch (e) {
      Logger.error('Error cleaning up exports', tag: 'EXPORT', error: e);
      // Non-critical operation, don't throw
    }
  }
}

/// Exception for data export errors
class DataExportException extends DatabaseException {
  const DataExportException({
    required super.message,
    super.originalError,
  });
}
