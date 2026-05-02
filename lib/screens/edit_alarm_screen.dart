import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/step_alarm_settings.dart';
import '../providers/alarm_provider.dart';

const Color kAccent = Color(0xFF6E9BE0);

class EditAlarmScreen extends StatefulWidget {
  final StepAlarmSettings? alarm;
  const EditAlarmScreen({super.key, this.alarm});
  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  late int _hour, _minute, _requiredSteps, _timeLimitMinutes;
  late bool _vibrate, _isHourMode;
  late TextEditingController _labelCtrl;
  String? _ringtonePath;

  @override
  void initState() {
    super.initState();
    final a = widget.alarm;
    _hour = a?.dateTime.hour ?? TimeOfDay.now().hour;
    _minute = a?.dateTime.minute ?? TimeOfDay.now().minute;
    _labelCtrl = TextEditingController(text: a?.label ?? 'Wake Up!');
    _requiredSteps = a?.requiredSteps ?? 10;
    _timeLimitMinutes = a?.timeLimitMinutes ?? 10;
    _vibrate = a?.vibrate ?? true;
    _ringtonePath = a?.customRingtonePath;
    _isHourMode = true;
  }

  @override
  void dispose() { _labelCtrl.dispose(); super.dispose(); }

  void _save() {
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, _hour, _minute);
    final nowNoSec = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (dt.isBefore(nowNoSec)) dt = dt.add(const Duration(days: 1));

    final alarm = StepAlarmSettings(
      id: widget.alarm?.id ?? dt.millisecondsSinceEpoch.remainder(100000),
      dateTime: dt,
      label: _labelCtrl.text.trim().isEmpty ? 'Alarm' : _labelCtrl.text.trim(),
      requiredSteps: _requiredSteps, timeLimitMinutes: _timeLimitMinutes,
      vibrate: _vibrate, customRingtonePath: _ringtonePath, isEnabled: true,
    );
    final p = context.read<AlarmProvider>();
    widget.alarm == null ? p.addAlarm(alarm) : p.updateAlarm(alarm);
    Navigator.pop(context);
  }

  void _onDialSelect(double dx, double dy, double size) {
    final cx = size / 2, cy = size / 2;
    final angle = (atan2(dy - cy, dx - cx) * 180 / pi + 90 + 360) % 360;
    if (_isHourMode) {
      final dist = sqrt(pow(dx - cx, 2) + pow(dy - cy, 2));
      final pos = (angle / 30).round() % 12;
      final isInner = dist < size * 0.32;
      setState(() {
        _hour = isInner ? (pos == 0 ? 0 : pos + 12) : (pos == 0 ? 12 : pos);
        _isHourMode = false; // auto-switch to minutes
      });
    } else {
      setState(() => _minute = (angle / 6).round() % 60);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = _hour.toString().padLeft(2, '0');
    final m = _minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(widget.alarm == null ? 'Set alarm' : 'Edit alarm',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
        centerTitle: false,
        actions: [IconButton(icon: const Icon(Icons.check, color: Colors.white), onPressed: _save)],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // Time display — tap hours or minutes to switch mode
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isHourMode = true),
                child: Text(h, style: TextStyle(fontSize: 64, fontWeight: FontWeight.w400,
                    color: _isHourMode ? kAccent : Colors.white54)),
              ),
              const Text(':', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: Colors.white38)),
              GestureDetector(
                onTap: () => setState(() => _isHourMode = false),
                child: Text(m, style: TextStyle(fontSize: 64, fontWeight: FontWeight.w400,
                    color: !_isHourMode ? kAccent : Colors.white54)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Inline clock dial
          Center(child: _buildDial()),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          // Steps
          _buildStepsRow(),
          Divider(height: 1, indent: 72, color: Colors.white.withOpacity(0.08)),
          // Time limit
          _settingTile(Icons.timer_outlined, 'Time limit', '$_timeLimitMinutes minutes', _showTimeLimitPicker),
          Divider(height: 1, indent: 72, color: Colors.white.withOpacity(0.08)),
          // Sound
          _settingTile(Icons.notifications_none, 'Alarm sound',
              _ringtonePath != null ? 'Custom ringtone' : 'Default alarm', _pickRingtone),
          Divider(height: 1, indent: 72, color: Colors.white.withOpacity(0.08)),
          // Vibrate
          _buildVibrateRow(),
          Divider(height: 1, indent: 72, color: Colors.white.withOpacity(0.08)),
          // Label
          _settingTile(Icons.label_outline, 'Label',
              _labelCtrl.text.isEmpty ? 'Add label' : _labelCtrl.text, _showLabelDialog),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDial() {
    const double size = 260;
    const double outerR = 105, innerR = 68;
    return GestureDetector(
      onPanUpdate: (d) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        _onDialSelect(d.localPosition.dx, d.localPosition.dy, size);
      },
      onTapDown: (d) => _onDialSelect(d.localPosition.dx, d.localPosition.dy, size),
      child: SizedBox(
        width: size, height: size,
        child: CustomPaint(
          painter: _DialPainter(
            hour: _hour, minute: _minute, isHourMode: _isHourMode,
            outerR: outerR, innerR: innerR,
          ),
          child: Stack(children: _buildNumbers(size, outerR, innerR)),
        ),
      ),
    );
  }

  List<Widget> _buildNumbers(double size, double outerR, double innerR) {
    final cx = size / 2, cy = size / 2;
    List<Widget> widgets = [];
    if (_isHourMode) {
      // Outer: 12, 1..11
      for (int i = 0; i < 12; i++) {
        final hr = i == 0 ? 12 : i;
        final a = (i * 30 - 90) * pi / 180;
        final selected = hr == _hour;
        widgets.add(_numAt(cx + outerR * cos(a), cy + outerR * sin(a), '$hr', selected, 16));
      }
      // Inner: 0(00), 13..23
      for (int i = 0; i < 12; i++) {
        final hr = i == 0 ? 0 : i + 12;
        final a = (i * 30 - 90) * pi / 180;
        final selected = hr == _hour;
        widgets.add(_numAt(cx + innerR * cos(a), cy + innerR * sin(a),
            hr == 0 ? '00' : '$hr', selected, 13));
      }
    } else {
      // Minutes: 00,05,10...55
      for (int i = 0; i < 12; i++) {
        final min = i * 5;
        final a = (i * 30 - 90) * pi / 180;
        final selected = min == _minute;
        widgets.add(_numAt(cx + outerR * cos(a), cy + outerR * sin(a),
            min.toString().padLeft(2, '0'), selected, 16));
      }
    }
    return widgets;
  }

  Widget _numAt(double x, double y, String text, bool selected, double fontSize) {
    return Positioned(
      left: x - 18, top: y - 18,
      child: Container(
        width: 36, height: 36, alignment: Alignment.center,
        decoration: selected ? const BoxDecoration(shape: BoxShape.circle, color: kAccent) : null,
        child: Text(text, style: TextStyle(
          fontSize: fontSize, color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _buildStepsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(children: [
        Icon(Icons.directions_walk, color: Colors.white.withOpacity(0.7), size: 24),
        const SizedBox(width: 24),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Required steps', style: TextStyle(color: Colors.white, fontSize: 16)),
          Text('$_requiredSteps steps', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ])),
        IconButton(
          onPressed: _requiredSteps > 10 ? () => setState(() => _requiredSteps -= 10) : null,
          icon: Icon(Icons.remove_circle_outline, size: 28,
              color: _requiredSteps > 10 ? kAccent : Colors.white.withOpacity(0.15)),
        ),
        SizedBox(width: 40, child: Text('$_requiredSteps', textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500))),
        IconButton(
          onPressed: _requiredSteps < 100 ? () => setState(() => _requiredSteps += 10) : null,
          icon: Icon(Icons.add_circle_outline, size: 28,
              color: _requiredSteps < 100 ? kAccent : Colors.white.withOpacity(0.15)),
        ),
      ]),
    );
  }

  Widget _buildVibrateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(children: [
        Icon(Icons.vibration, color: Colors.white.withOpacity(0.7), size: 24),
        const SizedBox(width: 24),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Vibrate', style: TextStyle(color: Colors.white, fontSize: 16)),
          Text(_vibrate ? 'On' : 'Off', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ])),
        Switch(value: _vibrate, onChanged: (v) => setState(() => _vibrate = v),
          activeColor: kAccent, activeTrackColor: kAccent.withOpacity(0.4),
          inactiveThumbColor: Colors.grey.shade500, inactiveTrackColor: Colors.grey.shade800),
      ]),
    );
  }

  Widget _settingTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
        const SizedBox(width: 24),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ])),
      ]),
    ));
  }

  Future<void> _pickRingtone() async {
    final r = await FilePicker.pickFiles(type: FileType.audio);
    if (r != null && r.files.single.path != null) setState(() => _ringtonePath = r.files.single.path);
  }

  void _showLabelDialog() {
    showDialog(context: context, builder: (ctx) {
      final c = TextEditingController(text: _labelCtrl.text);
      return AlertDialog(
        backgroundColor: const Color(0xFF303030),
        title: const Text('Label', style: TextStyle(color: Colors.white)),
        content: TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'Enter label', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kAccent)))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: kAccent))),
          TextButton(onPressed: () { setState(() => _labelCtrl.text = c.text); Navigator.pop(ctx); },
              child: const Text('OK', style: TextStyle(color: kAccent))),
        ],
      );
    });
  }

  void _showTimeLimitPicker() {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF303030),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Time limit', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ...[1, 2, 5, 10, 15].map((m) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_timeLimitMinutes == m ? Icons.radio_button_checked : Icons.radio_button_off,
                color: _timeLimitMinutes == m ? kAccent : Colors.white54),
            title: Text('$m minutes', style: const TextStyle(color: Colors.white, fontSize: 16)),
            onTap: () { setState(() => _timeLimitMinutes = m); Navigator.pop(ctx); },
          )),
        ],
      )),
    );
  }
}

class _DialPainter extends CustomPainter {
  final int hour, minute;
  final bool isHourMode;
  final double outerR, innerR;

  _DialPainter({required this.hour, required this.minute,
    required this.isHourMode, required this.outerR, required this.innerR});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final center = Offset(cx, cy);

    // Background circle
    canvas.drawCircle(center, size.width / 2, Paint()..color = const Color(0xFF3C3C3C));

    // Hand line
    double angle;
    double radius;
    if (isHourMode) {
      final pos = hour % 12;
      angle = (pos * 30 - 90) * pi / 180;
      radius = (hour == 0 || hour > 12) ? innerR : outerR;
    } else {
      angle = (minute * 6 - 90) * pi / 180;
      radius = outerR;
    }

    final handEnd = Offset(cx + radius * cos(angle), cy + radius * sin(angle));
    canvas.drawLine(center, handEnd, Paint()..color = kAccent..strokeWidth = 2);

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = kAccent);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.hour != hour || old.minute != minute || old.isHourMode != isHourMode;
}
