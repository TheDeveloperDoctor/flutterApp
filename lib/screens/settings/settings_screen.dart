import 'package:flutter/material.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _autoLockEnabled = true;
  int _autoLockDelay = 30; // seconds
  bool _biometricAuthEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Settings', style: AppTheme.headingStyle),
            const SizedBox(height: 8),
            Text(
              'Configure your smart lock preferences',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 24),

            // Account section
            _buildSectionHeader('Account'),
            _buildAccountSection(),

            const SizedBox(height: 24),

            // Notifications section
            _buildSectionHeader('Notifications'),
            _buildNotificationsSection(),

            const SizedBox(height: 24),

            // Security section
            _buildSectionHeader('Security'),
            _buildSecuritySection(),

            const SizedBox(height: 24),

            // Device section
            _buildSectionHeader('Device'),
            _buildDeviceSection(),

            const SizedBox(height: 24),

            // About section
            _buildSectionHeader('About'),
            _buildAboutSection(),

            const SizedBox(height: 24),

            // Sign out button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show sign out confirmation
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                            'Are you sure you want to sign out?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle sign out
                                Navigator.pop(context);
                              },
                              child: const Text('Sign Out'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),

            const SizedBox(height: 16),

            // App version
            const Center(
              child: Text(
                'Smart Lock Pro v1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: AppTheme.subheadingStyle),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            subtitle: const Text('John Doe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to profile screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: const Text('john.doe@example.com'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to email settings
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.password_outlined),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to change password screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for important events'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications_outlined),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound for notifications'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
            secondary: const Icon(Icons.volume_up_outlined),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notification Preferences'),
            subtitle: const Text(
              'Configure which events trigger notifications',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to notification preferences
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Auto-Lock'),
            subtitle: const Text('Automatically lock the door after opening'),
            value: _autoLockEnabled,
            onChanged: (value) {
              setState(() {
                _autoLockEnabled = value;
              });
            },
            secondary: const Icon(Icons.lock_clock_outlined),
          ),
          if (_autoLockEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Text('Delay: '),
                  Expanded(
                    child: Slider(
                      value: _autoLockDelay.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '$_autoLockDelay seconds',
                      onChanged: (value) {
                        setState(() {
                          _autoLockDelay = value.round();
                        });
                      },
                    ),
                  ),
                  Text('$_autoLockDelay sec'),
                ],
              ),
            ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID for app access'),
            value: _biometricAuthEnabled,
            onChanged: (value) {
              setState(() {
                _biometricAuthEnabled = value;
              });
            },
            secondary: const Icon(Icons.fingerprint),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Security Log'),
            subtitle: const Text('View security-related events'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to security log
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.door_front_door_outlined),
            title: const Text('Smart Lock'),
            subtitle: const Text('Front Door • Connected'),
            trailing: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              // Navigate to device details
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.battery_charging_full_outlined),
            title: const Text('Battery'),
            subtitle: const Text('85% • Estimated 45 days remaining'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to battery details
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.wifi_outlined),
            title: const Text('Network'),
            subtitle: const Text('Connected • Strong signal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to network settings
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.update_outlined),
            title: const Text('Firmware Update'),
            subtitle: const Text('Version 2.1.3 • Up to date'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Check for updates
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to help & support
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to terms of service
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show about dialog
              showAboutDialog(
                context: context,
                applicationName: 'Smart Lock Pro',
                applicationVersion: 'v1.0.0',
                applicationIcon: const Icon(
                  Icons.door_front_door_outlined,
                  size: 50,
                  color: AppTheme.primaryColor,
                ),
                applicationLegalese:
                    '© 2023 Smart Lock Pro. All rights reserved.',
              );
            },
          ),
        ],
      ),
    );
  }
}
