import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  static const String _pinHashKey = 'crew_stash_parent_pin_hash';
  static const String _securityQuestionKey = 'crew_stash_security_q';
  static const String _securityAnswerHashKey = 'crew_stash_security_a_hash';
  static const String _salt = 'CrewStashVault2025Salt';

  final SharedPreferences _prefs;

  PinService(this._prefs);

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin + _salt);
    return sha256.convert(bytes).toString();
  }

  Future<bool> isPinSet() async {
    final hash = _prefs.getString(_pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = _prefs.getString(_pinHashKey);
    if (storedHash == null) {
      // Default PIN is 1234 if not explicitly set
      return pin == '1234';
    }
    return storedHash == _hashPin(pin);
  }

  Future<void> setPin(String pin) async {
    await _prefs.setString(_pinHashKey, _hashPin(pin));
  }

  Future<void> setSecurityRecovery(String question, String answer) async {
    await _prefs.setString(_securityQuestionKey, question);
    await _prefs.setString(_securityAnswerHashKey, _hashPin(answer.trim().toLowerCase()));
  }

  String? getSecurityQuestion() {
    return _prefs.getString(_securityQuestionKey) ?? "What is Mom's favorite city?";
  }

  Future<bool> verifySecurityAnswer(String answer) async {
    final storedHash = _prefs.getString(_securityAnswerHashKey);
    if (storedHash == null) return answer.trim().toLowerCase() == 'bangor';
    return storedHash == _hashPin(answer.trim().toLowerCase());
  }
}
