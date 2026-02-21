import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sync_service.dart';

/// Widget that shows the current sync status as a small bar
class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription<SyncState> _syncSubscription;
  SyncState _currentState = SyncState.synced;
  int _pendingCount = 0;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _syncSubscription = SyncService.instance.syncStateStream.listen((state) {
      if (mounted) {
        setState(() => _currentState = state);
        if (state == SyncState.syncing) {
          _spinController.repeat();
        } else {
          _spinController.stop();
        }
      }
    });
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    final count = await SyncService.instance.getPendingSyncCount();
    if (mounted) {
      setState(() => _pendingCount = count);
    }
  }

  @override
  void dispose() {
    _syncSubscription.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show when there's something to report
    if (_currentState == SyncState.synced && _pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String label;

    switch (_currentState) {
      case SyncState.syncing:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.sync;
        label = 'Syncing...';
      case SyncState.pending:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.cloud_queue;
        label = '$_pendingCount pending';
        _loadPendingCount();
      case SyncState.error:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cloud_off;
        label = 'Sync error';
      case SyncState.synced:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.cloud_done;
        label = 'Synced';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _currentState == SyncState.syncing
              ? RotationTransition(
                  turns: _spinController,
                  child: Icon(icon, size: 14, color: textColor),
                )
              : Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
