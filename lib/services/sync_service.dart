import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database.dart';

final syncServiceProvider = Provider((ref) => SyncService(AppDatabase())); // You'll inject the DB properly later

class SyncService {
  final AppDatabase _db;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SyncService(this._db) {
    _listenToNetworkChanges();
  }

  void _listenToNetworkChanges() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        _processSyncQueue();
      }
    });
  }

  Future<void> addToQueue(String operation, String targetTable, String dataPayload) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      id: id,
      operation: operation,
      targetTable: targetTable,
      dataPayload: dataPayload,
    ));
    _processSyncQueue();
  }

  Future<void> _processSyncQueue() async {
    final user = _auth.currentUser;
    if (user == null) return; // Cannot sync without a logged-in user

    final pendingJobs = await _db.select(_db.syncQueue).get();

    for (var job in pendingJobs) {
      try {
        final payload = jsonDecode(job.dataPayload) as Map<String, dynamic>;
        final docId = payload['id'] as String;

        final docRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection(job.targetTable)
            .doc(docId);

        if (job.operation == 'CREATE' || job.operation == 'UPDATE') {
          await docRef.set(payload, SetOptions(merge: true));
        } else if (job.operation == 'DELETE') {
          await docRef.delete();
        }

        // Remove from local queue after successful sync
        await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(job.id))).go();
      } catch (e) {
        // Leave in queue to try again later
        print('Sync failed for job ${job.id}: $e');
      }
    }
  }
}
