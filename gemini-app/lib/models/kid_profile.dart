import 'package:flutter/material.dart';

class KidProfile {
  final String id;
  final String name;
  final int balanceCents;
  final Color themeColor;
  final String avatarIconName;
  final String lastUpdatedText;

  const KidProfile({
    required this.id,
    required this.name,
    required this.balanceCents,
    required this.themeColor,
    required this.avatarIconName,
    required this.lastUpdatedText,
  });

  KidProfile copyWith({
    String? id,
    String? name,
    int? balanceCents,
    Color? themeColor,
    String? avatarIconName,
    String? lastUpdatedText,
  }) {
    return KidProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      balanceCents: balanceCents ?? this.balanceCents,
      themeColor: themeColor ?? this.themeColor,
      avatarIconName: avatarIconName ?? this.avatarIconName,
      lastUpdatedText: lastUpdatedText ?? this.lastUpdatedText,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'balanceCents': balanceCents,
    'themeColorValue': themeColor.value,
    'avatarIconName': avatarIconName,
    'lastUpdatedText': lastUpdatedText,
  };

  factory KidProfile.fromJson(Map<String, dynamic> json) => KidProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    balanceCents: json['balanceCents'] as int,
    themeColor: Color(json['themeColorValue'] as int),
    avatarIconName: json['avatarIconName'] as String,
    lastUpdatedText: json['lastUpdatedText'] as String? ?? 'Set by Parent',
  );
}
