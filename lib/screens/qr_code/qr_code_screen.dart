import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:path_provider/path_provider.dart';
// import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _nameController = TextEditingController();
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 1));
  AccessType _selectedAccessType = AccessType.limited;

  // List of active QR codes
  final List<QRCode> _activeCodes = [
    QRCode(
      name: 'Cleaning Service',
      type: AccessType.limited,
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
      expirationDate: DateTime.now().add(const Duration(days: 7)),
    ),
    QRCode(
      name: 'Guest Access',
      type: AccessType.oneTime,
      createdDate: DateTime.now().subtract(const Duration(hours: 2)),
      expirationDate: DateTime.now().add(const Duration(days: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Generate QR'),
              Tab(text: 'Manage QR Codes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildGenerateQRTab(), _buildManageQRTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateQRTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generate QR Code', style: AppTheme.headingStyle),
          const SizedBox(height: 8),
          Text(
            'Create a QR code to grant temporary access',
            style: AppTheme.bodyStyle,
          ),
          const SizedBox(height: 24),

          // Form
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name/Purpose',
              hintText: 'e.g., Cleaning Service, Guest Access',
            ),
          ),
          const SizedBox(height: 16),

          // Access type selection
          Text(
            'Access Type',
            style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildAccessTypeCard(
                  title: 'One-Time',
                  description: 'Single use access',
                  type: AccessType.oneTime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAccessTypeCard(
                  title: 'Limited Time',
                  description: 'Access until expiration',
                  type: AccessType.limited,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAccessTypeCard(
                  title: 'Permanent',
                  description: 'Unlimited access',
                  type: AccessType.permanent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Expiration date picker (only for limited time access)
          if (_selectedAccessType == AccessType.limited)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expiration Date',
                  style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _expirationDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _expirationDate = pickedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}',
                          style: AppTheme.bodyStyle,
                        ),
                        const Icon(Icons.calendar_today_outlined),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a name or purpose'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // In a real app, this would generate a QR code
                setState(() {
                  _activeCodes.add(
                    QRCode(
                      name: _nameController.text,
                      type: _selectedAccessType,
                      createdDate: DateTime.now(),
                      expirationDate:
                          _selectedAccessType == AccessType.limited
                              ? _expirationDate
                              : null,
                    ),
                  );

                  // Show the QR code
                  _showGeneratedQRCode(_nameController.text);

                  // Reset form
                  _nameController.clear();
                });
              },
              child: const Text('Generate QR Code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessTypeCard({
    required String title,
    required String description,
    required AccessType type,
  }) {
    final isSelected = _selectedAccessType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccessType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryColor : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showGeneratedQRCode(String name) {
    // Generate a unique code for this QR code
    final String qrData =
        'SMARTLOCK:${DateTime.now().millisecondsSinceEpoch}:$name:${_selectedAccessType.toString().split('.').last}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Text('QR Code Generated', style: AppTheme.headingStyle),
              const SizedBox(height: 8),
              Text(name, style: AppTheme.subheadingStyle),
              const SizedBox(height: 24),

              // QR Code with actual QR generation
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    errorStateBuilder: (context, error) {
                      return const Center(
                        child: Text(
                          'Error generating QR code',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Access details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Type',
                      _selectedAccessType.toString().split('.').last,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedAccessType == AccessType.limited)
                      _buildDetailRow(
                        'Expires',
                        '${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}',
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Share button with actual sharing functionality
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      // Share the QR code
                      await Share.share(
                        'Here is your access QR code for $name: $qrData',
                        subject: 'Smart Lock Access QR Code',
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('QR Code shared')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error sharing: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share QR Code'),
                ),
              ),

              const SizedBox(height: 16),

              // Share options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: Icons.message,
                    label: 'SMS',
                    onTap: () {
                      _shareViaSMS(qrData, name);
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.share,
                    label: 'WhatsApp',
                    onTap: () {
                      _shareViaWhatsApp(qrData, name);
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.email,
                    label: 'Email',
                    onTap: () {
                      _shareViaEmail(qrData, name);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Close button
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
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _shareViaSMS(String qrData, String name) async {
    final String message = 'Here is your access QR code for $name: $qrData';
    final Uri smsUri = Uri(scheme: 'sms', queryParameters: {'body': message});

    try {
      if (await canLaunch(smsUri.toString())) {
        await launch(smsUri.toString());
      } else {
        // Fall back to general share
        await Share.share(message);
      }
    } catch (e) {
      // Fall back to general share
      await Share.share(message);
    }
  }

  void _shareViaWhatsApp(String qrData, String name) async {
    final String message = 'Here is your access QR code for $name: $qrData';
    final String whatsappUrl =
        "whatsapp://send?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        // Fall back to general share
        await Share.share(message);
      }
    } catch (e) {
      // Fall back to general share
      await Share.share(message);
    }
  }

  void _shareViaEmail(String qrData, String name) async {
    final String subject = 'Smart Lock Access QR Code';
    final String body = 'Here is your access QR code for $name: $qrData';
    final String emailUrl =
        'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    try {
      if (await canLaunch(emailUrl)) {
        await launch(emailUrl);
      } else {
        // Fall back to general share
        await Share.share(body, subject: subject);
      }
    } catch (e) {
      // Fall back to general share
      await Share.share(body, subject: subject);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildManageQRTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage QR Codes', style: AppTheme.headingStyle),
          const SizedBox(height: 8),
          Text('View and manage active QR codes', style: AppTheme.bodyStyle),
          const SizedBox(height: 24),

          Expanded(
            child:
                _activeCodes.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                      itemCount: _activeCodes.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final qrCode = _activeCodes[index];
                        return _buildQRCodeItem(qrCode);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No QR codes generated yet', style: AppTheme.subheadingStyle),
          const SizedBox(height: 8),
          Text(
            'Generate a QR code to grant temporary access',
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _tabController.animateTo(0);
            },
            child: const Text('Generate QR Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeItem(QRCode qrCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qrCode.name,
                      style: AppTheme.subheadingStyle.copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created: ${_formatDate(qrCode.createdDate)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildAccessTypeBadge(qrCode.type),
            ],
          ),
          const SizedBox(height: 16),

          // Expiration info
          if (qrCode.type == AccessType.limited &&
              qrCode.expirationDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Expires: ${_formatDate(qrCode.expirationDate!)}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Generate QR data
                  final String qrData =
                      'SMARTLOCK:${qrCode.createdDate.millisecondsSinceEpoch}:${qrCode.name}:${qrCode.type.toString().split('.').last}';

                  // Show QR code in dialog
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(qrCode.name),
                          content: SizedBox(
                            width: 250,
                            height: 250,
                            child: QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 220,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await Share.share(
                                  'Here is your access QR code for ${qrCode.name}: $qrData',
                                  subject: 'Smart Lock Access QR Code',
                                );
                              },
                              child: const Text('Share'),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('View'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  // Revoke QR code
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Revoke QR Code'),
                          content: Text(
                            'Are you sure you want to revoke access for "${qrCode.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _activeCodes.remove(qrCode);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Revoke'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Revoke'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccessTypeBadge(AccessType type) {
    Color color;
    String label;

    switch (type) {
      case AccessType.oneTime:
        color = Colors.blue;
        label = 'One-Time';
        break;
      case AccessType.limited:
        color = Colors.orange;
        label = 'Limited';
        break;
      case AccessType.permanent:
        color = Colors.green;
        label = 'Permanent';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum AccessType { oneTime, limited, permanent }

class QRCode {
  final String name;
  final AccessType type;
  final DateTime createdDate;
  final DateTime? expirationDate;

  QRCode({
    required this.name,
    required this.type,
    required this.createdDate,
    this.expirationDate,
  });
}
