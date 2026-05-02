import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart';
import '../models/step_alarm_settings.dart';

class AlarmProvider extends ChangeNotifier {
  List<StepAlarmSettings> _alarms = [];
  SharedPreferences? _prefs;

  List<StepAlarmSettings> get alarms => _alarms;

  AlarmProvider() {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    _prefs = await SharedPreferences.getInstance();
    final alarmsString = _prefs?.getStringList('step_alarms') ?? [];
    
    _alarms = alarmsString
        .map((e) => StepAlarmSettings.fromJson(e))
        .toList();
    
    // Sort alarms by time
    _sortAlarms();
    notifyListeners();
  }

  Future<void> _saveAlarms() async {
    if (_prefs == null) return;
    final alarmsString = _alarms.map((e) => e.toJson()).toList();
    await _prefs?.setStringList('step_alarms', alarmsString);
  }

  void _sortAlarms() {
    _alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> addAlarm(StepAlarmSettings alarm) async {
    _alarms.add(alarm);
    _sortAlarms();
    await _saveAlarms();
    
    if (alarm.isEnabled) {
      await scheduleAlarm(alarm);
    }
    notifyListeners();
  }

  Future<void> updateAlarm(StepAlarmSettings alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      _alarms[index] = alarm;
      _sortAlarms();
      await _saveAlarms();
      
      // Reschedule or cancel
      if (alarm.isEnabled) {
        await scheduleAlarm(alarm);
      } else {
        await cancelAlarm(alarm.id);
      }
      notifyListeners();
    }
  }

  Future<void> toggleAlarm(int id, bool isEnabled) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index].copyWith(isEnabled: isEnabled);
      _alarms[index] = alarm;
      await _saveAlarms();
      
      if (isEnabled) {
        // If the date is in the past, move to next day
        DateTime scheduledTime = alarm.dateTime;
        if (scheduledTime.isBefore(DateTime.now())) {
           scheduledTime = scheduledTime.add(const Duration(days: 1));
           _alarms[index] = alarm.copyWith(dateTime: scheduledTime);
           await _saveAlarms();
        }
        await scheduleAlarm(_alarms[index]);
      } else {
        await cancelAlarm(id);
      }
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(int id) async {
    _alarms.removeWhere((a) => a.id == id);
    await _saveAlarms();
    await cancelAlarm(id);
    notifyListeners();
  }

  Future<void> scheduleAlarm(StepAlarmSettings stepAlarm) async {
    final alarmSettings = AlarmSettings(
      id: stepAlarm.id,
      dateTime: stepAlarm.dateTime,
      assetAudioPath: stepAlarm.customRingtonePath ?? 'assets/default_alarm.mp3',
      loopAudio: true,
      vibrate: stepAlarm.vibrate,
      volume: 1.0, // Max volume
      fadeDuration: 3.0,
      notificationTitle: stepAlarm.label,
      notificationBody: 'Wake up! It is time to walk.',
      enableNotificationOnKill: true,
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
  }
}
