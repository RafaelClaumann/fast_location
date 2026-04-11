import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import 'address_card.dart';

class AddressListView extends StatelessWidget {
  final int? limit; // Parâmetro opcional para limitar a quantidade

  const AddressListView({super.key, this.limit});

  @override
  Widget build(BuildContext context) {
    // O componente busca o seu próprio controller via Provider
    final controller = context.watch<AddressController>();

    // 1. Pegamos a lista do controller
    var displayAddresses = controller.addresses;

    // 2. Se houver um limite e a lista for maior que esse limite, cortamos ela
    if (limit != null && displayAddresses.length > limit!) {
      displayAddresses = displayAddresses.sublist(0, limit);
    }

    if (controller.addresses.isEmpty) {
      return const Center(child: Text('Nenhum endereço encontrado.'));
    }

    return ListView.builder(
      // Evita conflitos de scroll se estiver dentro de outra Column/ListView
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: displayAddresses.length,
      itemBuilder: (context, index) {
        final address = displayAddresses[index];
        return AddressCard(
          address: address,
          onDelete: () => controller.deleteAddress(address),
        );
      },
    );
  }
}
