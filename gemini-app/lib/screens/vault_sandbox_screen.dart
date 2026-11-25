import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/denomination_breakdown.dart';
import '../models/kid_profile.dart';
import '../models/money_balance.dart';
import '../models/physics_item.dart';
import '../repositories/balance_repository.dart';
import '../services/pin_service.dart';
import '../widgets/kid_switcher_sheet.dart';
import '../widgets/play_bill_widget.dart';
import '../widgets/play_coin_widget.dart';
import '../widgets/what_if_scanner_drawer.dart';
import 'parent_control_panel_screen.dart';
import 'parent_pin_dialog.dart';

class VaultSandboxScreen extends StatefulWidget {
  final BalanceRepository balanceRepository;
  final PinService pinService;

  const VaultSandboxScreen({
    super.key,
    required this.balanceRepository,
    required this.pinService,
  });

  @override
  State<VaultSandboxScreen> createState() => _VaultSandboxScreenState();
}

class _VaultSandboxScreenState extends State<VaultSandboxScreen> {
  List<KidProfile> _profiles = [];
  KidProfile? _activeProfile;
  List<PhysicsItem> _items = [];
  bool _showItemCount = false;
  Timer? _ticker;
  int _targetTestCents = 0;
  bool _isScannerOpen = false;

  // Canvas physics boundaries
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _startPhysicsLoop();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    final profiles = await widget.balanceRepository.getKidProfiles();
    if (profiles.isNotEmpty) {
      setState(() {
        _profiles = profiles;
        if (_activeProfile == null) {
          _activeProfile = profiles.first;
        } else {
          final updated = profiles.where((p) => p.id == _activeProfile!.id);
          _activeProfile = updated.isNotEmpty ? updated.first : profiles.first;
        }
      });
      _generatePhysicsItems();
    }
  }

  void _generatePhysicsItems() {
    if (_activeProfile == null || _canvasSize == Size.zero) return;
    final breakdown = DenominationBreakdown.fromCents(_activeProfile!.balanceCents);
    final stacks = breakdown.toVisibleStacks();
    final scale = PhysicsItem.computeScaleForStacks(stacks, _canvasSize);
    final rand = Random(42);

    final newItems = <PhysicsItem>[];
    int idx = 0;
    for (final stack in stacks) {
      final baseSize = PhysicsItem.baseSizeFor(stack.type);
      final itemW = baseSize.width * scale;
      final itemH = baseSize.height * scale;
      final minX = 14.0;
      final maxX = max(minX, _canvasSize.width - itemW - 14.0);
      final minY = 122.0;
      final maxY = max(minY, _canvasSize.height - itemH - 110.0);

      for (int i = 0; i < stack.visibleCount; i++) {
        final posX = minX + rand.nextDouble() * (maxX - minX);
        final posY = minY + rand.nextDouble() * (maxY - minY);
        newItems.add(PhysicsItem(
          id: 'item_${idx}_${stack.type.name}',
          type: stack.type,
          position: Offset(posX, posY),
          rotation: (rand.nextDouble() - 0.5) * 0.36,
          scale: scale,
          stackCount: stack.isCollapsed ? stack.totalCount : 1,
        ));
        idx++;
      }
    }
    setState(() {
      _items = newItems;
    });
  }

  void _startPhysicsLoop() {
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_items.isEmpty || _canvasSize == Size.zero) return;
      bool updated = false;
      for (var item in _items) {
        if (item.isDragging) continue;
        if (item.velocity.dx.abs() > 0.1 || item.velocity.dy.abs() > 0.1) {
          updated = true;
          item.position += item.velocity;
          // Air drag friction
          final friction = item.type.isBill ? 0.88 : 0.94;
          item.velocity *= friction;
          item.rotation += item.angularVelocity;
          item.angularVelocity *= 0.90;

          // Boundaries bouncing
          const minX = 10.0;
          final maxX = max(minX, _canvasSize.width - item.size.width - 10);
          const minY = 115.0;
          final maxY = max(minY, _canvasSize.height - item.size.height - 105);

          if (item.position.dx < minX) {
            item.position = Offset(minX, item.position.dy);
            item.velocity = Offset(-item.velocity.dx * 0.5, item.velocity.dy);
          } else if (item.position.dx > maxX) {
            item.position = Offset(maxX, item.position.dy);
            item.velocity = Offset(-item.velocity.dx * 0.5, item.velocity.dy);
          }
          if (item.position.dy < minY) {
            item.position = Offset(item.position.dx, minY);
            item.velocity = Offset(item.velocity.dx, -item.velocity.dy * 0.5);
          } else if (item.position.dy > maxY) {
            item.position = Offset(item.position.dx, maxY);
            item.velocity = Offset(item.velocity.dx, -item.velocity.dy * 0.5);
          }
        }
      }
      if (updated) setState(() {});
    });
  }

  void _tidyStacks() {
    HapticFeedback.heavyImpact();
    if (_canvasSize == Size.zero || _items.isEmpty) return;

    final Map<DenominationType, List<PhysicsItem>> byType = {};
    for (final item in _items) {
      byType.putIfAbsent(item.type, () => []).add(item);
    }

    final billTypes = DenominationType.values
        .where((t) => t.isBill && byType.containsKey(t))
        .toList();
    final coinTypes = DenominationType.values
        .where((t) => !t.isBill && byType.containsKey(t))
        .toList();

    final availW = _canvasSize.width - 24.0;
    const topY = 124.0;
    final bottomY = _canvasSize.height - 110.0;
    final totalAvailH = max(160.0, bottomY - topY);

    final billRows = billTypes.isEmpty ? 0 : (billTypes.length / 3).ceil();
    final hasCoins = coinTypes.isNotEmpty;
    final coinAreaH = hasCoins ? min(150.0, totalAvailH * (billRows > 0 ? 0.30 : 0.85)) : 0.0;
    final billAreaH = max(0.0, totalAvailH - coinAreaH - (hasCoins && billRows > 0 ? 16.0 : 0.0));

    setState(() {
      if (billTypes.isNotEmpty) {
        final rowHeight = billAreaH / billRows;
        for (int r = 0; r < billRows; r++) {
          final start = r * 3;
          final end = min(start + 3, billTypes.length);
          final rowTypes = billTypes.sublist(start, end);
          final cols = rowTypes.length;
          final billW = byType[rowTypes.first]!.first.size.width;
          final billH = byType[rowTypes.first]!.first.size.height;
          final gap = min(16.0, max(6.0, (availW - cols * billW) / max(cols + 1, 1)));
          final rowContentW = cols * billW + (cols - 1) * gap;
          final startX = 12.0 + max(0.0, (availW - rowContentW) / 2.0);
          final rowTopY = topY + r * rowHeight;
          final maxStackDelta = max(0.0, rowHeight - billH - 8.0);

          for (int c = 0; c < cols; c++) {
            final group = byType[rowTypes[c]]!;
            final stepY = group.length > 1
                ? min(12.0, maxStackDelta / (group.length - 1))
                : 0.0;
            final x = startX + c * (billW + gap);
            for (int k = 0; k < group.length; k++) {
              group[k].position = Offset(x, rowTopY + k * stepY);
              group[k].velocity = Offset.zero;
              group[k].angularVelocity = 0;
              group[k].rotation = 0;
            }
          }
        }
      }

      if (coinTypes.isNotEmpty) {
        final cols = coinTypes.length;
        final maxCoinW = coinTypes
            .map((t) => byType[t]!.first.size.width)
            .reduce(max);
        final gap = min(22.0, max(8.0, (availW - cols * maxCoinW) / max(cols + 1, 1)));
        final rowContentW = cols * maxCoinW + (cols - 1) * gap;
        final startX = 12.0 + max(0.0, (availW - rowContentW) / 2.0);
        final coinTopY = billRows > 0 ? (topY + billAreaH + 14.0) : topY + 20.0;
        final maxCoinStackDelta = max(0.0, coinAreaH - maxCoinW - 8.0);

        for (int c = 0; c < cols; c++) {
          final group = byType[coinTypes[c]]!;
          final coinW = group.first.size.width;
          final stepY = group.length > 1
              ? min(10.0, maxCoinStackDelta / (group.length - 1))
              : 0.0;
          final x = startX + c * (maxCoinW + gap) + (maxCoinW - coinW) / 2.0;
          for (int k = 0; k < group.length; k++) {
            group[k].position = Offset(x, coinTopY + k * stepY);
            group[k].velocity = Offset.zero;
            group[k].angularVelocity = 0;
            group[k].rotation = 0;
          }
        }
      }
    });
  }

  void _explodeScatter() {
    HapticFeedback.mediumImpact();
    final rand = Random();
    setState(() {
      for (var item in _items) {
        final angle = rand.nextDouble() * 2 * pi;
        final speed = 12.0 + rand.nextDouble() * 18.0;
        item.velocity = Offset(cos(angle) * speed, sin(angle) * speed);
        item.angularVelocity = (rand.nextDouble() - 0.5) * 0.3;
      }
    });
  }

  void _openParentGate() {
    showDialog(
      context: context,
      builder: (context) => ParentPinDialog(
        pinService: widget.pinService,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParentControlPanelScreen(
                balanceRepository: widget.balanceRepository,
                pinService: widget.pinService,
              ),
            ),
          ).then((_) => _loadProfiles());
        },
      ),
    );
  }

  int _calculateTrayCents() {
    if (_targetTestCents == 0 || _canvasSize == Size.zero) return 0;
    final trayRect = Rect.fromLTWH(20, _canvasSize.height - 230, _canvasSize.width - 40, 110);
    int sum = 0;
    for (var item in _items) {
      final itemRect = item.position & item.size;
      if (trayRect.overlaps(itemRect)) {
        sum += item.totalCents;
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeProfile;
    final breakdown = active != null ? DenominationBreakdown.fromCents(active.balanceCents) : null;
    final trayCents = _calculateTrayCents();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_canvasSize != Size(constraints.maxWidth, constraints.maxHeight)) {
            _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
            WidgetsBinding.instance.addPostFrameCallback((_) => _generatePhysicsItems());
          }

          return Stack(
            children: [
              // Vault Floor Background Surface
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    radius: 1.2,
                  ),
                ),
              ),
              // Physics Canvas Area
              if (active != null && active.balanceCents == 0)
                _buildEmptyVaultState()
              else
                ..._items.map((item) => _buildPhysicsItemWidget(item)),

              // What-If Purchase Drop Tray Overlay
              if (_targetTestCents > 0)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 120,
                  child: _buildPurchaseTrayWidget(trayCents),
                ),

              // Top HUD Navigation Bar
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: _buildTopHUD(active, breakdown),
              ),

              // Bottom Dock Controls
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: _buildBottomDock(),
              ),

              // Purchase Scanner Drawer Sheet
              if (_isScannerOpen)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: WhatIfScannerDrawer(
                    currentTargetCents: _targetTestCents,
                    onTargetPriceSet: (cents) {
                      setState(() {
                        _targetTestCents = cents;
                      });
                    },
                    onClose: () => setState(() => _isScannerOpen = false),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopHUD(KidProfile? active, DenominationBreakdown? breakdown) {
    final balanceText = active != null ? MoneyBalance(active.balanceCents).toFormattedString() : '\$0.00';
    final itemCountText = breakdown != null ? '${breakdown.totalBills} Bills • ${breakdown.totalCoins} Coins' : '0 Items';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Active Kid Pill
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => KidSwitcherSheet(
                profiles: _profiles,
                activeProfile: active!,
                onSelect: (selected) {
                  setState(() {
                    _activeProfile = selected;
                  });
                  _generatePhysicsItems();
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: active?.themeColor ?? Colors.cyan, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  KidSwitcherSheet.iconForAvatar(active?.avatarIconName ?? 'shield'),
                  color: active?.themeColor ?? Colors.cyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  active?.name ?? 'Stash',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white70),
              ],
            ),
          ),
        ),

        // Balance Badge
        GestureDetector(
          onTap: () {
            setState(() {
              _showItemCount = !_showItemCount;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _showItemCount ? itemCountText : balanceText,
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF00E5FF),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  active?.lastUpdatedText ?? 'Set by Dad',
                  style: GoogleFonts.plusJakartaSans(fontSize: 8, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),

        // Parent Access Gear
        GestureDetector(
          onLongPress: _openParentGate,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hold Parent Gear for 2 seconds to enter Admin PIN'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings, color: Colors.amberAccent, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicsItemWidget(PhysicsItem item) {
    final themeId = _activeProfile?.moneyThemeId;
    final coreWidget = item.type.isBill
        ? PlayBillWidget(
            type: item.type,
            themeId: themeId,
            width: item.size.width,
            height: item.size.height,
          )
        : PlayCoinWidget(
            type: item.type,
            themeId: themeId,
            size: item.size.width,
          );

    final visual = item.stackCount > 1
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 4,
                top: 4,
                child: Opacity(opacity: 0.45, child: coreWidget),
              ),
              Positioned(
                left: 2,
                top: 2,
                child: Opacity(opacity: 0.72, child: coreWidget),
              ),
              coreWidget,
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amberAccent, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    'x${item.stackCount}',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.amberAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          )
        : coreWidget;

    return Positioned(
      left: item.position.dx,
      top: item.position.dy,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() {
            item.isDragging = true;
            item.velocity = Offset.zero;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            item.position += details.delta;
            item.velocity = details.delta;
          });
        },
        onPanEnd: (details) {
          setState(() {
            item.isDragging = false;
            item.velocity = details.velocity.pixelsPerSecond / 60.0;
          });
        },
        child: Transform.rotate(
          angle: item.rotation,
          child: visual,
        ),
      ),
    );
  }

  Widget _buildEmptyVaultState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.savings, size: 90, color: Colors.amberAccent),
          const SizedBox(height: 16),
          Text(
            'Empty Vault!',
            style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Time to earn money through chores!',
            style: GoogleFonts.plusJakartaSans(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTrayWidget(int trayCents) {
    final targetStr = MoneyBalance(_targetTestCents).toFormattedString();
    final trayStr = MoneyBalance(trayCents).toFormattedString();
    final isCovered = trayCents >= _targetTestCents;

    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCovered ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCovered ? Colors.greenAccent : Colors.amberAccent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TEST PURCHASE TRAY (Drag cash here)',
                style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                'Target: $targetStr  |  In Tray: $trayStr',
                style: GoogleFonts.jetBrainsMono(
                  color: isCovered ? Colors.greenAccent : Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.white54),
            onPressed: () => setState(() => _targetTestCents = 0),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _tidyStacks,
          icon: const Icon(Icons.align_horizontal_left, size: 18),
          label: Text('Tidy', style: GoogleFonts.fredoka()),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: const Color(0xFFFF6B00),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _explodeScatter,
          icon: const Icon(Icons.bolt, size: 18),
          label: Text('Scatter', style: GoogleFonts.fredoka()),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => setState(() => _isScannerOpen = true),
          icon: const Icon(Icons.qr_code_scanner, size: 18),
          label: Text('What-If?', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
