import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _accent = Color(0xFF6E9BE0);

class BatterySetupScreen extends StatefulWidget {
  const BatterySetupScreen({super.key});

  @override
  State<BatterySetupScreen> createState() => _BatterySetupScreenState();
}

class _BatterySetupScreenState extends State<BatterySetupScreen> {
  String _brand = '';
  String _model = '';
  bool _batteryOptDisabled = false;
  bool _autoStartConfirmed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      _brand = info.brand.toLowerCase();
      _model = info.model;

      final status = await Permission.ignoreBatteryOptimizations.status;
      _batteryOptDisabled = status.isGranted;

      final prefs = await SharedPreferences.getInstance();
      _autoStartConfirmed = prefs.getBool('autostart_confirmed') ?? false;
    }
    setState(() => _loading = false);
  }

  Future<void> _disableBatteryOptimization() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    setState(() => _batteryOptDisabled = status.isGranted);
  }

  Future<void> _openAutoStartSettings() async {
    // Try to open manufacturer-specific autostart settings
    const platform = MethodChannel('com.example.stepalarm/settings');
    try {
      // Try common manufacturer settings intents
      final intents = _getAutoStartIntents();
      for (final intent in intents) {
        try {
          await platform.invokeMethod('openIntent', intent);
          break;
        } catch (_) {
          continue;
        }
      }
    } catch (_) {
      // Fallback: open general app settings
      await openAppSettings();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autostart_confirmed', true);
    setState(() => _autoStartConfirmed = true);
  }

  Future<void> _openAppBatterySettings() async {
    // Opens the app's specific battery settings page
    await openAppSettings();
  }

  List<Map<String, String>> _getAutoStartIntents() {
    switch (_brand) {
      case 'xiaomi':
      case 'redmi':
      case 'poco':
        return [
          {'package': 'com.miui.securitycenter', 'class': 'com.miui.permcenter.autostart.AutoStartManagementActivity'},
        ];
      case 'oppo':
      case 'realme':
        return [
          {'package': 'com.coloros.safecenter', 'class': 'com.coloros.safecenter.permission.startup.StartupAppListActivity'},
        ];
      case 'vivo':
        return [
          {'package': 'com.iqoo.secure', 'class': 'com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity'},
        ];
      case 'huawei':
      case 'honor':
        return [
          {'package': 'com.huawei.systemmanager', 'class': 'com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity'},
        ];
      default:
        return [];
    }
  }

  bool get _needsAutoStart =>
      ['xiaomi', 'redmi', 'poco', 'oppo', 'realme', 'vivo', 'oneplus',
       'huawei', 'honor', 'samsung', 'asus', 'tecno', 'infinix', 'itel']
          .contains(_brand);

  List<String> _getDeviceTips() {
    switch (_brand) {
      case 'xiaomi':
      case 'redmi':
      case 'poco':
        return [
          'Settings → Apps → Step Alarm → Battery Saver → No restrictions',
          'Settings → Apps → Step Alarm → Autostart → Enable',
          'Lock the app in Recents (swipe down on the app card)',
          'Settings → Battery → Ultra battery saver → disable',
        ];
      case 'samsung':
        return [
          'Settings → Apps → Step Alarm → Battery → Unrestricted',
          'Settings → Device care → Battery → Background usage limits → Never sleeping apps → Add Step Alarm',
          'Lock the app in Recents (long press → Lock)',
        ];
      case 'oppo':
      case 'realme':
        return [
          'Settings → Battery → More settings → Optimize battery use → Step Alarm → Don\'t optimize',
          'Settings → App management → Step Alarm → Auto launch → Allow',
          'Lock the app in Recents (swipe down on the app card)',
        ];
      case 'oneplus':
        return [
          'Settings → Battery → Battery optimization → Step Alarm → Don\'t optimize',
          'Settings → Apps → Step Alarm → Advanced → Battery optimization → Not optimized',
        ];
      case 'vivo':
        return [
          'Settings → Battery → Background power consumption management → Step Alarm → Allow',
          'i Manager → App manager → Autostart manager → Step Alarm → Enable',
        ];
      case 'huawei':
      case 'honor':
        return [
          'Settings → Battery → App launch → Step Alarm → Manage manually → Enable all toggles',
          'Settings → Apps → Step Alarm → Battery → Unrestricted',
        ];
      default:
        return [
          'Settings → Battery → Battery optimization → Step Alarm → Don\'t optimize',
          'Settings → Apps → Step Alarm → Battery → Unrestricted',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alarm Setup',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Status header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _batteryOptDisabled
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _batteryOptDisabled
                          ? Colors.green.withOpacity(0.3)
                          : Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _batteryOptDisabled ? Icons.check_circle : Icons.warning_amber_rounded,
                        color: _batteryOptDisabled ? Colors.green : Colors.redAccent,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _batteryOptDisabled
                                  ? 'Battery optimization disabled'
                                  : 'Battery optimization is ON',
                              style: TextStyle(
                                color: _batteryOptDisabled ? Colors.green : Colors.redAccent,
                                fontSize: 16, fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _batteryOptDisabled
                                  ? 'Alarms should fire reliably overnight.'
                                  : 'Android will kill the app overnight. Alarms will NOT fire.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6), fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Device info
                if (_brand.isNotEmpty)
                  Text(
                    'Detected: ${_brand.toUpperCase()} $_model',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  ),
                const SizedBox(height: 24),

                // Step 1: Battery Optimization
                _buildStep(
                  number: 1,
                  title: 'Disable Battery Optimization',
                  subtitle: 'Prevents Android from killing the alarm process.',
                  done: _batteryOptDisabled,
                  buttonText: _batteryOptDisabled ? 'Done ✓' : 'Open Settings',
                  onTap: _batteryOptDisabled ? null : _disableBatteryOptimization,
                ),

                const SizedBox(height: 16),

                // Step 2: App Battery Settings (manual)
                _buildStep(
                  number: 2,
                  title: 'Set Battery to Unrestricted',
                  subtitle: 'Open app settings and set battery to "Unrestricted" or "No restrictions".',
                  done: false,
                  buttonText: 'Open App Settings',
                  onTap: _openAppBatterySettings,
                ),

                const SizedBox(height: 16),

                // Step 3: Auto Start (OEM specific)
                if (_needsAutoStart) ...[
                  _buildStep(
                    number: 3,
                    title: 'Enable Auto Start',
                    subtitle: 'Required for ${_brand.toUpperCase()} devices to allow background alarms.',
                    done: _autoStartConfirmed,
                    buttonText: _autoStartConfirmed ? 'Done ✓' : 'Open Settings',
                    onTap: _autoStartConfirmed ? null : () async {
                      await openAppSettings();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('autostart_confirmed', true);
                      setState(() => _autoStartConfirmed = true);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),

                // Device-specific tips
                const Text(
                  'Manual Steps (Recommended)',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'These settings ensure maximum alarm reliability:',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                ),
                const SizedBox(height: 16),

                ..._getDeviceTips().asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accent.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text('${entry.key + 1}',
                                style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _accent.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: _accent.withOpacity(0.7), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Most alarm failures are caused by aggressive battery optimization. '
                          'Apps like Alarmy and Google Clock have special system privileges. '
                          'Following the steps above gives Step Alarm the same reliability.',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String subtitle,
    required bool done,
    required String buttonText,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? Colors.green : _accent,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('$number', style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: done ? Colors.green.withOpacity(0.2) : _accent,
                  foregroundColor: done ? Colors.green : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
