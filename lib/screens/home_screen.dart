import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/alarm_provider.dart';
import 'edit_alarm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<int> _selectedAlarms = {};

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedAlarms.contains(id)) {
        _selectedAlarms.remove(id);
      } else {
        _selectedAlarms.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedAlarms.clear();
    });
  }

  void _deleteSelected(AlarmProvider provider) {
    for (final id in _selectedAlarms) {
      provider.deleteAlarm(id);
    }
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectionMode = _selectedAlarms.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        title: Text(isSelectionMode ? '${_selectedAlarms.length} Selected' : 'STEP ALARM'),
        actions: [
          if (isSelectionMode)
            Consumer<AlarmProvider>(
              builder: (context, alarmProvider, child) {
                return IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteSelected(alarmProvider),
                );
              },
            ),
        ],
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
              final isSelected = _selectedAlarms.contains(alarm.id);
              
              return Dismissible(
                key: Key(alarm.id.toString()),
                direction: isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  color: isSelected ? Colors.deepPurpleAccent.withOpacity(0.2) : const Color(0xFF1E1E1E),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onLongPress: () {
                      _toggleSelection(alarm.id);
                    },
                    onTap: () {
                      if (isSelectionMode) {
                        _toggleSelection(alarm.id);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAlarmScreen(alarm: alarm),
                          ),
                        );
                      }
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
                          if (isSelectionMode)
                            Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleSelection(alarm.id),
                              activeColor: Colors.deepPurpleAccent,
                            )
                          else
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
      floatingActionButton: isSelectionMode ? null : FloatingActionButton(
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
