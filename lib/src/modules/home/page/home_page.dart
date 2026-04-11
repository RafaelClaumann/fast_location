import 'package:flutter/material.dart';
import '../../../shared/components/address_card.dart';
import '../../../shared/models/address_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _cepController = TextEditingController();
  final List<AddressModel> _recentAddresses = [
    AddressModel(cep: '01001-000', address: 'Praça da Sé, Sé, São Paulo - SP'),
    AddressModel(cep: '20040-002', address: 'Avenida Rio Branco, Centro, Rio de Janeiro - RJ'),
  ];

  void _searchCep() {
    final cep = _cepController.text;
    if (cep.isNotEmpty) {
      // Simulação de busca
      setState(() {
        _recentAddresses.insert(
          0,
          AddressModel(
            cep: cep,
            address: 'Rua Simulada para o CEP $cep, Bairro, Cidade - UF',
          ),
        );
      });
      _cepController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: _recentAddresses.isEmpty
                ? const Center(child: Text('Nenhuma busca recente.'))
                : ListView.builder(
                    itemCount: _recentAddresses.length,
                    itemBuilder: (context, index) {
                      return AddressCard(
                        address: _recentAddresses[index],
                        onDelete: () {
                          setState(() {
                            _recentAddresses.removeAt(index);
                          });
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
