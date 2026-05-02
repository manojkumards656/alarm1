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
        
        final timeString = DateFormat('hh:mm').format(DateTime.now());
        final amPm = DateFormat('a').format(DateTime.now());

        return Scaffold(
          backgroundColor: isPenalty ? Colors.red.shade900 : const Color(0xFF121212),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Clock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        amPm,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Label
                  Text(
                    alarm?.label ?? 'Wake Up!',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  
                  // Conditional UI (Dismiss vs Penalty Timer)
                  if (isPenalty) ...[
                    const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'PENALTY',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You failed to walk the required steps.\nAlarm cannot be dismissed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '00:${provider.penaltySecondsRemaining.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Phase 1 Dismiss Button
                    GestureDetector(
                      onTap: () {
                        provider.dismissPhase1();
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.deepPurpleAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'DISMISS',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Tap to start Step Verification',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    )
                  ],
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
