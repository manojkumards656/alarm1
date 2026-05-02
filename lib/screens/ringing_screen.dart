import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/active_alarm_provider.dart';

class RingingScreen extends StatelessWidget {
  const RingingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveAlarmProvider>(
      builder: (context, provider, child) {
        final isPenalty = provider.state == ActiveAlarmState.penaltyRingingPhase2;
        final alarm = provider.activeStepAlarm;
        
        final timeString = DateFormat('HH:mm').format(DateTime.now());

        return Scaffold(
          backgroundColor: isPenalty ? const Color(0xFF4A1010) : Colors.black,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Clock
                  Text(
                    timeString,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Label
                  Text(
                    alarm?.label ?? 'Alarm',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(flex: 2),
                  
                  // Conditional UI
                  if (isPenalty) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'PENALTY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You didn\'t complete the steps.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '${provider.penaltySecondsRemaining}s',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Dismiss button
                    GestureDetector(
                      onTap: () => provider.dismissPhase1(),
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8AB4F8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8AB4F8).withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'DISMISS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tap to start step verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
