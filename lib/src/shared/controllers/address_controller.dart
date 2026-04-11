import 'package:flutter/material.dart';

import '../../modules/home/repositories/address_repository.dart';
import '../models/address_model.dart';

// O ChangeNotifier permite que as telas "escutem" quando os dados mudarem
class AddressController extends ChangeNotifier {
  final AddressRepository _repository = AddressRepository();

  final List<AddressModel> _staticAddresses = [
    AddressModel(cep: '01001-000', address: 'Praça da Sé, Sé, São Paulo - SP'),
    AddressModel(cep: '20040-002', address: 'Avenida Rio Branco, Rio de Janeiro - RJ',),
  ];

  List<AddressModel> addresses = [];
  bool isLoading = false;

  // Lógica de carregar e concatenar centralizada
  Future<void> loadAddresses() async {
    isLoading = true;
    notifyListeners(); // Avisa a tela para mostrar um loading

    final hiveAddresses = await _repository.getAllAddresses();
    addresses = [..._staticAddresses, ...hiveAddresses.reversed];

    isLoading = false;
    notifyListeners(); // Avisa a tela para atualizar a lista
  }

  Future<void> addAddress(String cep) async {
    final novo = AddressModel(cep: cep, address: 'Endereço para o CEP $cep');
    await _repository.saveAddress(novo);
    await loadAddresses(); // Atualiza a lista automaticamente
  }

  Future<void> deleteAddress(AddressModel address) async {
    await _repository.deleteAddress(address);
    await loadAddresses();
  }
}
