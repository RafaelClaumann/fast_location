import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../shared/models/address_model.dart';

var logger = Logger();

class ViaCepService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://viacep.com.br/ws',
      connectTimeout: const Duration(seconds: 5), // Tempo limite de conexão
    ),
  );

  Future<AddressModel?> fetchCep(String cep) async {
    // Limpa o CEP para ter apenas números
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) return null;

    try {
      final response = await _dio.get('/$cleanCep/json/');

      if (response.statusCode == 200) {
        final data = response.data;

        // ViaCEP retorna erro: true quando o CEP não existe
        if (data['erro'] == true) return null;

        return AddressModel(
          cep: data['cep'],
          address:
              '${data['logradouro']}, ${data['bairro']}, ${data['localidade']} - ${data['uf']}',
        );
      }
    } catch (e) {
      logger.e('Erro ao buscar CEP no ViaCEP: $cep');
      // Aqui você pode tratar erros de rede ou timeout
      return null;
    }
    return null;
  }
}
