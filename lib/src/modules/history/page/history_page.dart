import 'package:flutter/material.dart';
import '../../../shared/models/address_model.dart';
import '../../../shared/components/address_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Lista fictícia para a página estática
  final List<AddressModel> _history = [
    AddressModel(cep: '01001-000', address: 'Praça da Sé, Sé, São Paulo - SP'),
    AddressModel(cep: '20040-002', address: 'Avenida Rio Branco, Centro, Rio de Janeiro - RJ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Buscas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _history.isEmpty
          ? const Center(child: Text('Nenhum histórico encontrado.'))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return AddressCard(
                  address: _history[index],
                );
              },
            ),
    );
  }
}
