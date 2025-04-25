import 'package:flutter/material.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - in a real app, this would come from a backend
    final activities = [
      ActivityItem(
        user: 'You',
        time: '10:30 AM',
        method: AccessMethod.face,
        isSuccessful: true,
      ),
      ActivityItem(
        user: 'John Doe',
        time: '09:15 AM',
        method: AccessMethod.qrCode,
        isSuccessful: true,
      ),
      ActivityItem(
        user: 'Unknown',
        time: '08:45 AM',
        method: AccessMethod.face,
        isSuccessful: false,
      ),
      ActivityItem(
        user: 'You',
        time: 'Yesterday, 11:20 PM',
        method: AccessMethod.remote,
        isSuccessful: true,
      ),
    ];

    return Container(
      decoration: AppTheme.cardDecoration,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  activity.isSuccessful
                      ? activity.method.color.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
              child: Icon(
                activity.method.icon,
                color:
                    activity.isSuccessful ? activity.method.color : Colors.red,
                size: 20,
              ),
            ),
            title: Text(activity.user),
            subtitle: Text(activity.time),
            trailing: Text(
              activity.isSuccessful ? 'Success' : 'Failed',
              style: TextStyle(
                color: activity.isSuccessful ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ActivityItem {
  final String user;
  final String time;
  final AccessMethod method;
  final bool isSuccessful;

  ActivityItem({
    required this.user,
    required this.time,
    required this.method,
    required this.isSuccessful,
  });
}

enum AccessMethod {
  face(Icons.face_outlined, Colors.blue),
  qrCode(Icons.qr_code_outlined, Colors.purple),
  remote(Icons.phonelink_lock_outlined, Colors.orange);

  final IconData icon;
  final Color color;

  const AccessMethod(this.icon, this.color);
}
