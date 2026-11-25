import 'dart:async';

import 'package:flutter/foundation.dart';

import 'sync_repository.dart';

/// Debounced / gated sync triggers (PoseCoach-style).
class SyncCoordinator {
  SyncCoordinator(this._repo);

  static const Duration debounce = Duration(milliseconds: 1500);
  static const Duration resumeStale = Duration(minutes: 15);
  static const Duration flushTimeout = Duration(seconds: 20);

  final SyncRepository _repo;

  Timer? _debounce;
  bool _paused = false;
  DateTime? _lastFullSync;

  void setActivityPaused(bool paused) {
    final bool wasPaused = _paused;
    _paused = paused;
    if (wasPaused && !paused) {
      notifyLocalChange();
    }
  }

  void notifyLocalChange() {
    if (_paused) {
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      unawaited(requestPush());
    });
  }

  Future<SyncResult> requestPush() async {
    if (_paused) {
      return const SyncResult();
    }
    return _repo.pushAll(expectedUserId: _repo.expectedUserId);
  }

  Future<SyncResult> requestFullSync({Duration? onlyIfOlderThan}) async {
    if (_paused) {
      return const SyncResult();
    }
    if (onlyIfOlderThan != null && _lastFullSync != null) {
      if (DateTime.now().difference(_lastFullSync!) < onlyIfOlderThan) {
        return const SyncResult();
      }
    }
    final SyncResult result = await _repo.syncAll(
      expectedUserId: _repo.expectedUserId,
    );
    if (result.ok) {
      _lastFullSync = DateTime.now();
    }
    return result;
  }

  Future<SyncResult> backupNow() => requestFullSync();

  Future<SyncResult> flushBeforeSignOut() async {
    try {
      return await _repo
          .pushAll(expectedUserId: _repo.expectedUserId)
          .timeout(flushTimeout);
    } on TimeoutException {
      return const SyncResult(
        ok: false,
        errorMessage: 'Backup timed out.',
      );
    } on Object catch (e) {
      debugPrint('flushBeforeSignOut: $e');
      return const SyncResult(ok: false, errorMessage: 'Backup failed.');
    }
  }

  Future<int> pendingCount() => _repo.pendingCount();

  void cancelPending() {
    _debounce?.cancel();
    _debounce = null;
  }

  void dispose() {
    cancelPending();
  }
}
