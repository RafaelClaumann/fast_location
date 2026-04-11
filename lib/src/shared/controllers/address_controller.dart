import 'package:fast_location/src/modules/home/services/viacep_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../modules/home/repositories/address_repository.dart';
import '../models/address_model.dart';

var logger = Logger();

// O ChangeNotifier permite que as telas "escutem" quando os dados mudarem
class AddressController extends ChangeNotifier {
  final AddressRepository _repository = AddressRepository();

  final ViaCepService _viaCepService = ViaCepService();

  final List<AddressModel> _staticAddresses = [
    AddressModel(cep: '01001-000', address: 'Praça da Sé, Sé, São Paulo - SP'),
    AddressModel(
      cep: '20040-002',
      address: 'Avenida Rio Branco, Rio de Janeiro - RJ',
    ),
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
    isLoading = true;

    try {
      final fullAddress = await _viaCepService.fetchCep(cep);

      if (fullAddress != null) {
        logger.i('CEP $cep encontrado no ViaCEP: $fullAddress');

        await _repository.saveAddress(fullAddress);
        await loadAddresses();
      } else {
        logger.w('CEP $cep não encontrado no ViaCEP ou formato inválido.');
      }
    } catch (e) {
      logger.e('Erro ao processar busca de CEP: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(AddressModel address) async {
    await _repository.deleteAddress(address);
    await loadAddresses();
  }
}
