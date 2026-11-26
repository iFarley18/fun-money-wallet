import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kid_profile.dart';
import '../models/money_balance.dart';
import '../repositories/balance_repository.dart';
import '../services/pin_service.dart';
import '../services/crew_sync_service.dart';
import '../services/plaid_link_launcher.dart';

class ParentControlPanelScreen extends StatefulWidget {
  final BalanceRepository balanceRepository;
  final PinService pinService;
  final CrewSyncService? crewSync;
  final PlaidLinkLauncher? linkLauncher;

  const ParentControlPanelScreen({
    super.key,
    required this.balanceRepository,
    required this.pinService,
    this.crewSync,
    this.linkLauncher,
  });

  @override
  State<ParentControlPanelScreen> createState() => _ParentControlPanelScreenState();
}

class _ParentControlPanelScreenState extends State<ParentControlPanelScreen> {
  List<KidProfile> _profiles = [];
  final Map<String, TextEditingController> _controllers = {};
  final _newPinController = TextEditingController();
  late final CrewSyncService _crew = widget.crewSync ?? CrewSyncService();
  late final PlaidLinkLauncher _link = widget.linkLauncher ?? PlaidLinkLauncher();
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final list = await widget.balanceRepository.getKidProfiles();
    setState(() {
      _profiles = list;
      for (var p in list) {
        _controllers[p.id] = TextEditingController(
          text: (p.balanceCents / 100.0).toStringAsFixed(2),
        );
      }
    });
  }

  Future<void> _saveBalance(KidProfile p) async {
    final text = _controllers[p.id]?.text ?? '0';
    final cents = MoneyBalance.parseDollarsToCents(text);
    await widget.balanceRepository.updateBalance(
      p.id,
      cents,
      'Set by Parent on ${DateTime.now().month}/${DateTime.now().day}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated ${p.name}\'s balance to ${MoneyBalance(cents).toFormattedString()}')),
    );
    _loadProfiles();
  }


  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _withBusy(KidProfile p, Future<void> Function() fn) async {
    if (_busy.contains(p.id)) return;
    setState(() => _busy.add(p.id));
    try {
      await fn();
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy.remove(p.id));
    }
  }

  Future<void> _applyResult(KidProfile p, CrewSyncResult r, {bool announce = true}) async {
    final fresh = (await widget.balanceRepository.getKidProfiles()).firstWhere((k) => k.id == p.id, orElse: () => p);
    final updated = r.applyTo(fresh);
    await widget.balanceRepository.saveKidProfile(updated);
    await _loadProfiles();
    if (announce) {
      _toast('${p.name} synced from Crew: ${MoneyBalance(updated.balanceCents).toFormattedString()}');
    }
  }

  /// Link Crew: new Plaid Link login, or reuse a login another kid already linked.
  Future<void> _linkCrew(KidProfile p) => _withBusy(p, () async {
    final logins = await _crew.linkedLogins();
    String? reuseItemId;
    if (logins.isNotEmpty && mounted) {
      reuseItemId = await showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text('Link ${p.name} to Crew'),
          children: [
            ...logins.map((l) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, l.itemId),
                  child: Text('Use my linked ${l.institution ?? 'Crew'} login'),
                )),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, ''),
              child: const Text('Sign in to a new Crew login'),
            ),
          ],
        ),
      );
      if (reuseItemId == null) return; // cancelled
    }
    CrewSyncResult result;
    if (reuseItemId != null && reuseItemId.isNotEmpty) {
      result = await _crew.assign(p.id, itemId: reuseItemId);
    } else {
      final token = await _crew.createLinkToken(p.id);
      final outcome = await _link.open(token);
      if (outcome == null) return; // parent backed out of Plaid Link
      result = await _crew.exchange(p.id, outcome.publicToken,
          institutionName: outcome.institutionName, accountId: outcome.firstAccountId);
    }
    if (result.accounts.length > 1) {
      final chosen = await _pickAccount(p, result);
      if (chosen != null && chosen != result.selectedAccountId) {
        result = await _crew.assign(p.id, itemId: result.itemId, accountId: chosen);
      }
    }
    await _applyResult(p, result);
  });

  Future<void> _changeAccount(KidProfile p) => _withBusy(p, () async {
    final current = await _crew.balance(p.id);
    final chosen = await _pickAccount(p, current);
    if (chosen == null) return;
    await _applyResult(p, await _crew.assign(p.id, itemId: current.itemId, accountId: chosen));
  });

  Future<void> _syncNow(KidProfile p) => _withBusy(p, () async {
    final r = await _crew.balance(p.id);
    if (r.selected == null) {
      _toast("That Crew account isn't available anymore. Pick another.");
      return;
    }
    await _applyResult(p, r);
  });

  Future<void> _unlinkCrew(KidProfile p) => _withBusy(p, () async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unlink ${p.name} from Crew?'),
        content: const Text('The balance stays where it is and you can type it in by hand again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unlink')),
        ],
      ),
    );
    if (ok != true) return;
    await _crew.unlink(p.id);
    final fresh = (await widget.balanceRepository.getKidProfiles()).firstWhere((k) => k.id == p.id, orElse: () => p);
    await widget.balanceRepository.saveKidProfile(fresh.copyWith(clearCrew: true));
    await _loadProfiles();
    _toast('${p.name} unlinked from Crew');
  });

  Future<String?> _pickAccount(KidProfile p, CrewSyncResult r) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text("Which account is ${p.name}'s?"),
        children: r.accounts
            .map((a) => SimpleDialogOption(
                  key: Key('pick_${a.accountId}'),
                  onPressed: () => Navigator.pop(ctx, a.accountId),
                  child: Row(
                    children: [
                      Icon(a.accountId == r.selectedAccountId ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(a.label)),
                      Text(MoneyBalance(a.balanceCents).toFormattedString()),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCrewSection(KidProfile p) {
    final busy = _busy.contains(p.id);
    final small = GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70);
    final btnStyle = OutlinedButton.styleFrom(
      foregroundColor: p.themeColor,
      side: BorderSide(color: p.themeColor.withOpacity(0.6)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      visualDensity: VisualDensity.compact,
    );
    if (!_crew.isConfigured) {
      return Text('Crew sync: not set up in this build (manual entry only).', style: small);
    }
    if (!p.isCrewLinked) {
      return Row(
        children: [
          OutlinedButton.icon(
            key: Key('link_${p.id}'),
            style: btnStyle,
            onPressed: busy ? null : () => _linkCrew(p),
            icon: const Icon(Icons.link, size: 16),
            label: const Text('Link Crew account'),
          ),
          if (busy) const Padding(padding: EdgeInsets.only(left: 10), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Crew: ${p.crewAccountLabel ?? 'linked'}', style: GoogleFonts.fredoka(fontSize: 13, color: Colors.white)),
        Text(
          p.lastSyncedAt == null ? 'Not synced yet' : 'Last synced ${formatSyncTime(p.lastSyncedAt!)}',
          style: small,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              key: Key('sync_${p.id}'),
              style: ElevatedButton.styleFrom(backgroundColor: p.themeColor, foregroundColor: Colors.black, visualDensity: VisualDensity.compact),
              onPressed: busy ? null : () => _syncNow(p),
              icon: const Icon(Icons.sync, size: 16),
              label: const Text('Sync now'),
            ),
            OutlinedButton(style: btnStyle, onPressed: busy ? null : () => _changeAccount(p), child: const Text('Change account')),
            OutlinedButton(style: btnStyle, onPressed: busy ? null : () => _unlinkCrew(p), child: const Text('Unlink')),
            if (busy) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ],
    );
  }

  Future<void> _changePin() async {
    if (_newPinController.text.length == 4) {
      await widget.pinService.setPin(_newPinController.text);
      _newPinController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent PIN successfully updated!'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Parent Control Center', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Manage Kid Balances (Stored as Integer Cents)',
            style: GoogleFonts.fredoka(fontSize: 16, color: const Color(0xFF00E5FF)),
          ),
          const SizedBox(height: 12),
          ..._profiles.map((p) => _buildKidEditorCard(p)),
          const SizedBox(height: 24),
          Text(
            'Security & PIN Settings',
            style: GoogleFonts.fredoka(fontSize: 16, color: const Color(0xFF00E5FF)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Change 4-Digit Parent PIN', style: GoogleFonts.fredoka(color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newPinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'New 4-digit PIN',
                          filled: true,
                          fillColor: Color(0xFF0F172A),
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _changePin,
                      child: Text('Save PIN', style: GoogleFonts.fredoka()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKidEditorCard(KidProfile p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.themeColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: p.themeColor, radius: 14),
              const SizedBox(width: 10),
              Text(p.name, style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllers[p.id],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    labelText: p.isCrewLinked ? 'Manual override (next sync replaces it)' : 'Balance (Dollars)',
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.themeColor,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => _saveBalance(p),
                child: Text('Update', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildCrewSection(p),
          const SizedBox(height: 6),
          Text(
            'Provenance: ${p.lastUpdatedText}',
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
