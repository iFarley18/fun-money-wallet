import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gemini_fun_money/models/kid_profile.dart';
import 'package:gemini_fun_money/services/crew_sync_service.dart';

const kid = KidProfile(
  id: 'kid_everest', name: 'Everest', balanceCents: 4350, themeColor: Color(0xFFFF6B00),
  avatarIconName: 'mountain', lastUpdatedText: 'Set by Dad (Brian)', moneyThemeId: 'everest_mountain_sports',
);

Map<String, dynamic> resp({String selected = 'acc2'}) => {
  'item_id': 'item1',
  'institution': 'First Platypus Bank',
  'selected_account_id': selected,
  'fetched_at': '2026-11-26T01:02:00.000Z',
  'accounts': [
    {'account_id': 'acc1', 'name': 'Plaid Checking', 'mask': '0000', 'current': 110, 'available': 100},
    {'account_id': 'acc2', 'name': 'Plaid Saving', 'mask': '1111', 'current': 210.57, 'available': 200},
  ],
};

void main() {
  test('KidProfile JSON round-trips Crew fields and stays compatible with v4 data', () {
    final linked = kid.copyWith(crewItemId: 'item1', crewAccountId: 'acc2', crewAccountLabel: 'Plaid Saving ••1111', lastSyncedAt: DateTime.utc(2026, 11, 26, 1, 2));
    final back = KidProfile.fromJson(jsonDecode(jsonEncode(linked.toJson())));
    expect(back.isCrewLinked, isTrue);
    expect(back.crewAccountLabel, 'Plaid Saving ••1111');
    expect(back.lastSyncedAt, DateTime.utc(2026, 11, 26, 1, 2));
    final v4 = KidProfile.fromJson(jsonDecode(jsonEncode(kid.toJson())));
    expect(v4.isCrewLinked, isFalse);
    expect(linked.copyWith(clearCrew: true).isCrewLinked, isFalse);
  });

  test('sync result sets the kid total from the chosen account (current balance)', () {
    final r = CrewSyncResult.fromJson(resp());
    final updated = r.applyTo(kid);
    expect(updated.balanceCents, 21057);
    expect(updated.crewAccountId, 'acc2');
    expect(updated.lastUpdatedText, startsWith('Crew sync • Plaid Saving ••1111'));
    expect(updated.moneyThemeId, 'everest_mountain_sports');
  });

  test('balance cents: falls back to available, never negative', () {
    expect(CrewAccount.fromJson({'account_id': 'a', 'name': 'x', 'current': null, 'available': 5.5}).balanceCents, 550);
    expect(CrewAccount.fromJson({'account_id': 'a', 'name': 'x', 'current': -3.2}).balanceCents, 0);
    expect(CrewAccount.fromJson({'account_id': 'a', 'name': 'x', 'current': 0.1 + 0.2}).balanceCents, 30);
  });

  test('service sends app key, parses balance, surfaces errors', () async {
    late http.Request seen;
    final svc = CrewSyncService(baseUrl: 'http://x/', appKey: 'k', client: MockClient((req) async {
      seen = req;
      if (req.url.path == '/balance') return http.Response(jsonEncode(resp()), 200);
      return http.Response(jsonEncode({'error': 'ITEM_LOGIN_REQUIRED'}), 502);
    }));
    final r = await svc.balance('kid_everest');
    expect(seen.headers['x-crew-stash-key'], 'k');
    expect(jsonDecode(seen.body)['kidId'], 'kid_everest');
    expect(r.selected!.label, 'Plaid Saving ••1111');
    expect(() => svc.assign('kid_everest'), throwsA(isA<CrewSyncException>()));
  });

  test('unconfigured build refuses politely', () async {
    final svc = CrewSyncService(baseUrl: '', appKey: '');
    expect(svc.isConfigured, isFalse);
    expect(() => svc.balance('kid_everest'), throwsA(isA<CrewSyncException>()));
  });
}
