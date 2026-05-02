import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:pedometer/pedometer.dart';
import '../models/step_alarm_settings.dart';
import 'alarm_provider.dart';

enum ActiveAlarmState {
  idle,
  ringingPhase1,
  stepVerificationPhase15,
  penaltyRingingPhase2,
}

class ActiveAlarmProvider extends ChangeNotifier {
  final AlarmProvider alarmProvider;
  StreamSubscription<AlarmSettings>? _ringSubscription;
  StreamSubscription<StepCount>? _stepSubscription;
  
  ActiveAlarmState _state = ActiveAlarmState.idle;
  ActiveAlarmState get state => _state;

  StepAlarmSettings? _activeStepAlarm;
  StepAlarmSettings? get activeStepAlarm => _activeStepAlarm;

  int _initialSteps = 0;
  int _currentSteps = 0;
  int _targetSteps = 0;
  int get stepsTaken => _currentSteps - _initialSteps > 0 ? _currentSteps - _initialSteps : 0;
  int get targetSteps => _targetSteps;

  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  int get secondsRemaining => _secondsRemaining;

  Timer? _penaltyTimer;
  int _penaltySecondsRemaining = 0;
  int get penaltySecondsRemaining => _penaltySecondsRemaining;

  ActiveAlarmProvider({required this.alarmProvider}) {
    _initRingListener();
  }

  void _initRingListener() {
    _ringSubscription = Alarm.ringingStream.listen((alarmSettings) {
      _handleAlarmRing(alarmSettings);
    });
  }

  void _handleAlarmRing(AlarmSettings alarmSettings) {
    bool isPenalty = alarmSettings.id >= 100000;
    int originalId = isPenalty ? alarmSettings.id - 100000 : alarmSettings.id;

    // Find the original step alarm settings
    final stepAlarm = alarmProvider.alarms.firstWhere(
      (a) => a.id == originalId,
      orElse: () => StepAlarmSettings(
        id: originalId, 
        dateTime: DateTime.now(), 
        label: 'Unknown Alarm',
      ),
    );

    _activeStepAlarm = stepAlarm;

    if (isPenalty) {
      _startPenaltyPhase2();
    } else {
      _startRingingPhase1();
    }
  }

  void _startRingingPhase1() {
    _state = ActiveAlarmState.ringingPhase1;
    notifyListeners();
  }

  Future<void> dismissPhase1() async {
    if (_activeStepAlarm == null) return;
    
    // Stop the actual sound
    await Alarm.stop(_activeStepAlarm!.id);
    
    // Schedule the backup penalty alarm
    final penaltyId = _activeStepAlarm!.id + 100000;
    final timeLimit = _activeStepAlarm!.timeLimitMinutes;
    final penaltyTime = DateTime.now().add(Duration(minutes: timeLimit));
    
    final penaltySettings = AlarmSettings(
      id: penaltyId,
      dateTime: penaltyTime,
      assetAudioPath: _activeStepAlarm!.customRingtonePath ?? 'assets/default_alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(
        volume: 1.0,
        volumeEnforced: true,
      ),
      notificationSettings: const NotificationSettings(
        title: "Penalty: Walk Failed!",
        body: "You didn't walk enough. Time to get up!",
      ),
    );
    await Alarm.set(alarmSettings: penaltySettings);

    // Transition to Phase 1.5
    _state = ActiveAlarmState.stepVerificationPhase15;
    _secondsRemaining = timeLimit * 60;
    
    _startCountdownTimer();
    _startStepTracking();
    notifyListeners();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        // Time ran out! The penalty alarm will fire on its own via the Alarm package.
        // We just stop the timer and wait for the ringStream to handle it.
        timer.cancel();
      }
    });
  }

  void _startStepTracking() {
    _stepSubscription?.cancel();
    _initialSteps = 0;
    _currentSteps = 0;
    _targetSteps = _activeStepAlarm?.requiredSteps ?? 10;
    bool isFirstEvent = true;

    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (isFirstEvent) {
          _initialSteps = event.steps;
          _currentSteps = event.steps;
          isFirstEvent = false;
        } else {
          _currentSteps = event.steps;
        }
        
        if (stepsTaken >= _targetSteps) {
          _handleSuccess();
        } else {
          notifyListeners();
        }
      },
      onError: (error) {
        print("Pedometer error: $error");
        // Fallback or just ignore. In a real app we might use shake detection as fallback.
      },
    );
  }

  Future<void> _handleSuccess() async {
    _cleanupAll();
    
    // Stop the penalty alarm if it's scheduled
    if (_activeStepAlarm != null) {
      await Alarm.stop(_activeStepAlarm!.id + 100000);
      
      // Update the main alarm provider if needed (e.g., repeating alarms)
      // For now we just let it be, but toggle it off if it's a one-time alarm.
      alarmProvider.toggleAlarm(_activeStepAlarm!.id, false);
    }
    
    _state = ActiveAlarmState.idle;
    notifyListeners();
  }

  void _startPenaltyPhase2() {
    _cleanupAll();
    _state = ActiveAlarmState.penaltyRingingPhase2;
    _penaltySecondsRemaining = 60; // 1 minute of continuous ringing
    
    _penaltyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_penaltySecondsRemaining > 0) {
        _penaltySecondsRemaining--;
        notifyListeners();
      } else {
        // Stop penalty and restart step verification
        timer.cancel();
        _restartStepVerification();
      }
    });
    
    notifyListeners();
  }

  Future<void> _restartStepVerification() async {
    if (_activeStepAlarm != null) {
      await Alarm.stop(_activeStepAlarm!.id + 100000);
      
      // We automatically pretend the user "dismissed" it again and give them another chance
      // But maybe a shorter time limit? We'll just use the same limit for simplicity
      await dismissPhase1();
    } else {
      _state = ActiveAlarmState.idle;
      notifyListeners();
    }
  }

  void _cleanupAll() {
    _countdownTimer?.cancel();
    _penaltyTimer?.cancel();
    _stepSubscription?.cancel();
  }

  @override
  void dispose() {
    _ringSubscription?.cancel();
    _cleanupAll();
    super.dispose();
  }
}
