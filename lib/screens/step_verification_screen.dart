import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/active_alarm_provider.dart';

class StepVerificationScreen extends StatelessWidget {
  const StepVerificationScreen({super.key});

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveAlarmProvider>(
      builder: (context, provider, child) {
        final stepsTaken = provider.stepsTaken;
        final targetSteps = provider.targetSteps;
        final progress = targetSteps > 0 ? (stepsTaken / targetSteps).clamp(0.0, 1.0) : 0.0;
        
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'STEP VERIFICATION',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Walk $targetSteps steps to fully dismiss the alarm.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  
                  // Circular Progress Indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 20,
                          backgroundColor: const Color(0xFF1E1E1E),
                          color: Colors.tealAccent,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_walk, size: 40, color: Colors.tealAccent),
                          const SizedBox(height: 8),
                          Text(
                            '$stepsTaken',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/ $targetSteps steps',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Countdown Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TIME REMAINING',
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1.5,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(provider.secondsRemaining),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'If time runs out, the penalty alarm will trigger.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
