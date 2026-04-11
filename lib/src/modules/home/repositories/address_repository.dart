import 'package:hive/hive.dart';
import '../../../shared/models/address_model.dart';

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
  }

  // Buscar todos os endereços
  Future<List<AddressModel>> getAllAddresses() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // Deletar um endereço (opcional)
  Future<void> deleteAddress(int index) async {
    final box = await _openBox();
    await box.deleteAt(index);
  }

}
