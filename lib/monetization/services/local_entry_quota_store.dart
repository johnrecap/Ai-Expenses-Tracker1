import 'dart:convert';
import 'dart:io';

import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:path_provider/path_provider.dart';

class EntryQuotaStoreException implements Exception {
  const EntryQuotaStoreException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    final cause = this.cause;
    if (cause == null) {
      return message;
    }
    return '$message: $cause';
  }
}

class LocalEntryQuotaStore {
  factory LocalEntryQuotaStore({
    File? file,
    Directory? directory,
    String fileName = 'entry_quota.json',
  }) {
    return LocalEntryQuotaStore._(file, directory, fileName);
  }

  const LocalEntryQuotaStore._(this._file, this._directory, this._fileName);

  final File? _file;
  final Directory? _directory;
  final String _fileName;

  Future<EntryQuotaSnapshot> loadSnapshot({
    required String scopeId,
    required DateTime now,
    bool isPremium = false,
  }) async {
    final data = await _readData();
    final scope = _scopeData(data, scopeId);
    final currentDate = entryQuotaDateKey(now);
    final storedSnapshot = _snapshotFromScope(scope);

    if (storedSnapshot == null || storedSnapshot.quotaDate != currentDate) {
      final snapshot = EntryQuotaSnapshot.fresh(
        scopeId: scopeId,
        now: now,
        isPremium: isPremium,
      );
      _replaceScopeForNewDay(data, scopeId, snapshot);
      await _writeData(data);
      return snapshot;
    }

    final snapshot = storedSnapshot.copyWith(isPremium: isPremium);
    scope['snapshot'] = snapshot.toJson();
    await _writeData(data);
    return snapshot;
  }

  Future<EntryQuotaMutationResult> consume({
    required String scopeId,
    required EntryQuotaKind kind,
    required String operationId,
    required DateTime now,
    String? expenseId,
  }) async {
    final data = await _readData();
    final snapshot = await _ensureTodaySnapshot(data: data, scopeId: scopeId, now: now);
    final scope = _scopeData(data, scopeId);
    final consumptions = _consumptionsFromScope(scope);

    final isDuplicate = consumptions.any(
      (consumption) =>
          consumption.operationId == operationId && consumption.quotaDate == snapshot.quotaDate,
    );
    if (isDuplicate) {
      return EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.duplicate,
        snapshot: snapshot,
        message: 'This save operation already consumed quota.',
      );
    }

    if (!snapshot.hasRemainingFor(kind)) {
      return EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.blocked,
        snapshot: snapshot,
        message: 'Daily entry quota is exhausted.',
      );
    }

    final updatedSnapshot = _incrementConsumed(snapshot, kind);
    consumptions.add(
      EntryQuotaConsumption(
        operationId: operationId,
        scopeId: scopeId,
        quotaDate: snapshot.quotaDate,
        kind: kind,
        expenseId: expenseId,
        createdAt: now,
      ),
    );

    scope['snapshot'] = updatedSnapshot.toJson();
    scope['consumptions'] = consumptions.map((consumption) => consumption.toJson()).toList();
    await _writeData(data);

    return EntryQuotaMutationResult(
      status: EntryQuotaMutationStatus.consumed,
      snapshot: updatedSnapshot,
      message: 'Entry quota consumed.',
    );
  }

  Future<EntryQuotaMutationResult> grantReward({
    required String scopeId,
    required EntryQuotaRewardPlacement placement,
    required String rewardEventId,
    required DateTime now,
    int? amount,
  }) async {
    final data = await _readData();
    final snapshot = await _ensureTodaySnapshot(data: data, scopeId: scopeId, now: now);
    final scope = _scopeData(data, scopeId);
    final rewards = _rewardsFromScope(scope);

    final isDuplicate = rewards.any(
      (reward) => reward.rewardEventId == rewardEventId && reward.quotaDate == snapshot.quotaDate,
    );
    if (isDuplicate) {
      return EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.duplicate,
        snapshot: snapshot,
        message: 'This reward event was already granted.',
      );
    }

    final grantAmount = amount ?? _defaultRewardAmount(placement);
    final updatedSnapshot = _addReward(snapshot, placement, grantAmount);
    rewards.add(
      EntryQuotaRewardGrant(
        rewardEventId: rewardEventId,
        scopeId: scopeId,
        quotaDate: snapshot.quotaDate,
        placement: placement,
        amount: grantAmount,
        createdAt: now,
        grantedAt: now,
      ),
    );

    scope['snapshot'] = updatedSnapshot.toJson();
    scope['rewards'] = rewards.map((reward) => reward.toJson()).toList();
    await _writeData(data);

    return EntryQuotaMutationResult(
      status: EntryQuotaMutationStatus.granted,
      snapshot: updatedSnapshot,
      message: 'Rewarded entry credits granted.',
    );
  }

  Future<EntryQuotaSnapshot> _ensureTodaySnapshot({
    required Map<String, Object?> data,
    required String scopeId,
    required DateTime now,
  }) async {
    final scope = _scopeData(data, scopeId);
    final currentDate = entryQuotaDateKey(now);
    final storedSnapshot = _snapshotFromScope(scope);
    if (storedSnapshot == null || storedSnapshot.quotaDate != currentDate) {
      final snapshot = EntryQuotaSnapshot.fresh(scopeId: scopeId, now: now);
      _replaceScopeForNewDay(data, scopeId, snapshot);
      return snapshot;
    }
    return storedSnapshot;
  }

  Future<Map<String, Object?>> _readData() async {
    final file = await _resolveFile();
    if (!await file.exists()) {
      return _emptyData();
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Quota store root must be a JSON object.');
      }
      return decoded;
    } catch (error) {
      throw EntryQuotaStoreException('Could not load local entry quota store', error);
    }
  }

  Future<void> _writeData(Map<String, Object?> data) async {
    final file = await _resolveFile();
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (error) {
      throw EntryQuotaStoreException('Could not save local entry quota store', error);
    }
  }

  Future<File> _resolveFile() async {
    final file = _file;
    if (file != null) {
      return file;
    }

    final directory = _directory ?? await getApplicationSupportDirectory();
    return File(directory.uri.resolve(_fileName).toFilePath());
  }

  Map<String, Object?> _emptyData() => <String, Object?>{
    'version': 1,
    'scopes': <String, Object?>{},
  };

  Map<String, Object?> _scopeData(Map<String, Object?> data, String scopeId) {
    final scopes = _scopesData(data);
    final existing = scopes[scopeId];
    if (existing is Map<String, Object?>) {
      return existing;
    }

    final created = <String, Object?>{};
    scopes[scopeId] = created;
    return created;
  }

  Map<String, Object?> _scopesData(Map<String, Object?> data) {
    final scopes = data['scopes'];
    if (scopes is Map<String, Object?>) {
      return scopes;
    }

    final created = <String, Object?>{};
    data['scopes'] = created;
    return created;
  }

  EntryQuotaSnapshot? _snapshotFromScope(Map<String, Object?> scope) {
    final snapshot = scope['snapshot'];
    if (snapshot is Map<String, Object?>) {
      return EntryQuotaSnapshot.fromJson(snapshot);
    }
    return null;
  }

  List<EntryQuotaConsumption> _consumptionsFromScope(Map<String, Object?> scope) {
    final consumptions = scope['consumptions'];
    if (consumptions is! List<Object?>) {
      return <EntryQuotaConsumption>[];
    }
    return consumptions
        .whereType<Map<String, Object?>>()
        .map(EntryQuotaConsumption.fromJson)
        .toList();
  }

  List<EntryQuotaRewardGrant> _rewardsFromScope(Map<String, Object?> scope) {
    final rewards = scope['rewards'];
    if (rewards is! List<Object?>) {
      return <EntryQuotaRewardGrant>[];
    }
    return rewards.whereType<Map<String, Object?>>().map(EntryQuotaRewardGrant.fromJson).toList();
  }

  void _replaceScopeForNewDay(
    Map<String, Object?> data,
    String scopeId,
    EntryQuotaSnapshot snapshot,
  ) {
    final scopes = _scopesData(data);
    scopes[scopeId] = <String, Object?>{
      'snapshot': snapshot.toJson(),
      'consumptions': <Object?>[],
      'rewards': <Object?>[],
    };
  }

  EntryQuotaSnapshot _incrementConsumed(EntryQuotaSnapshot snapshot, EntryQuotaKind kind) {
    switch (kind) {
      case EntryQuotaKind.normal:
        return snapshot.copyWith(normalConsumed: snapshot.normalConsumed + 1);
      case EntryQuotaKind.ai:
        return snapshot.copyWith(aiConsumed: snapshot.aiConsumed + 1);
    }
  }

  EntryQuotaSnapshot _addReward(
    EntryQuotaSnapshot snapshot,
    EntryQuotaRewardPlacement placement,
    int amount,
  ) {
    switch (placement) {
      case EntryQuotaRewardPlacement.rewardedNormalEntries:
        return snapshot.copyWith(
          normalRewardedRemaining: snapshot.normalRewardedRemaining + amount,
        );
      case EntryQuotaRewardPlacement.rewardedAiEntries:
        return snapshot.copyWith(aiRewardedRemaining: snapshot.aiRewardedRemaining + amount);
    }
  }

  int _defaultRewardAmount(EntryQuotaRewardPlacement placement) {
    switch (placement) {
      case EntryQuotaRewardPlacement.rewardedNormalEntries:
        return EntryQuotaDefaults.rewardedNormalGrant;
      case EntryQuotaRewardPlacement.rewardedAiEntries:
        return EntryQuotaDefaults.rewardedAiGrant;
    }
  }
}
