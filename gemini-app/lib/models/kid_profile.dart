import 'package:flutter/material.dart';

class KidProfile {
  final String id;
  final String name;
  final int balanceCents;
  final Color themeColor;
  final String avatarIconName;
  final String lastUpdatedText;
  final String moneyThemeId;

  /// Crew (via Plaid) link info. The Plaid access token never reaches the
  /// app; it stays on the Crew Sync backend. These are display-only ids.
  final String? crewItemId;
  final String? crewAccountId;
  final String? crewAccountLabel;
  final DateTime? lastSyncedAt;

  const KidProfile({
    required this.id,
    required this.name,
    required this.balanceCents,
    required this.themeColor,
    required this.avatarIconName,
    required this.lastUpdatedText,
    this.moneyThemeId = 'default',
    this.crewItemId,
    this.crewAccountId,
    this.crewAccountLabel,
    this.lastSyncedAt,
  });

  bool get isCrewLinked => crewItemId != null && crewAccountId != null;

  KidProfile copyWith({
    String? id,
    String? name,
    int? balanceCents,
    Color? themeColor,
    String? avatarIconName,
    String? lastUpdatedText,
    String? moneyThemeId,
    String? crewItemId,
    String? crewAccountId,
    String? crewAccountLabel,
    DateTime? lastSyncedAt,
    bool clearCrew = false,
  }) {
    return KidProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      balanceCents: balanceCents ?? this.balanceCents,
      themeColor: themeColor ?? this.themeColor,
      avatarIconName: avatarIconName ?? this.avatarIconName,
      lastUpdatedText: lastUpdatedText ?? this.lastUpdatedText,
      moneyThemeId: moneyThemeId ?? this.moneyThemeId,
      crewItemId: clearCrew ? null : (crewItemId ?? this.crewItemId),
      crewAccountId: clearCrew ? null : (crewAccountId ?? this.crewAccountId),
      crewAccountLabel: clearCrew ? null : (crewAccountLabel ?? this.crewAccountLabel),
      lastSyncedAt: clearCrew ? null : (lastSyncedAt ?? this.lastSyncedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'balanceCents': balanceCents,
    'themeColorValue': themeColor.value,
    'avatarIconName': avatarIconName,
    'lastUpdatedText': lastUpdatedText,
    'moneyThemeId': moneyThemeId,
    if (crewItemId != null) 'crewItemId': crewItemId,
    if (crewAccountId != null) 'crewAccountId': crewAccountId,
    if (crewAccountLabel != null) 'crewAccountLabel': crewAccountLabel,
    if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt!.toIso8601String(),
  };

  factory KidProfile.fromJson(Map<String, dynamic> json) => KidProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    balanceCents: json['balanceCents'] as int,
    themeColor: Color(json['themeColorValue'] as int),
    avatarIconName: json['avatarIconName'] as String,
    lastUpdatedText: json['lastUpdatedText'] as String? ?? 'Set by Parent',
    moneyThemeId: json['moneyThemeId'] as String? ?? 'default',
    crewItemId: json['crewItemId'] as String?,
    crewAccountId: json['crewAccountId'] as String?,
    crewAccountLabel: json['crewAccountLabel'] as String?,
    lastSyncedAt: json['lastSyncedAt'] == null ? null : DateTime.tryParse(json['lastSyncedAt'] as String),
  );
}
