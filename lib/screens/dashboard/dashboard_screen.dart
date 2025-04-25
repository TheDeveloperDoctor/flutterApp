import 'package:flutter/material.dart';
import 'package:smart_lock_pro/screens/face_recognition/face_recognition_screen.dart';
import 'package:smart_lock_pro/screens/qr_code/qr_code_screen.dart';
import 'package:smart_lock_pro/screens/access_logs/access_logs_screen.dart';
import 'package:smart_lock_pro/screens/settings/settings_screen.dart';
import 'package:smart_lock_pro/screens/monitoring/live_monitoring_screen.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';
import 'package:smart_lock_pro/widgets/dashboard/door_status_card.dart';
import 'package:smart_lock_pro/widgets/dashboard/stats_card.dart';
import 'package:smart_lock_pro/widgets/dashboard/recent_activity_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Screen titles for AppBar
  final List<String> _screenTitles = [
    'Dashboard',
    'Face Recognition',
    'QR Code Access',
    'Live Monitoring',
    'Access Logs',
    'Settings',
  ];

  // Navigation items with icons and labels
  final List<NavigationItem> _navigationItems = [
    NavigationItem(Icons.dashboard_outlined, 'Dashboard'),
    NavigationItem(Icons.face_outlined, 'Face'),
    NavigationItem(Icons.qr_code_outlined, 'QR Code'),
    NavigationItem(Icons.videocam_outlined, 'Monitor'),
    NavigationItem(Icons.history_outlined, 'Logs'),
    NavigationItem(Icons.settings_outlined, 'Settings'),
  ];

  // Screen content
  final List<Widget> _screens = [
    const DashboardContent(),
    const FaceRecognitionScreen(),
    const QRCodeScreen(),
    const LiveMonitoringScreen(),
    const AccessLogsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Improved responsive breakpoints
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final bool isMediumScreen = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      key: _scaffoldKey,
      // Removing the AppBar
      appBar: null,
      drawer: !isSmallScreen ? null : _buildDrawer(),
      // For large screens, use a side navigation with content side by side
      body: isLargeScreen
          ? Row(
              children: [
                // Permanent drawer for large screens
                SizedBox(
                  width: 250,
                  child: _buildDrawer(isPermanent: true),
                ),
                // Main content area
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            )
          : _screens[_selectedIndex],
      // Show bottom navigation only on small screens
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Colors.grey,
              items: _navigationItems
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            )
          : null,
    );
  }

  Widget _buildDrawer({bool isPermanent = false}) {
    return Drawer(
      elevation: isPermanent ? 0 : 16,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.door_front_door_outlined,
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Smart Lock Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: _selectedIndex == index
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                  title: Text(
                    _screenTitles[index],
                    style: TextStyle(
                      color: _selectedIndex == index
                          ? AppTheme.primaryColor
                          : Colors.black,
                      fontWeight: _selectedIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: _selectedIndex == index,
                  onTap: () {
                    _onItemTapped(index);
                    if (!isPermanent) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.red),
            title: const Text('Sign Out'),
            onTap: () {
              // Handle sign out
              if (!isPermanent) {
                Navigator.pop(context);
              }
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to sign in screen
                        // In a real app, you would handle authentication here
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
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Helper class for navigation items
class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem(this.icon, this.label);
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // More granular responsive breakpoints
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final bool isLargeScreen = screenWidth >= 900;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // In a real app, you would refresh data from a backend here
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: isLargeScreen
              ? _buildLargeScreenLayout(context)
              : isMediumScreen
                  ? _buildMediumScreenLayout(context)
                  : _buildSmallScreenLayout(context),
        ),
      ),
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with greeting
        _buildHeader(),

        // Door status card
        const DoorStatusCard(isLocked: true, lastUpdated: '2 mins ago'),

        const SizedBox(height: 16),

        // Stats grid
        _buildStatsSection(),

        const SizedBox(height: 16),

        // Recent activity
        _buildRecentActivitySection(context),

        // Add extra space at the bottom to prevent overflow with bottom navigation
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMediumScreenLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with greeting
        _buildHeader(),

        const SizedBox(height: 16),

        // Door status card
        const DoorStatusCard(isLocked: true, lastUpdated: '2 mins ago'),

        const SizedBox(height: 16),

        // Two-column layout for stats and activity
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats section
            Expanded(
              child: _buildStatsSection(),
            ),
            const SizedBox(width: 16),
            // Recent activity
            Expanded(
              child: _buildRecentActivitySection(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with greeting
        _buildHeader(),

        const SizedBox(height: 24),

        // Two-column layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Door status and stats
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DoorStatusCard(
                    isLocked: true,
                    lastUpdated: '2 mins ago',
                  ),

                  const SizedBox(height: 24),

                  _buildStatsSection(),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right column - Recent activity
            Expanded(
              flex: 1,
              child: _buildRecentActivitySection(context, showFullHeight: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, User', 
                  style: AppTheme.headingStyle,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Today is a great day to be secure',
                  style: AppTheme.bodyStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Icon(Icons.person_outline, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stats', style: AppTheme.subheadingStyle),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            // Adjust grid layout based on available width
            final double width = constraints.maxWidth;
            final int crossAxisCount = width < 400 ? 1 : 2;
            final double aspectRatio = width < 400 ? 3.0 : (width < 600 ? 2.0 : 1.5);

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: aspectRatio,
              children: const [
                StatsCard(
                  title: 'Last Access',
                  value: '10:30 AM',
                  icon: Icons.access_time_outlined,
                  color: Colors.blue,
                ),
                StatsCard(
                  title: 'Today\'s Access',
                  value: '5',
                  icon: Icons.people_outline,
                  color: Colors.orange,
                ),
                StatsCard(
                  title: 'Active Permissions',
                  value: '3',
                  icon: Icons.vpn_key_outlined,
                  color: Colors.purple,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(
    BuildContext context, {
    bool showFullHeight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: AppTheme.subheadingStyle),
            TextButton(
              onPressed: () {
                // Navigate to access logs tab
                (context.findAncestorStateOfType<_DashboardScreenState>())
                    ?._onItemTapped(4); // Updated index to match access logs
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Use ConstrainedBox instead of SizedBox for better control
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: showFullHeight ? 400 : 300,
            minHeight: 100,
          ),
          child: const RecentActivityList(),
        ),
      ],
    );
  }
}
