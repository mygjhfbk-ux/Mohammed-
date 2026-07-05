import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات')),
      body: ListView(
        children: [
          ListTile(title: Text('لغة الواجهة'), subtitle: Text('العربية')),
          ListTile(title: Text('عن التطبيق')),
        ],
      ),
    );
  }
}
