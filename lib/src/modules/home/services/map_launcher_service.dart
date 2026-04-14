import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:map_launcher/map_launcher.dart';

class MapLauncherService {
  final _logger = Logger();

  /// Abre uma folha de estilo (BottomSheet) customizada para o usuário escolher o mapa
  Future<void> openMapPicker(BuildContext context, String address) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isEmpty) {
        _logger.w("Nenhum aplicativo de mapa instalado.");
        return;
      }

      // Se houver apenas um mapa, abre direto para agilizar
      if (availableMaps.length == 1) {
        await availableMaps.first.showMarker(
          coords: Coords(0, 0),
          title: address,
        );
        return;
      }

      // Abre o seletor customizado
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'O que deseja fazer?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  // Lista os mapas instalados
                  ...availableMaps.map(
                    (map) => ListTile(
                      onTap: () async {
                        await map.showMarker(
                          coords: Coords(0, 0),
                          title: address,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      title: Text(map.mapName),
                      leading: const Icon(
                        Icons.map_outlined,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const Divider(),
                  // Opção de Copiar Endereço
                  ListTile(
                    leading: const Icon(
                      Icons.copy_all_outlined,
                      color: Colors.green,
                    ),
                    title: const Text('Copiar endereço'),
                    subtitle: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: address));

                      if (context.mounted) {
                        Navigator.pop(context); // Fecha o BottomSheet

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Endereço copiado para a área de transferência!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      _logger.e("Erro ao abrir seletor de mapas: $e");
    }
  }
}
