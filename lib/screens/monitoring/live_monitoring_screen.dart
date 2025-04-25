import 'package:flutter/material.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  bool _isMicActive = false;
  bool _isSpeakerActive = false;
  bool _isRecording = false;
  bool _isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Live Monitoring', style: AppTheme.headingStyle),
            const SizedBox(height: 8),
            Text('View and interact with your door in real-time', style: AppTheme.bodyStyle),
            const SizedBox(height: 24),

            // Live video feed
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFullScreen = !_isFullScreen;
                  });
                  if (_isFullScreen) {
                    _showFullScreenView();
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      // Placeholder for camera feed
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_off_outlined,
                              size: 60,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Camera feed will appear here',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Recording indicator
                      if (_isRecording)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'REC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Fullscreen button
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(Icons.fullscreen),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _isFullScreen = !_isFullScreen;
                            });
                            if (_isFullScreen) {
                              _showFullScreenView();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.mic,
                  label: 'Microphone',
                  isActive: _isMicActive,
                  onPressed: () {
                    setState(() {
                      _isMicActive = !_isMicActive;
                    });
                    _showPermissionSnackBar('Microphone');
                  },
                ),
                _buildControlButton(
                  icon: Icons.volume_up,
                  label: 'Speaker',
                  isActive: _isSpeakerActive,
                  onPressed: () {
                    setState(() {
                      _isSpeakerActive = !_isSpeakerActive;
                    });
                    _showPermissionSnackBar('Speaker');
                  },
                ),
                _buildControlButton(
                  icon: _isRecording ? Icons.stop : Icons.fiber_manual_record,
                  label: _isRecording ? 'Stop' : 'Record',
                  isActive: _isRecording,
                  activeColor: Colors.red,
                  onPressed: () {
                    setState(() {
                      _isRecording = !_isRecording;
                    });
                    if (_isRecording) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recording started'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recording saved'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Door control
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Door Control',
                    style: AppTheme.subheadingStyle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Door unlocked'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock_open),
                          label: const Text('Unlock Door'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Door locked'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock),
                          label: const Text('Lock Door'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
    Color activeColor = AppTheme.primaryColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.2) : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : Colors.grey[700],
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? activeColor : Colors.grey[700],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showPermissionSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ${_isMicActive ? 'activated' : 'deactivated'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFullScreenView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Placeholder for camera feed
              const Center(
                child: Text(
                  'Full screen camera feed',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              // Close button
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Control buttons at bottom
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: _isMicActive ? AppTheme.primaryColor : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMicActive = !_isMicActive;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.fiber_manual_record,
                        color: _isRecording ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isRecording = !_isRecording;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        color: _isSpeakerActive ? AppTheme.primaryColor : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSpeakerActive = !_isSpeakerActive;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}