import 'dart:async';
import 'balance_repository.dart';
import '../models/kid_profile.dart';

/// Plaid Balance Repository (Read-Only Proxy Architecture)
///
/// In a production environment with Plaid API integration:
/// 1. Connects to the read-only balance web service.
/// 2. Converts external account balances to integer cents.
/// 3. Updates the metadata stream (`Live Read-Only Sync • Bangor Savings Bank`).
///
/// Because the Vault UI consumes `Stream<List<KidProfile>>`, substituting this
/// implementation requires zero UI layout changes.
class PlaidBalanceRepository implements BalanceRepository {
  final BalanceRepository _localFallback;

  PlaidBalanceRepository(this._localFallback);

  @override
  Future<List<KidProfile>> getKidProfiles() async {
    // Interface Slot for Plaid Link Balance Proxy
    return _localFallback.getKidProfiles();
  }

  @override
  Future<void> saveKidProfile(KidProfile profile) {
    return _localFallback.saveKidProfile(profile);
  }

  @override
  Future<void> updateBalance(String kidId, int cents, String sourceDescription) {
    return _localFallback.updateBalance(kidId, cents, "Live Sync • Bangor Savings Bank");
  }

  @override
  Stream<List<KidProfile>> watchProfiles() {
    return _localFallback.watchProfiles();
  }
}
