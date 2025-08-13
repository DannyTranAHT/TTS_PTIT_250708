import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class NotificationToast extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  const NotificationToast({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<NotificationToast> createState() => _NotificationToastState();
}

class _NotificationToastState extends State<NotificationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start animation
    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: _getTypeColor(widget.notification['type']),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getTypeColor(
                              widget.notification['type'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _getTypeIcon(widget.notification['type']),
                            color: _getTypeColor(widget.notification['type']),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.notification['title'] ?? 'Notification',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.notification['message'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _dismiss,
                          icon: const Icon(Icons.close, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'task_assigned':
        return Colors.blue;
      case 'task_updated':
        return Colors.orange;
      case 'comment_added':
        return Colors.green;
      case 'project_updated':
        return Colors.purple;
      case 'due_date_reminder':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'task_assigned':
      case 'task_updated':
        return Icons.assignment;
      case 'comment_added':
        return Icons.comment;
      case 'project_updated':
        return Icons.folder;
      case 'due_date_reminder':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }
}
