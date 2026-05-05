import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_theme.dart';
import 'providers/alarm_provider.dart';
import 'providers/active_alarm_provider.dart';
import 'screens/home_screen.dart';
import 'screens/ringing_screen.dart';
import 'screens/step_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Alarm package
  await Alarm.init();

  // Request basic permissions
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();
  await Permission.activityRecognition.request(); // For Pedometer
  await Permission.ignoreBatteryOptimizations.request();
  await Permission.systemAlertWindow.request();

  // Set warning notification if app is killed
  await Alarm.setWarningNotificationOnKill(
    'Step Alarm',
    'Alarm may not ring if the app is killed.',
  );

  runApp(const StepAlarmApp());
}

class StepAlarmApp extends StatelessWidget {
  const StepAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProxyProvider<AlarmProvider, ActiveAlarmProvider>(
          create: (context) => ActiveAlarmProvider(
            alarmProvider: Provider.of<AlarmProvider>(context, listen: false),
          ),
          update: (context, alarmProvider, previous) => 
              previous ?? ActiveAlarmProvider(alarmProvider: alarmProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Step Alarm',
        theme: AppTheme.darkTheme,
        home: const AlarmWatcher(child: HomeScreen()),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AlarmWatcher extends StatelessWidget {
  final Widget child;
  
  const AlarmWatcher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveAlarmProvider>(
      builder: (context, activeAlarmProvider, _) {
        final state = activeAlarmProvider.state;

        if (state == ActiveAlarmState.ringingPhase1 || 
            state == ActiveAlarmState.penaltyRingingPhase2) {
          return const RingingScreen();
        } else if (state == ActiveAlarmState.stepVerificationPhase15) {
          return const StepVerificationScreen();
        }
        
        return child;
      },
    );
  }
}
