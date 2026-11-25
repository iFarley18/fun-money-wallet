import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kid_profile.dart';
import 'balance_repository.dart';

class LocalBalanceRepository implements BalanceRepository {
  static const String _storageKey = 'crew_stash_kid_profiles_v1';
  final SharedPreferences _prefs;
  final StreamController<List<KidProfile>> _controller = StreamController.broadcast();

  LocalBalanceRepository(this._prefs);

  Future<void> initDefaultsIfNeeded() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      final defaults = [
        const KidProfile(
          id: 'kid_leo',
          name: 'Leo',
          balanceCents: 4350,
          themeColor: Color(0xFFFF6B00),
          avatarIconName: 'rocket',
          lastUpdatedText: 'Set by Dad (Brian) on Oct 24, 4:15 PM',
        ),
        const KidProfile(
          id: 'kid_sam',
          name: 'Sam',
          balanceCents: 1825,
          themeColor: Color(0xFF00E5FF),
          avatarIconName: 'shield',
          lastUpdatedText: 'Set by Dad (Brian) on Oct 23, 2:10 PM',
        ),
      ];
      await _saveList(defaults);
    }
  }

  @override
  Future<List<KidProfile>> getKidProfiles() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => KidProfile.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> saveKidProfile(KidProfile profile) async {
    final list = await getKidProfiles();
    final index = list.indexWhere((k) => k.id == profile.id);
    if (index >= 0) {
      list[index] = profile;
    } else {
      list.add(profile);
    }
    await _saveList(list);
  }

  @override
  Future<void> updateBalance(String kidId, int cents, String sourceDescription) async {
    final list = await getKidProfiles();
    final index = list.indexWhere((k) => k.id == kidId);
    if (index >= 0) {
      list[index] = list[index].copyWith(
        balanceCents: cents,
        lastUpdatedText: sourceDescription,
      );
      await _saveList(list);
    }
  }

  @override
  Stream<List<KidProfile>> watchProfiles() {
    getKidProfiles().then((list) => _controller.add(list));
    return _controller.stream;
  }

  Future<void> _saveList(List<KidProfile> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
    _controller.add(list);
  }
}
