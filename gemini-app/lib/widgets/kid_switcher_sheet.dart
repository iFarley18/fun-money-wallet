import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/kid_profile.dart';
import '../models/money_balance.dart';

class KidSwitcherSheet extends StatelessWidget {
  final List<KidProfile> profiles;
  final KidProfile activeProfile;
  final ValueChanged<KidProfile> onSelect;

  const KidSwitcherSheet({
    super.key,
    required this.profiles,
    required this.activeProfile,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Kid Vault',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...profiles.map((p) {
            final isSelected = p.id == activeProfile.id;
            final balanceStr = MoneyBalance(p.balanceCents).toFormattedString();
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? p.themeColor.withOpacity(0.2) : Colors.black26,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? p.themeColor : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: p.themeColor,
                  child: Icon(
                    p.avatarIconName == 'rocket' ? Icons.rocket_launch : Icons.shield,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  p.name,
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  balanceStr,
                  style: GoogleFonts.jetBrainsMono(
                    color: p.themeColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: p.themeColor)
                    : null,
                onTap: () {
                  onSelect(p);
                  Navigator.pop(context);
                },
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
