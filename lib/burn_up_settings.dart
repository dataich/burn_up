import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class BurnUpSettings extends StatelessWidget {
  const BurnUpSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
        children: [
          TextInputSettingsTile(
            title: 'Backlog API Key',
            settingKey: 'apiKey',
            obscureText: true,
            validator: (String? apiKey) {
              if (apiKey?.isNotEmpty == true) {
                return null;
              }
              return "Please input your Backlog API Key";
            },
          ),
          TextInputSettingsTile(
            title: 'Backlog Domain (e.g. example.backlog.com)',
            settingKey: 'domain',
            validator: (String? domain) {
              if (domain?.isNotEmpty == true) {
                return null;
              }
              return "Please input your Backlog Domain";
            },
          ),
          TextInputSettingsTile(
            title: 'Backlog Project Key (e.g EXAMPLE)',
            settingKey: 'projectKey',
            validator: (String? projectKey) {
              if (projectKey?.isNotEmpty == true) {
                return null;
              }
              return "Please input your Backlog Issue Type Name";
            },
          ),
          TextInputSettingsTile(
            title: 'Backlog Milestone Prefix (e.g Season 1)',
            settingKey: 'milestonePrefix',
            validator: (String? milestonePrefix) {
              if (milestonePrefix?.isNotEmpty == true) {
                return null;
              }
              return "Please input your Backlog Milestone Prefix";
            },
          ),
          TextInputSettingsTile(
            title: 'Backlog Issue Type Name (e.g Task)',
            settingKey: 'issueTypeName',
            validator: (String? issueTypeName) {
              if (issueTypeName?.isNotEmpty == true) {
                return null;
              }
              return "Please input your Backlog Issue Type Name";
            },
          ),
        ],
      );
  }
}
