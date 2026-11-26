import 'dart:async';
import 'package:plaid_flutter/plaid_flutter.dart';

class PlaidLinkOutcome {
  final String publicToken;
  final String? institutionName;
  final String? firstAccountId;
  const PlaidLinkOutcome(this.publicToken, this.institutionName, this.firstAccountId);
}

/// Opens Plaid Link with a link_token and resolves with the public_token,
/// or null if the parent backs out.
class PlaidLinkLauncher {
  Future<PlaidLinkOutcome?> open(String linkToken) async {
    final completer = Completer<PlaidLinkOutcome?>();
    late final StreamSubscription<LinkSuccess> s;
    late final StreamSubscription<LinkExit> e;
    s = PlaidLink.onSuccess.listen((ok) {
      if (!completer.isCompleted) {
        final accts = ok.metadata.accounts;
        completer.complete(PlaidLinkOutcome(
          ok.publicToken,
          ok.metadata.institution?.name,
          accts.isNotEmpty ? accts.first.id : null,
        ));
      }
    });
    e = PlaidLink.onExit.listen((ex) {
      if (!completer.isCompleted) {
        final err = ex.error;
        if (err != null) {
          completer.completeError(Exception(err.displayMessage ?? err.message));
        } else {
          completer.complete(null);
        }
      }
    });
    try {
      await PlaidLink.create(configuration: LinkTokenConfiguration(token: linkToken));
      await PlaidLink.open();
      return await completer.future;
    } finally {
      await s.cancel();
      await e.cancel();
    }
  }
}
