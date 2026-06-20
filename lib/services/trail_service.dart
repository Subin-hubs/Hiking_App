import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/trail_model.dart';

class TrailService {
  static const String _boxName = 'trails';
  static const String _lastFetchKey = 'last_fetch';
  static const int _cacheHours = 6;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TrailModel>> getTrails({bool forceRefresh = false}) async {
    final box = Hive.box(_boxName);
    final lastFetch = box.get(_lastFetchKey) as int?;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheExpired = lastFetch == null ||
        (now - lastFetch) > (_cacheHours * 60 * 60 * 1000);

    if (!forceRefresh && !cacheExpired && box.length > 1) {
      return _getFromHive(box);
    }

    try {
      final trails = await _fetchFromFirestore();
      await _saveToHive(box, trails);
      return trails;
    } catch (e) {
      if (box.length > 1) {
        return _getFromHive(box);
      }
      rethrow;
    }
  }

  Future<List<TrailModel>> _fetchFromFirestore() async {
    final snapshot = await _firestore.collection('trails').get();
    return snapshot.docs
        .map((doc) => TrailModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  List<TrailModel> _getFromHive(Box box) {
    return box.keys
        .where((k) => k != _lastFetchKey)
        .map((k) => box.get(k) as TrailModel)
        .toList();
  }

  Future<void> _saveToHive(Box box, List<TrailModel> trails) async {
    await box.clear();
    for (final trail in trails) {
      await box.put(trail.id, trail);
    }
    await box.put(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearCache() async {
    final box = Hive.box(_boxName);
    await box.clear();
  }
}