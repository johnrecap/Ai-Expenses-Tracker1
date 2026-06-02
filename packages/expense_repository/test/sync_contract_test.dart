import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/local/drift/drift_store.dart';
import 'package:expense_repository/src/local/drift/drift_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;

void main() {
  group('SyncCoordinator', () {
    test('push sends the VPS contract payload and removes accepted changes', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final queue = _queueFor(store);
      final api = _FakeVpsApiClient();
      final coordinator = SyncCoordinator(
        apiClient: api,
        queue: queue,
        localStore: store,
      );

      store.upsertExpense(_expense(id: 'expense-1'));
      final clientChangeId = store.pendingChanges.single.clientChangeId;
      api.pushResponse = {
        'accepted': [
          {
            'entityType': 'expense',
            'entityId': 'expense-1',
            'clientChangeId': clientChangeId,
            'serverRevision': 1,
          },
        ],
        'nextCursor': '1',
      };

      await coordinator.syncNow(deviceId: 'device-1');

      expect(store.pendingChanges, isEmpty);
      expect(api.pushedChanges, hasLength(1));
      final pushed = api.pushedChanges.single;
      expect(pushed['clientChangeId'], clientChangeId);
      expect(pushed['entityType'], 'expense');
      expect(pushed['entityId'], 'expense-1');
      expect(pushed['operation'], 'upsert');
      expect(pushed['clientUpdatedAt'], isA<String>());
      expect((pushed['data'] as Map<String, dynamic>)['date'], isA<String>());
    });

    test('pull applies remote changes locally without creating new pending work', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final api = _FakeVpsApiClient()
        ..pullResponse = {
          'changes': [
            {
              'entityType': 'expense',
              'entityId': 'remote-expense',
              'clientChangeId': 'remote-change-1',
              'operation': 'upsert',
              'clientUpdatedAt': '2026-05-31T10:00:00.000Z',
              'serverRevision': 7,
              'data': _expenseDocument(id: 'remote-expense'),
            },
          ],
          'nextCursor': '7',
          'hasMore': false,
        };
      final coordinator = SyncCoordinator(
        apiClient: api,
        queue: _queueFor(store),
        localStore: store,
      );

      await coordinator.syncNow(deviceId: 'device-1');

      expect(api.pullCursors, equals([null]));
      expect(store.expenses, hasLength(1));
      expect(store.expenses.single.expenseId, 'remote-expense');
      expect(store.expenses.single.description, 'Remote lunch');
      expect(store.pendingChanges, isEmpty);

      api.pullResponse = {
        'changes': const <Map<String, dynamic>>[],
        'nextCursor': '7',
        'hasMore': false,
      };
      await coordinator.syncNow(deviceId: 'device-1');
      expect(api.pullCursors.last, '7');
    });

    test('wallet changes use the server entity name', () {
      final store = LocalRepositoryStore(userId: 'user-1');

      store.upsertWallet(
        WalletAccount(
          walletId: 'wallet-1',
          userId: 'user-1',
          name: 'Cash',
          type: 'cash',
          balance: 100,
          currency: 'EGP',
          icon: 'wallet',
          color: 0xFF225577,
          createdAt: DateTime.utc(2026, 5, 31),
          updatedAt: DateTime.utc(2026, 5, 31),
        ),
      );

      expect(store.pendingChanges.single.entityType, 'walletAccount');
      expect(store.pendingChanges.single.toPushPayload()['operation'], 'upsert');
    });
  });

  group('Drift sync queue', () {
    test('persists pending changes and reloads them after restart', () async {
      final tempDir = Directory.systemTemp.createTempSync('sync_queue_test_');
      final queueFile = File(p.join(tempDir.path, 'pending.json'));
      final store1 = DriftLocalRepositoryStore(
        userId: 'user-1',
        database: AppDatabase(NativeDatabase.memory()),
        syncQueueFile: queueFile,
      );

      try {
        store1.upsertExpense(_expense(id: 'expense-1'));
        await _waitUntil(() => queueFile.existsSync());
        await store1.dispose();

        final raw = jsonDecode(queueFile.readAsStringSync()) as List<dynamic>;
        expect(raw, hasLength(1));
        expect((raw.single as Map<String, dynamic>)['entityId'], 'expense-1');

        final store2 = DriftLocalRepositoryStore(
          userId: 'user-1',
          database: AppDatabase(NativeDatabase.memory()),
          syncQueueFile: queueFile,
        );
        try {
          await _waitUntil(() => store2.pendingChanges.length == 1);
          expect(store2.pendingChanges.single.entityId, 'expense-1');
          expect(store2.pendingChanges.single.data['date'], isA<String>());
        } finally {
          await store2.dispose();
        }
      } finally {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('VpsApiClient', () {
    test('pull uses GET with cursor query to match server routes', () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode({
            'changes': <Map<String, dynamic>>[],
            'nextCursor': '5',
            'hasMore': false,
          }),
          200,
        );
      });
      final api = VpsApiClient(
        baseUri: Uri.parse('https://example.test'),
        tokenProvider: () async => 'token-1',
        client: client,
      );

      final response = await api.pullChanges(cursor: '4');

      expect(response['nextCursor'], '5');
      expect(requests.single.method, 'GET');
      expect(requests.single.url.toString(), 'https://example.test/v1/sync/pull?cursor=4');
      expect(requests.single.headers['Authorization'], 'Bearer token-1');
    });

    test('non-success responses throw a typed VPS exception', () async {
      final client = MockClient(
        (_) async => http.Response('server failed', 500),
      );
      final api = VpsApiClient(
        baseUri: Uri.parse('https://example.test'),
        tokenProvider: () async => null,
        client: client,
      );

      expect(
        () => api.pushChanges(deviceId: 'device-1', changes: const []),
        throwsA(isA<VpsApiException>()),
      );
    });
  });
}

LocalSyncQueue _queueFor(LocalRepositoryStore store) {
  return LocalSyncQueue(
    pending: store.pendingChanges,
    onUploaded: store.markUploadedChanges,
    onChanged: store.markSyncChangesUpdated,
  );
}

Expense _expense({required String id}) {
  final date = DateTime.utc(2026, 5, 31, 10);
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: Category(
      categoryId: 'food',
      userId: 'user-1',
      name: 'Food',
      totalExpenses: 0,
      icon: 'restaurant',
      color: 0xFF336699,
      createdAt: date,
      updatedAt: date,
    ),
    date: date,
    amount: 125.5,
    description: 'Remote lunch',
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
    createdAt: date,
    updatedAt: date,
  );
}

Map<String, dynamic> _expenseDocument({required String id}) {
  final date = DateTime.utc(2026, 5, 31, 10).toIso8601String();
  return {
    'expenseId': id,
    'userId': 'user-1',
    'categoryId': 'food',
    'categoryName': 'Food',
    'categoryIcon': 'restaurant',
    'categoryColor': 0xFF336699,
    'date': date,
    'amount': 125.5,
    'description': 'Remote lunch',
    'tags': const <String>[],
    'paymentMethod': 'cash',
    'currency': 'EGP',
    'createdAt': date,
    'updatedAt': date,
    'source': 'manual',
  };
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var i = 0; i < 30; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('Condition was not met in time.');
}

class _FakeVpsApiClient extends VpsApiClient {
  _FakeVpsApiClient()
    : super(
        baseUri: Uri.parse('https://example.test'),
        tokenProvider: () async => 'token',
      );

  List<Map<String, dynamic>> pushedChanges = const <Map<String, dynamic>>[];
  Map<String, dynamic> pushResponse = const {
    'accepted': <Map<String, dynamic>>[],
  };
  Map<String, dynamic> pullResponse = const {
    'changes': <Map<String, dynamic>>[],
    'nextCursor': '0',
    'hasMore': false,
  };
  final pullCursors = <String?>[];

  @override
  Future<Map<String, dynamic>> pushChanges({
    required String deviceId,
    required List<Map<String, dynamic>> changes,
  }) async {
    pushedChanges = changes;
    return pushResponse;
  }

  @override
  Future<Map<String, dynamic>> pullChanges({required String? cursor}) async {
    pullCursors.add(cursor);
    return pullResponse;
  }
}
