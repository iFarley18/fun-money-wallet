import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pin_service.dart';

class ParentPinDialog extends StatefulWidget {
  final PinService pinService;
  final VoidCallback onSuccess;

  const ParentPinDialog({
    super.key,
    required this.pinService,
    required this.onSuccess,
  });

  @override
  State<ParentPinDialog> createState() => _ParentPinDialogState();
}

class _ParentPinDialogState extends State<ParentPinDialog> {
  String _enteredPin = '';
  String? _errorMessage;

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = null;
      });
      if (_enteredPin.length == 4) {
        _verify();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verify() async {
    final valid = await widget.pinService.verifyPin(_enteredPin);
    if (valid) {
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Try default: 1234';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock, color: Color(0xFF00E5FF), size: 42),
            const SizedBox(height: 12),
            Text(
              'Parent Gate PIN',
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter 4-digit security PIN',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            // PIN Dots Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? const Color(0xFF00E5FF) : Colors.white24,
                  ),
                );
              }),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            // Keypad Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                if (index == 9) return const SizedBox.shrink();
                if (index == 10) return _keyButton('0');
                if (index == 11) {
                  return IconButton(
                    icon: const Icon(Icons.backspace, color: Colors.white70),
                    onPressed: _onDelete,
                  );
                }
                return _keyButton('${index + 1}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyButton(String digit) {
    return InkWell(
      onTap: () => _onKeyPress(digit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
