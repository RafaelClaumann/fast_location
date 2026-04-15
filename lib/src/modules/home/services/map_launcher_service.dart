import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:map_launcher/map_launcher.dart';

class MapLauncherService {
  final _logger = Logger();

  /// Abre uma folha de estilo (BottomSheet) customizada para o usuário escolher o mapa
  Future<void> openMapPicker(BuildContext context, String address) async {
    try {
      final coords = await _getCoordinates(address);
      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isEmpty) {
        _logger.w("Nenhum aplicativo de mapa instalado.");
        return;
      }

      // Se houver apenas um mapa, abre direto para agilizar
      if (availableMaps.length == 1) {
        await _launchMap(availableMaps.first, coords, address);
        return;
      }

      if (context.mounted) {
        _showOptionsBottomSheet(context, availableMaps, coords, address);
      }
    } catch (e) {
      _logger.e("Erro ao processar abertura de mapas: $e");
    }
  }

  /// 1. Lógica de Geocoding (Converte texto em coordenadas)
  Future<Coords?> _getCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _logger.i("Coordenadas obtidas: ${loc.latitude}, ${loc.longitude}");
        return Coords(loc.latitude, loc.longitude);
      }
    } catch (e) {
      _logger.w("Falha no Geocoding para: $address. Erro: $e");
    }
    return null;
  }

  /// 2. Lógica de Execução (Dispara o app de mapa escolhido)
  Future<void> _launchMap(
    AvailableMap map,
    Coords? coords,
    String title,
  ) async {
    _logger.i("Abrindo mapa: ${map.mapName}");
    await map.showMarker(coords: coords ?? Coords(0, 0), title: title);
  }

  /// 3. Lógica de UI (Constrói o BottomSheet)
  void _showOptionsBottomSheet(
    BuildContext context,
    List<AvailableMap> maps,
    Coords? coords,
    String address,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'O que deseja fazer?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            // Mapeia os aplicativos instalados
            ...maps.map(
              (map) => ListTile(
                leading: const Icon(Icons.map_outlined, color: Colors.blue),
                title: Text(map.mapName),
                onTap: () async {
                  await _launchMap(map, coords, address);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            // Opção de Copiar para Clipboard
            ListTile(
              leading: const Icon(Icons.copy_all_outlined, color: Colors.green),
              title: const Text('Copiar endereço'),
              subtitle: Text(
                address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: address));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Endereço copiado!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
