import 'package:fast_location/src/shared/controllers/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/components/address_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _cepController = TextEditingController();

  void _searchCep() async {
    final cep = _cepController.text.isNotEmpty;
    if (cep) {
      context.read<AddressController>().addAddress(_cepController.text);
      _cepController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos .watch para ESCUTAR mudanças na lista e reconstruir a tela
    final addressController = context.watch<AddressController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fast Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cepController,
                    decoration: const InputDecoration(
                      labelText: 'Digite o CEP',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchCep,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Buscas Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            // 1. Verificamos se a lista no controller está vazia
            child: addressController.addresses.isEmpty
                ? const Center(child: Text('Nenhuma busca recente.'))
                : ListView.builder(
                    // 2. Usamos a lista que vem do controller
                    itemCount: addressController.addresses.length,
                    itemBuilder: (context, index) {
                      final address = addressController.addresses[index];
                      return AddressCard(
                        address: address,
                        onDelete: () async {
                          // 3. Chamamos a deleção diretamente no controller
                          await addressController.deleteAddress(address);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }
}
