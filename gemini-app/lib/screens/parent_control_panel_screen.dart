import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kid_profile.dart';
import '../models/money_balance.dart';
import '../repositories/balance_repository.dart';
import '../services/pin_service.dart';

class ParentControlPanelScreen extends StatefulWidget {
  final BalanceRepository balanceRepository;
  final PinService pinService;

  const ParentControlPanelScreen({
    super.key,
    required this.balanceRepository,
    required this.pinService,
  });

  @override
  State<ParentControlPanelScreen> createState() => _ParentControlPanelScreenState();
}

class _ParentControlPanelScreenState extends State<ParentControlPanelScreen> {
  List<KidProfile> _profiles = [];
  final Map<String, TextEditingController> _controllers = {};
  final _newPinController = TextEditingController();

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
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    labelText: 'Balance (Dollars)',
                    filled: true,
                    fillColor: Color(0xFF0F172A),
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
