import 'package:hive/hive.dart';

part 'address_model.g.dart'; // Necessário para o gerador de código

@HiveType(typeId: 0)
class AddressModel extends HiveObject {

  @HiveField(0)
  final String cep;

  @HiveField(1)
  final String address;

  AddressModel({required this.cep, required this.address});

}
