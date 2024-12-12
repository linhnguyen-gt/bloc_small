import 'package:bloc_small/bloc.dart';
import 'package:flutter/material.dart';

import '../drawer/menu_drawer.dart';

class DefaultSettings extends StatefulWidget {
  static const String route = '/default_settings';

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
      initialData: _settingsWithDefaults.value,
      builder: (context, snapshot) {
        final settings = snapshot.data ?? {};

        // Determine the theme
        final isDarkTheme = settings['theme'] == 'dark';
        final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
        final textColor = isDarkTheme ? Colors.white : Colors.black;

        return Scaffold(
          drawer: const MenuDrawer(DefaultSettings.route),
          appBar: AppBar(
            title: Text("Default Settings", style: TextStyle(color: textColor)),
            backgroundColor: backgroundColor, // Optional: Change AppBar color
          ),
          backgroundColor: backgroundColor,
          body: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Dark Theme',
                  style: TextStyle(color: textColor),
                ),
                value: isDarkTheme,
                onChanged: (bool value) {
                  _updateSettings('theme', value ? 'dark' : 'light');
                },
              ),
              SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: TextStyle(color: textColor),
                ),
                value: settings['notifications'] ?? true,
                onChanged: (bool value) {
                  _updateSettings('notifications', value);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notifications Enabled'
                            : 'Notifications Disabled',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 16.0, // Text size
                        ),
                      ),
                      backgroundColor: Colors.blueGrey,
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: Colors.yellow,
                        onPressed: () {
                          _updateSettings('notifications', !value);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
