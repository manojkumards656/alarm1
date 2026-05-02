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
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),

                    // Title
                    const Text(
                      'Step Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Walk $targetSteps steps to dismiss',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),

                    const Spacer(),
                    
                    // Circular Progress
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background ring
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 12,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          // Progress ring
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              color: const Color(0xFF8AB4F8),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          // Center content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_walk,
                                size: 32,
                                color: const Color(0xFF8AB4F8).withOpacity(0.8),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$stepsTaken',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '/ $targetSteps',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Keep walking!\nAndroid batches steps to save battery.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const Spacer(),
                    
                    // Countdown Timer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TIME REMAINING',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: Colors.redAccent.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(provider.secondsRemaining),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              fontFamily: 'monospace',
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Penalty alarm triggers when time runs out',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
