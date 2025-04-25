import 'package:flutter/material.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';

class DoorStatusCard extends StatefulWidget {
  final bool isLocked;
  final String lastUpdated;

  const DoorStatusCard({
    super.key,
    required this.isLocked,
    required this.lastUpdated,
  });

  @override
  State<DoorStatusCard> createState() => _DoorStatusCardState();
}

class _DoorStatusCardState extends State<DoorStatusCard>
    with SingleTickerProviderStateMixin {
  late bool _isLocked;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isLocked = widget.isLocked;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (_isLocked) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLocked
              ? 'Door locked successfully'
              : 'Door unlocked - Please remember to lock',
        ),
        backgroundColor: _isLocked ? AppTheme.primaryColor : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Door Status', style: AppTheme.subheadingStyle),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isLocked
                            ? Icons.lock_outline
                            : Icons.lock_open_outlined,
                        color: _isLocked ? AppTheme.primaryColor : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLocked ? 'Locked' : 'Unlocked',
                        style: TextStyle(
                          color:
                              _isLocked ? AppTheme.primaryColor : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: ${widget.lastUpdated}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * 0.5,
                    child: Icon(
                      Icons.lock_outline,
                      size: 60,
                      color: Color.lerp(
                        Colors.green,
                        AppTheme.primaryColor,
                        _animation.value,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleLock,
              icon: Icon(
                _isLocked ? Icons.lock_open_outlined : Icons.lock_outline,
              ),
              label: Text(_isLocked ? 'Unlock Door' : 'Lock Door'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isLocked ? Colors.green : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
