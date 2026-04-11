import 'package:flutter/material.dart';
import '../models/address_model.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onDelete;

  const AddressCard({
    super.key,
    required this.address,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: Text(address.cep),
        subtitle: Text(address.address),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
