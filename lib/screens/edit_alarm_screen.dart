import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/step_alarm_settings.dart';
import '../providers/alarm_provider.dart';

class EditAlarmScreen extends StatefulWidget {
  final StepAlarmSettings? alarm;

  const EditAlarmScreen({super.key, this.alarm});

  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  late int _selectedHour;
  late int _selectedMinute;
  late TextEditingController _labelController;
  late int _requiredSteps;
  late int _timeLimitMinutes;
  late bool _vibrate;
  String? _customRingtonePath;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedHour = widget.alarm!.dateTime.hour;
      _selectedMinute = widget.alarm!.dateTime.minute;
      _labelController = TextEditingController(text: widget.alarm!.label);
      _requiredSteps = widget.alarm!.requiredSteps;
      _timeLimitMinutes = widget.alarm!.timeLimitMinutes;
      _vibrate = widget.alarm!.vibrate;
      _customRingtonePath = widget.alarm!.customRingtonePath;
    } else {
      _selectedHour = TimeOfDay.now().hour;
      _selectedMinute = TimeOfDay.now().minute;
      _labelController = TextEditingController(text: 'Wake Up!');
      _requiredSteps = 10;
      _timeLimitMinutes = 10;
      _vibrate = true;
      _customRingtonePath = null;
    }

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  Future<void> _pickRingtone() async {
    FilePickerResult? result = await FilePicker.pickFiles(
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
      _selectedHour,
      _selectedMinute,
    );

    final nowWithoutSeconds = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (dt.isBefore(nowWithoutSeconds)) {
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

  void _showLabelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _labelController.text);
        return AlertDialog(
          backgroundColor: const Color(0xFF303030),
          title: const Text('Label', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter label',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8AB4F8)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8AB4F8))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _labelController.text = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Color(0xFF8AB4F8))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.alarm == null ? 'Set alarm' : 'Edit alarm',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveAlarm,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Inline Time Picker (scrollable wheels)
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour wheel
                SizedBox(
                  width: 100,
                  child: ListWheelScrollView.useDelegate(
                    controller: _hourController,
                    itemExtent: 64,
                    perspective: 0.003,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedHour = index;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 24,
                      builder: (context, index) {
                        final isSelected = index == _selectedHour;
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: isSelected ? 56 : 36,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF8AB4F8)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Colon separator
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      color: Colors.white54,
                    ),
                  ),
                ),
                // Minute wheel
                SizedBox(
                  width: 100,
                  child: ListWheelScrollView.useDelegate(
                    controller: _minuteController,
                    itemExtent: 64,
                    perspective: 0.003,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMinute = index;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 60,
                      builder: (context, index) {
                        final isSelected = index == _selectedMinute;
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: isSelected ? 56 : 36,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),

          // --- Settings List ---

          // Required Steps
          _buildSettingTile(
            icon: Icons.directions_walk,
            title: 'Required steps',
            subtitle: '$_requiredSteps steps',
            onTap: () => _showStepsPicker(),
          ),

          Divider(height: 1, indent: 72, color: Colors.white.withOpacity(0.08)),

          // Time Limit
          _buildSettingTile(
            icon: Icons.timer_outlined,
            title: 'Time limit',
            subtitle: '$_timeLimitMinutes minutes',
            onTap: () => _showTimeLimitPicker(),
          ),

          Divider(height: 1, indent: 72, color: Colors.white.withOpacity(0.08)),

          // Alarm Sound
          _buildSettingTile(
            icon: Icons.notifications_none,
            title: 'Alarm sound',
            subtitle: _customRingtonePath != null ? 'Custom ringtone' : 'Default alarm',
            onTap: _pickRingtone,
          ),

          Divider(height: 1, indent: 72, color: Colors.white.withOpacity(0.08)),

          // Vibrate
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.vibration, color: Colors.white.withOpacity(0.7), size: 24),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vibrate',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        _vibrate ? 'On' : 'Off',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _vibrate,
                  onChanged: (value) {
                    setState(() {
                      _vibrate = value;
                    });
                  },
                  activeColor: const Color(0xFF8AB4F8),
                  activeTrackColor: const Color(0xFF8AB4F8).withOpacity(0.4),
                  inactiveThumbColor: Colors.grey.shade500,
                  inactiveTrackColor: Colors.grey.shade800,
                ),
              ],
            ),
          ),

          Divider(height: 1, indent: 72, color: Colors.white.withOpacity(0.08)),

          // Label
          _buildSettingTile(
            icon: Icons.label_outline,
            title: 'Label',
            subtitle: _labelController.text.isEmpty ? 'Add label' : _labelController.text,
            onTap: _showLabelDialog,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStepsPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF303030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Required steps',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...([10, 20, 30, 50, 100].map((steps) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _requiredSteps == steps ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _requiredSteps == steps ? const Color(0xFF8AB4F8) : Colors.white54,
                  ),
                  title: Text(
                    '$steps steps',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onTap: () {
                    setState(() {
                      _requiredSteps = steps;
                    });
                    Navigator.pop(context);
                  },
                );
              })),
            ],
          ),
        );
      },
    );
  }

  void _showTimeLimitPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF303030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time limit',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...([1, 2, 5, 10, 15].map((mins) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _timeLimitMinutes == mins ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _timeLimitMinutes == mins ? const Color(0xFF8AB4F8) : Colors.white54,
                  ),
                  title: Text(
                    '$mins minutes',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onTap: () {
                    setState(() {
                      _timeLimitMinutes = mins;
                    });
                    Navigator.pop(context);
                  },
                );
              })),
            ],
          ),
        );
      },
    );
  }
}
