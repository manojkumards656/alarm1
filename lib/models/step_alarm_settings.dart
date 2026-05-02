import 'dart:convert';
import 'package:flutter/material.dart';

class StepAlarmSettings {
  final int id;
  final DateTime dateTime;
  final String label;
  final bool vibrate;
  final String? customRingtonePath;
  final int requiredSteps;
  final int timeLimitMinutes;
  final bool isEnabled;

  StepAlarmSettings({
    required this.id,
    required this.dateTime,
    this.label = 'Alarm',
    this.vibrate = true,
    this.customRingtonePath,
    this.requiredSteps = 10,
    this.timeLimitMinutes = 10,
    this.isEnabled = true,
  });

  StepAlarmSettings copyWith({
    int? id,
    DateTime? dateTime,
    String? label,
    bool? vibrate,
    String? customRingtonePath,
    int? requiredSteps,
    int? timeLimitMinutes,
    bool? isEnabled,
  }) {
    return StepAlarmSettings(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      label: label ?? this.label,
      vibrate: vibrate ?? this.vibrate,
      customRingtonePath: customRingtonePath ?? this.customRingtonePath,
      requiredSteps: requiredSteps ?? this.requiredSteps,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'label': label,
      'vibrate': vibrate,
      'customRingtonePath': customRingtonePath,
      'requiredSteps': requiredSteps,
      'timeLimitMinutes': timeLimitMinutes,
      'isEnabled': isEnabled,
    };
  }

  factory StepAlarmSettings.fromMap(Map<String, dynamic> map) {
    return StepAlarmSettings(
      id: map['id']?.toInt() ?? 0,
      dateTime: DateTime.parse(map['dateTime']),
      label: map['label'] ?? 'Alarm',
      vibrate: map['vibrate'] ?? true,
      customRingtonePath: map['customRingtonePath'],
      requiredSteps: map['requiredSteps']?.toInt() ?? 10,
      timeLimitMinutes: map['timeLimitMinutes']?.toInt() ?? 10,
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory StepAlarmSettings.fromJson(String source) =>
      StepAlarmSettings.fromMap(json.decode(source));
}
