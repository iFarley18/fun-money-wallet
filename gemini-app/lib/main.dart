import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repositories/local_balance_repository.dart';
import 'services/pin_service.dart';
import 'screens/vault_sandbox_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final balanceRepository = LocalBalanceRepository(prefs);
  await balanceRepository.initDefaultsIfNeeded();
  final pinService = PinService(prefs);

  runApp(CrewStashApp(
    balanceRepository: balanceRepository,
    pinService: pinService,
  ));
}

class CrewStashApp extends StatelessWidget {
  final LocalBalanceRepository balanceRepository;
  final PinService pinService;

  const CrewStashApp({
    super.key,
    required this.balanceRepository,
    required this.pinService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crew Stash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF6B00),
          surface: Color(0xFF1E293B),
        ),
        textTheme: GoogleFonts.fredokaTextTheme(ThemeData.dark().textTheme),
      ),
      home: VaultSandboxScreen(
        balanceRepository: balanceRepository,
        pinService: pinService,
      ),
    );
  }
}
