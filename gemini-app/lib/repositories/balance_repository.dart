import '../models/kid_profile.dart';

abstract class BalanceRepository {
  Future<List<KidProfile>> getKidProfiles();
  Future<void> saveKidProfile(KidProfile profile);
  Future<void> updateBalance(String kidId, int cents, String sourceDescription);
  Stream<List<KidProfile>> watchProfiles();
}
