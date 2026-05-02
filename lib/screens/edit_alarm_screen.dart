import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/step_alarm_settings.dart';
import '../providers/alarm_provider.dart';

class EditAlarmScreen extends StatefulWidget {
  final StepAlarmSettings? alarm;

  const EditAlarmScreen({super.key, this.alarm});

  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late int _requiredSteps;
  late int _timeLimitMinutes;
  late bool _vibrate;
  String? _customRingtonePath;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.alarm!.dateTime);
      _labelController = TextEditingController(text: widget.alarm!.label);
      _requiredSteps = widget.alarm!.requiredSteps;
      _timeLimitMinutes = widget.alarm!.timeLimitMinutes;
      _vibrate = widget.alarm!.vibrate;
      _customRingtonePath = widget.alarm!.customRingtonePath;
    } else {
      _selectedTime = TimeOfDay.now();
      _labelController = TextEditingController(text: 'Wake Up!');
      _requiredSteps = 10;
      _timeLimitMinutes = 10;
      _vibrate = true;
      _customRingtonePath = null;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickRingtone() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _customRingtonePath = result.files.single.path;
      });
    }
  }

  void _saveAlarm() {
    final now = DateTime.now();
    DateTime dt = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    
    // If the time is in the past, schedule for tomorrow
    if (dt.isBefore(now)) {
      dt = dt.add(const Duration(days: 1));
    }

    final newAlarm = StepAlarmSettings(
      id: widget.alarm?.id ?? dt.millisecondsSinceEpoch.remainder(100000),
      dateTime: dt,
      label: _labelController.text.trim().isEmpty ? 'Alarm' : _labelController.text.trim(),
      requiredSteps: _requiredSteps,
      timeLimitMinutes: _timeLimitMinutes,
      vibrate: _vibrate,
      customRingtonePath: _customRingtonePath,
      isEnabled: true,
    );

    final provider = context.read<AlarmProvider>();
    if (widget.alarm == null) {
      provider.addAlarm(newAlarm);
    } else {
      provider.updateAlarm(newAlarm);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'New Alarm' : 'Edit Alarm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 30),
            onPressed: _saveAlarm,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Time Picker
          Center(
            child: InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Label
          TextField(
            controller: _labelController,
            decoration: InputDecoration(
              labelText: 'Alarm Label',
              prefixIcon: const Icon(Icons.label_outline, color: Colors.deepPurpleAccent),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),

          // Settings Cards
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.directions_walk, color: Colors.tealAccent),
                  title: const Text('Required Steps', style: TextStyle(color: Colors.white)),
                  trailing: DropdownButton<int>(
                    value: _requiredSteps,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    underline: const SizedBox(),
                    items: [10, 20, 30, 50, 100].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value steps'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _requiredSteps = newValue;
                        });
                      }
                    },
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.timer_outlined, color: Colors.tealAccent),
                  title: const Text('Time Limit', style: TextStyle(color: Colors.white)),
                  trailing: DropdownButton<int>(
                    value: _timeLimitMinutes,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    underline: const SizedBox(),
                    items: [1, 2, 5, 10, 15].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value min'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _timeLimitMinutes = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Vibrate', style: TextStyle(color: Colors.white)),
                  secondary: const Icon(Icons.vibration, color: Colors.deepPurpleAccent),
                  value: _vibrate,
                  onChanged: (bool value) {
                    setState(() {
                      _vibrate = value;
                    });
                  },
                ),
                const Divider(height: 1, color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.library_music, color: Colors.deepPurpleAccent),
                  title: const Text('Ringtone', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    _customRingtonePath != null ? 'Custom Audio Selected' : 'Default Alarm',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: _pickRingtone,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
