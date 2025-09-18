// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sender_location_tracker/ui/provider/location_sender_provider.dart';
//
// class SenderHome extends StatelessWidget {
//   const SenderHome({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<LocationSenderProvider>(
//       builder: (context, provider, _) {
//         return Scaffold(
//           appBar: AppBar(title: const Text('Location Sender')),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Text('Sender ID: ${provider.senderId}'),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       provider.isSharing
//                           ? await provider.stopSharing()
//                           : await provider.startSharing();
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(e.toString())),
//                       );
//                     }
//                   },
//                   child: Text(
//                       provider.isSharing ? 'Stop Sharing' : 'Start Sharing'),
//                 ),
//                 const SizedBox(height: 20),
//                 if (provider.lastPosition != null)
//                   Text(
//                       'Last Position: ${provider.lastPosition!.latitude}, ${provider.lastPosition!.longitude}'),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sender_location_tracker/ui/provider/location_sender_provider.dart';

class SenderHome extends StatelessWidget {
  const SenderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationSenderProvider>(
      builder: (context, provider, _) {
        final hasSenderId = provider.senderId.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Location Sharing'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: hasSenderId
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_pin_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Sender ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.senderId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: provider.isSharing
                                    ? Colors.green[50]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: provider.isSharing
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    provider.isSharing
                                        ? 'Sharing Active'
                                        : 'Not Sharing',
                                    style: TextStyle(
                                      color: provider.isSharing
                                          ? Colors.green[800]
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Location Information
                if (provider.lastPosition != null) ...[
                  const Text(
                    'Last Shared Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.lastAddress ??
                                      'Fetching address...',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Updated: ${DateTime.now().toString().substring(11, 16)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Spacer(),

                // Action Button
                _buildActionButton(context, provider),
              ],
            )
                : Center(
              child: _buildActionButton(context, provider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      BuildContext context, LocationSenderProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            if (provider.isSharing) {
              await provider.stopSharing();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location sharing stopped'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else {
              await provider.startSharing();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location sharing started'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: provider.isSharing
              ? Colors.orange
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              provider.isSharing ? Icons.location_off : Icons.location_on,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              provider.isSharing
                  ? 'Stop Sharing Location'
                  : 'Start Sharing Location',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
