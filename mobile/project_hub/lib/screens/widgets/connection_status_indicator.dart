import 'package:flutter/material.dart';
import 'package:project_hub/services/socket_service.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: SocketService.instance.connectionStatusStream,
      initialData: false,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isConnected ? 0 : 40,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            boxShadow:
                isConnected
                    ? []
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child:
              isConnected
                  ? const SizedBox.shrink()
                  : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Connecting to server...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            SocketService.instance.reconnect();
                          },
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
