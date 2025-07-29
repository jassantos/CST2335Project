import 'package:flutter/material.dart';
import 'customer.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer customer;
  final VoidCallback onDelete;
  final VoidCallback? onClose;
  final bool showClose;

  const CustomerDetailPage({
    Key? key,
    required this.customer,
    required this.onDelete,
    this.onClose,
    this.showClose = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${customer.firstName} ${customer.lastName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: ${customer.firstName}', style: const TextStyle(fontSize: 18)),
            Text('Last Name: ${customer.lastName}', style: const TextStyle(fontSize: 18)),
            Text('Address: ${customer.address}', style: const TextStyle(fontSize: 18)),
            Text('Date of Birth: ${customer.dob}', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (showClose)
                  ElevatedButton.icon(
                    onPressed: () {
                        Navigator.of(context).pop();
                      },
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ElevatedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onDelete(); // notify parent
                Navigator.of(ctx).pop(); // close dialog
                Navigator.of(context).pop(); // return to parent view
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}