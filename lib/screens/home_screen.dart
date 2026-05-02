import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/alarm_provider.dart';
import 'edit_alarm_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STEP ALARM'),
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child) {
          final alarms = alarmProvider.alarms;
          
          if (alarms.isEmpty) {
            return const Center(
              child: Text(
                'No alarms set.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              final timeFormat = DateFormat('hh:mm a').format(alarm.dateTime);
              final isToday = alarm.dateTime.day == DateTime.now().day;
              
              return Dismissible(
                key: Key(alarm.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                onDismissed: (_) {
                  alarmProvider.deleteAlarm(alarm.id);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAlarmScreen(alarm: alarm),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeFormat,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${alarm.label} • ${alarm.requiredSteps} steps',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: alarm.isEnabled,
                            onChanged: (value) {
                              alarmProvider.toggleAlarm(alarm.id, value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditAlarmScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
