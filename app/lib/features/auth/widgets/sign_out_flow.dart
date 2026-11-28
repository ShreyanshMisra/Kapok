import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/sync_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Confirms and performs sign-out.
///
/// Signing out clears this account's local data, including changes made
/// offline that haven't been uploaded. So first try to sync them if online;
/// if any remain, warn that they'll be discarded and let the user cancel.
///
/// [onConfirmed] runs after the user confirms, just before sign-out.
/// Returns whether sign-out was requested.
Future<bool> confirmAndSignOut(
  BuildContext context, {
  VoidCallback? onConfirmed,
}) async {
  final localizations = AppLocalizations.of(context);
  final sync = SyncService.instance;

  var pending = await sync.getPendingSyncCount();
  if (pending > 0) {
    final connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.none)) {
      // Firestore writes can wait indefinitely on a captive or flaky network;
      // don't hold the dialog hostage.
      await sync
          .syncPendingChanges()
          .timeout(const Duration(seconds: 10), onTimeout: () {});
      pending = await sync.getPendingSyncCount();
    }
  }

  if (!context.mounted) return false;
  final hasUnsynced = pending > 0;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        hasUnsynced
            ? localizations.unsyncedChangesTitle
            : localizations.signOut,
      ),
      content: Text(
        hasUnsynced
            ? localizations.unsyncedChangesMessage(pending)
            : localizations.confirmSignOut,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasUnsynced ? AppColors.error : Theme.of(context).colorScheme.primary,
            foregroundColor: hasUnsynced ? Colors.white : Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(
            hasUnsynced
                ? localizations.signOutAnyway
                : localizations.signOut.toUpperCase(),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return false;
  onConfirmed?.call();
  context.read<AuthBloc>().add(const SignOutRequested());
  return true;
}
