import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/components/address_card.dart';
import '../../../shared/controllers/address_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    // Escuta o mesmo controller do main
    var addressController = context.watch<AddressController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Buscas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: addressController.addresses.isEmpty
          ? const Center(child: Text('Nenhum histórico encontrado.'))
          : ListView.builder(
              itemCount: addressController.addresses.length,
              itemBuilder: (context, index) {
                final address = addressController.addresses[index];
                return AddressCard(
                  address: address,
                  onDelete: () => addressController.deleteAddress(address),
                );
              },
            ),
    );
  }
}
