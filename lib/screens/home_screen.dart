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

  String _getScheduleLabel(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final alarmDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = alarmDay.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEE, MMM d').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectionMode = _selectedAlarms.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isSelectionMode) ...[
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: _clearSelection,
                    ),
                    Text(
                      '${_selectedAlarms.length} selected',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Consumer<AlarmProvider>(
                      builder: (context, alarmProvider, child) {
                        return IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                          onPressed: () => _deleteSelected(alarmProvider),
                        );
                      },
                    ),
                  ] else ...[
                    const Text(
                      'Alarm',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Icon(Icons.more_vert, color: Colors.white54, size: 24),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Alarm List
            Expanded(
              child: Consumer<AlarmProvider>(
                builder: (context, alarmProvider, child) {
                  final alarms = alarmProvider.alarms;

                  if (alarms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alarm_off, size: 64, color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'No alarms',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = alarms[index];
                      final timeFormat = DateFormat('HH:mm').format(alarm.dateTime);
                      final scheduleLabel = _getScheduleLabel(alarm.dateTime);
                      final isSelected = _selectedAlarms.contains(alarm.id);

                      return Column(
                        children: [
                          if (index == 0)
                            Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                          InkWell(
                            onLongPress: () => _toggleSelection(alarm.id),
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
                            child: Container(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  // Time and label
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          timeFormat,
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w300,
                                            color: alarm.isEnabled
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.35),
                                            letterSpacing: -1,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$scheduleLabel · ${alarm.label}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: alarm.isEnabled
                                                ? Colors.white.withOpacity(0.6)
                                                : Colors.white.withOpacity(0.25),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Toggle or checkbox
                                  if (isSelectionMode)
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _toggleSelection(alarm.id),
                                      activeColor: const Color(0xFF6E9BE0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    )
                                  else
                                    Switch(
                                      value: alarm.isEnabled,
                                      onChanged: (value) {
                                        alarmProvider.toggleAlarm(alarm.id, value);
                                      },
                                      activeColor: const Color(0xFF6E9BE0),
                                      activeTrackColor: const Color(0xFF6E9BE0).withOpacity(0.4),
                                      inactiveThumbColor: Colors.grey.shade500,
                                      inactiveTrackColor: Colors.grey.shade800,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditAlarmScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF6E9BE0),
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.black, size: 28),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
