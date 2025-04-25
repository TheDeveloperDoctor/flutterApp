import 'package:flutter/material.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';

class AccessLogsScreen extends StatefulWidget {
  const AccessLogsScreen({super.key});

  @override
  State<AccessLogsScreen> createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends State<AccessLogsScreen> {
  // Filter states
  DateTimeRange? _selectedDateRange;
  Set<AccessMethod> _selectedMethods = {
    AccessMethod.face,
    AccessMethod.qrCode,
    AccessMethod.remote,
  };
  Set<AccessStatus> _selectedStatuses = {
    AccessStatus.successful,
    AccessStatus.failed,
  };

  bool _showFilters = false;

  // Sample log data
  final List<AccessLog> _logs = [
    AccessLog(
      user: 'You',
      dateTime: DateTime.now().subtract(const Duration(minutes: 30)),
      method: AccessMethod.face,
      status: AccessStatus.successful,
    ),
    AccessLog(
      user: 'John Doe',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      method: AccessMethod.qrCode,
      status: AccessStatus.successful,
    ),
    AccessLog(
      user: 'Unknown',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      method: AccessMethod.face,
      status: AccessStatus.failed,
    ),
    AccessLog(
      user: 'Jane Smith',
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      method: AccessMethod.qrCode,
      status: AccessStatus.successful,
    ),
    AccessLog(
      user: 'You',
      dateTime: DateTime.now().subtract(const Duration(hours: 8)),
      method: AccessMethod.remote,
      status: AccessStatus.successful,
    ),
    AccessLog(
      user: 'Guest',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      method: AccessMethod.qrCode,
      status: AccessStatus.successful,
    ),
    AccessLog(
      user: 'Unknown',
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      method: AccessMethod.face,
      status: AccessStatus.failed,
    ),
    AccessLog(
      user: 'You',
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      method: AccessMethod.remote,
      status: AccessStatus.successful,
    ),
  ];

  List<AccessLog> get _filteredLogs {
    return _logs.where((log) {
      // Filter by date range
      if (_selectedDateRange != null) {
        if (log.dateTime.isBefore(_selectedDateRange!.start) ||
            log.dateTime.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }

      // Filter by method
      if (!_selectedMethods.contains(log.method)) {
        return false;
      }

      // Filter by status
      if (!_selectedStatuses.contains(log.status)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Access Logs', style: AppTheme.headingStyle),
            const SizedBox(height: 8),
            Text('View all door access attempts', style: AppTheme.bodyStyle),
            const SizedBox(height: 16),

            // Filter button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_filteredLogs.length} logs',
                  style: const TextStyle(color: Colors.grey),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  ),
                  label: Text(_showFilters ? 'Hide Filters' : 'Show Filters'),
                ),
              ],
            ),

            // Filters
            if (_showFilters) _buildFilters(),

            const SizedBox(height: 16),

            // Logs list
            Expanded(
              child:
                  _filteredLogs.isEmpty ? _buildEmptyState() : _buildLogsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range filter
          Text(
            'Date Range',
            style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final initialDateRange =
                  _selectedDateRange ??
                  DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 7)),
                    end: DateTime.now(),
                  );

              final pickedDateRange = await showDateRangePicker(
                context: context,
                initialDateRange: initialDateRange,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );

              if (pickedDateRange != null) {
                setState(() {
                  _selectedDateRange = pickedDateRange;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDateRange != null
                        ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                        : 'All time',
                    style: AppTheme.bodyStyle,
                  ),
                  const Icon(Icons.calendar_today_outlined),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Method filter
          Text(
            'Access Method',
            style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                AccessMethod.values.map((method) {
                  final isSelected = _selectedMethods.contains(method);
                  return FilterChip(
                    label: Text(method.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMethods.add(method);
                        } else {
                          _selectedMethods.remove(method);
                        }
                      });
                    },
                    selectedColor: method.color.withOpacity(0.2),
                    checkmarkColor: method.color,
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),

          // Status filter
          Text(
            'Status',
            style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                AccessStatus.values.map((status) {
                  final isSelected = _selectedStatuses.contains(status);
                  return FilterChip(
                    label: Text(status.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedStatuses.add(status);
                        } else {
                          _selectedStatuses.remove(status);
                        }
                      });
                    },
                    selectedColor: status.color.withOpacity(0.2),
                    checkmarkColor: status.color,
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),

          // Reset filters button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedDateRange = null;
                  _selectedMethods = AccessMethod.values.toSet();
                  _selectedStatuses = AccessStatus.values.toSet();
                });
              },
              child: const Text('Reset Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No access logs found',
              style: AppTheme.subheadingStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList() {
    return ListView.separated(
      itemCount: _filteredLogs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return _buildLogItem(log);
      },
    );
  }

  Widget _buildLogItem(AccessLog log) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            log.status == AccessStatus.successful
                ? log.method.color.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
        child: Icon(
          log.method.icon,
          color:
              log.status == AccessStatus.successful
                  ? log.method.color
                  : Colors.red,
          size: 20,
        ),
      ),
      title: Text(log.user, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        _formatDateTime(log.dateTime),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        constraints: const BoxConstraints(maxWidth: 90),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: log.status.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          log.status.label,
          style: TextStyle(
            color: log.status.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      onTap: () {
        // Show log details
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Access Details', style: AppTheme.headingStyle),
                    const SizedBox(height: 24),
                    _buildDetailRow('User', log.user),
                    const Divider(),
                    _buildDetailRow('Date', _formatDate(log.dateTime)),
                    const Divider(),
                    _buildDetailRow('Time', _formatTime(log.dateTime)),
                    const Divider(),
                    _buildDetailRow('Method', log.method.label),
                    const Divider(),
                    _buildDetailRow('Status', log.status.label),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday, ${_formatTime(dateTime)}';
    } else {
      return '${_formatDate(dateTime)}, ${_formatTime(dateTime)}';
    }
  }
}

enum AccessMethod {
  face(Icons.face_outlined, Colors.blue, 'Face Recognition'),
  qrCode(Icons.qr_code_outlined, Colors.purple, 'QR Code'),
  remote(Icons.phonelink_lock_outlined, Colors.orange, 'Remote Access');

  final IconData icon;
  final Color color;
  final String label;

  const AccessMethod(this.icon, this.color, this.label);
}

enum AccessStatus {
  successful(Colors.green, 'Successful'),
  failed(Colors.red, 'Failed');

  final Color color;
  final String label;

  const AccessStatus(this.color, this.label);
}

class AccessLog {
  final String user;
  final DateTime dateTime;
  final AccessMethod method;
  final AccessStatus status;

  AccessLog({
    required this.user,
    required this.dateTime,
    required this.method,
    required this.status,
  });
}
