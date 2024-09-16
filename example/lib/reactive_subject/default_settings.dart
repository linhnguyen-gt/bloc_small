import 'package:bloc_small/reactive_subject.dart';
import 'package:flutter/material.dart';

class DefaultSettings extends StatefulWidget {
  @override
  _DefaultSettingsState createState() => _DefaultSettingsState();
}

class _DefaultSettingsState extends State<DefaultSettings> {
  final ReactiveSubject<Map<String, dynamic>> _settingsSubject =
      ReactiveSubject<Map<String, dynamic>>();
  late ReactiveSubject<Map<String, dynamic>> _settingsWithDefaults;

  @override
  void initState() {
    super.initState();
    // Start with default settings
    _settingsWithDefaults = _settingsSubject.startWith({
      'theme': 'light',
      'notifications': true,
    });
  }

  @override
  void dispose() {
    _settingsSubject.dispose();
    _settingsWithDefaults.dispose();
    super.dispose();
  }

  void _updateSettings(String key, dynamic value) {
    final currentSettings = _settingsWithDefaults.value;
    _settingsSubject.add({...currentSettings, key: value});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _settingsWithDefaults.stream,
      builder: (context, snapshot) {
        final settings = snapshot.data ?? {};
        return Column(
          children: [
            SwitchListTile(
              title: Text('Dark Theme'),
              value: settings['theme'] == 'dark',
              onChanged: (bool value) {
                _updateSettings('theme', value ? 'dark' : 'light');
              },
            ),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: settings['notifications'] ?? true,
              onChanged: (bool value) {
                _updateSettings('notifications', value);
              },
            ),
          ],
        );
      },
    );
  }
}
