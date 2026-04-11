import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../../../shared/models/address_model.dart';

var logger = Logger();

class AddressRepository {
  static const String _boxName = 'addresses';

  // Abre a caixa (tabela) do Hive
  Future<Box<AddressModel>> _openBox() async {
    return await Hive.openBox<AddressModel>(_boxName);
  }

  // Salvar um endereço
  Future<void> saveAddress(AddressModel address) async {
    final box = await _openBox();
    await box.add(address); // Adiciona com auto-incremento

    // Isso aparecerá com cores e ícones no console de debug
    logger.i('Endereço ${address.cep} salvo no Hive!');
  }

  // Buscar todos os endereços
  Future<List<AddressModel>> getAllAddresses() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // Deletar um endereço (opcional)
  Future<void> deleteAddressByIndex(int index) async {
    final box = await _openBox();
    await box.deleteAt(index);
  }

  // Deletar um endereço (opcional)
  Future<void> deleteAddress(AddressModel address) async {
    await address.delete();
    logger.i('Endereço ${address.cep} excluído do Hive!');
  }

  // Limpar a base de dados completa
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
    logger.w('Banco de dados Hive limpo com sucesso!');
  }
}
