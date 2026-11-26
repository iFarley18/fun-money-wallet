import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kid_profile.dart';

/// Backend config is baked in at build time:
///   flutter build apk --dart-define=CREW_SYNC_URL=https://... --dart-define=CREW_SYNC_KEY=...
/// No Plaid secret or access token is ever in the app.
class CrewSyncConfig {
  static const String baseUrl = String.fromEnvironment('CREW_SYNC_URL');
  static const String appKey = String.fromEnvironment('CREW_SYNC_KEY');
  static bool get isConfigured => baseUrl.isNotEmpty && appKey.isNotEmpty;
}

class CrewAccount {
  final String accountId;
  final String name;
  final String? mask;
  final String? subtype;
  final double? current;
  final double? available;

  const CrewAccount({required this.accountId, required this.name, this.mask, this.subtype, this.current, this.available});

  factory CrewAccount.fromJson(Map<String, dynamic> j) => CrewAccount(
    accountId: j['account_id'] as String,
    name: (j['name'] as String?) ?? 'Account',
    mask: j['mask'] as String?,
    subtype: j['subtype'] as String?,
    current: (j['current'] as num?)?.toDouble(),
    available: (j['available'] as num?)?.toDouble(),
  );

  String get label => mask == null ? name : '$name ••$mask';

  /// The kid's total = the account's current balance (Plaid gives account
  /// totals, not Crew pockets). Falls back to available; never negative.
  int get balanceCents {
    final v = current ?? available ?? 0;
    final cents = (v * 100).round();
    return cents < 0 ? 0 : cents;
  }
}

class CrewSyncResult {
  final String itemId;
  final String? institution;
  final String? selectedAccountId;
  final List<CrewAccount> accounts;
  final DateTime fetchedAt;

  const CrewSyncResult({required this.itemId, this.institution, this.selectedAccountId, required this.accounts, required this.fetchedAt});

  CrewAccount? get selected {
    for (final a in accounts) {
      if (a.accountId == selectedAccountId) return a;
    }
    return null;
  }

  factory CrewSyncResult.fromJson(Map<String, dynamic> j) => CrewSyncResult(
    itemId: j['item_id'] as String,
    institution: j['institution'] as String?,
    selectedAccountId: j['selected_account_id'] as String?,
    accounts: ((j['accounts'] as List?) ?? const []).map((e) => CrewAccount.fromJson(Map<String, dynamic>.from(e))).toList(),
    fetchedAt: DateTime.tryParse((j['fetched_at'] as String?) ?? '')?.toLocal() ?? DateTime.now(),
  );

  /// Applies this result to a kid: sets the total, label and last-synced time.
  KidProfile applyTo(KidProfile p) {
    final acct = selected;
    if (acct == null) return p;
    return p.copyWith(
      balanceCents: acct.balanceCents,
      crewItemId: itemId,
      crewAccountId: acct.accountId,
      crewAccountLabel: acct.label,
      lastSyncedAt: fetchedAt,
      lastUpdatedText: 'Crew sync • ${acct.label} • ${formatSyncTime(fetchedAt)}',
    );
  }
}

class LinkedLogin {
  final String itemId;
  final String? institution;
  const LinkedLogin(this.itemId, this.institution);
}

class CrewSyncException implements Exception {
  final String message;
  final int? status;
  CrewSyncException(this.message, [this.status]);
  @override
  String toString() => message;
}

String formatSyncTime(DateTime t) {
  final l = t.toLocal();
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final m = l.minute.toString().padLeft(2, '0');
  return '${months[l.month - 1]} ${l.day}, $h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
}

class CrewSyncService {
  final String baseUrl;
  final String appKey;
  final http.Client _client;

  CrewSyncService({String? baseUrl, String? appKey, http.Client? client})
      : baseUrl = (baseUrl ?? CrewSyncConfig.baseUrl).replaceAll(RegExp(r'/+$'), ''),
        appKey = appKey ?? CrewSyncConfig.appKey,
        _client = client ?? http.Client();

  bool get isConfigured => baseUrl.isNotEmpty && appKey.isNotEmpty;

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    if (!isConfigured) throw CrewSyncException('Crew sync server is not set up in this build.');
    http.Response r;
    try {
      r = await _client
          .post(Uri.parse('$baseUrl$path'),
              headers: {'content-type': 'application/json', 'x-crew-stash-key': appKey},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw CrewSyncException("Couldn't reach the Crew sync server. Check the internet and try again.");
    }
    Map<String, dynamic> j;
    try {
      j = Map<String, dynamic>.from(jsonDecode(r.body) as Map);
    } catch (_) {
      throw CrewSyncException('Crew sync server sent an unexpected reply (${r.statusCode}).', r.statusCode);
    }
    if (r.statusCode >= 400) {
      final code = j['error']?.toString() ?? 'error';
      if (code == 'ITEM_LOGIN_REQUIRED') {
        throw CrewSyncException('Crew needs you to sign in again. Tap "Link Crew account" to reconnect.', r.statusCode);
      }
      throw CrewSyncException((j['message'] ?? code).toString(), r.statusCode);
    }
    return j;
  }

  Future<String> createLinkToken(String kidId) async =>
      (await _post('/link-token', {'kidId': kidId}))['link_token'] as String;

  Future<CrewSyncResult> exchange(String kidId, String publicToken, {String? institutionName, String? accountId}) async =>
      CrewSyncResult.fromJson(await _post('/exchange', {
        'kidId': kidId,
        'public_token': publicToken,
        if (institutionName != null) 'institution_name': institutionName,
        if (accountId != null) 'account_id': accountId,
      }));

  Future<List<LinkedLogin>> linkedLogins() async {
    final j = await _post('/items', {});
    return ((j['items'] as List?) ?? const [])
        .map((e) => LinkedLogin(e['item_id'] as String, e['institution'] as String?))
        .toList();
  }

  Future<CrewSyncResult> assign(String kidId, {String? itemId, String? accountId}) async =>
      CrewSyncResult.fromJson(await _post('/assign', {
        'kidId': kidId,
        if (itemId != null) 'item_id': itemId,
        if (accountId != null) 'account_id': accountId,
      }));

  Future<CrewSyncResult> balance(String kidId) async =>
      CrewSyncResult.fromJson(await _post('/balance', {'kidId': kidId}));

  Future<void> unlink(String kidId) async => _post('/unlink', {'kidId': kidId});
}
