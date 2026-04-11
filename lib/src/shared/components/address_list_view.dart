import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import 'address_card.dart';

class AddressListView extends StatelessWidget {
  const AddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    // O componente busca o seu próprio controller via Provider
    final controller = context.watch<AddressController>();

    if (controller.addresses.isEmpty) {
      return const Center(child: Text('Nenhum endereço encontrado.'));
    }

    return ListView.builder(
      // Evita conflitos de scroll se estiver dentro de outra Column/ListView
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: controller.addresses.length,
      itemBuilder: (context, index) {
        final address = controller.addresses[index];
        return AddressCard(
          address: address,
          onDelete: () => controller.deleteAddress(address),
        );
      },
    );
  }
}
