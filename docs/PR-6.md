## Integração com Aplicativos de Mapas via `map_launcher` e `geocoding`

### Resumo

Esta PR adiciona a funcionalidade de abrir um endereço em um aplicativo de mapas externo diretamente a partir da lista de endereços. O usuário toca em um card e um `BottomSheet` apresenta os aplicativos de mapa instalados no dispositivo para escolha. A implementação cobre: geocoding (conversão de texto em coordenadas), detecção de apps instalados, lançamento do app escolhido e cópia do endereço para a área de transferência — tudo encapsulado em um único serviço dedicado.

---

### 1. Novas dependências

Duas dependências foram adicionadas ao `pubspec.yaml`:

| Pacote | Versão | Responsabilidade |
|---|---|---|
| `map_launcher` | `^3.1.0` | Detecta apps de mapa instalados e os abre via deep link |
| `geocoding` | `^3.0.0` | Converte um endereço textual em coordenadas geográficas (lat/lng) |

O `map_launcher` funciona disparando **intents** (Android) ou **URL schemes** (iOS). Ele não sabe apontar para um endereço textual — apenas para coordenadas. Por isso, o `geocoding` é necessário como etapa intermediária: recebe o `address` (string) e devolve uma lista de `Location` com latitude e longitude.

---

### 2. Configuração de plataforma

Para que as duas bibliotecas funcionem, são necessárias declarações explícitas nos manifestos de cada plataforma.

#### Android — `android/app/src/main/AndroidManifest.xml`

O Android 11+ (API 30+) impõe o **Package Visibility Filtering**: por padrão, um app não consegue "ver" nem interagir com outros apps instalados, a menos que declare explicitamente quais intents deseja consultar no bloco `<queries>`.

Três esquemas foram adicionados:

```xml
<queries>
    <!-- Google Maps e apps que respondem ao scheme geo: -->
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="geo" />
    </intent>

    <!-- Navegação turn-by-turn do Google Maps -->
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="google.navigation" />
    </intent>

    <!-- Waze -->
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="waze" />
    </intent>
</queries>
```

Sem essa declaração, `MapLauncher.installedMaps` retornaria uma lista vazia mesmo com o Google Maps instalado, pois o sistema operacional bloqueia a consulta.

#### iOS — `ios/Runner/Info.plist`

No iOS, o equivalente é a chave `LSApplicationQueriesSchemes`. Ela lista os URL schemes que o app está autorizado a consultar via `canOpenURL()`. Foram declarados 13 schemes, cobrindo: Google Maps, Waze, Yandex Maps, Yandex Navi, HERE, TomTom Go, CityMapper, Maps.me, OsmAnd, 2GIS, Baidu Maps, Amap e QQ Maps.

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>comgooglemaps</string>
    <string>waze</string>
    <string>yandexmaps</string>
    <!-- ... demais schemes ... -->
</array>
```

---

### 3. `MapLauncherService` — o serviço central

Arquivo criado: `lib/src/modules/home/services/map_launcher_service.dart`

O serviço centraliza três responsabilidades distintas em métodos privados separados, com um único ponto de entrada público.

#### 3.1 Ponto de entrada público: `openMapPicker`

```dart
Future<void> openMapPicker(BuildContext context, String address) async {
  final coords = await _getCoordinates(address);
  final availableMaps = await MapLauncher.installedMaps;

  if (availableMaps.isEmpty) { ... return; }

  if (availableMaps.length == 1) {
    await _launchMap(availableMaps.first, coords, address);
    return;
  }

  if (context.mounted) {
    _showOptionsBottomSheet(context, availableMaps, coords, address);
  }
}
```

Fluxo de decisão:
- **Nenhum app instalado:** loga um warning e aborta silenciosamente (sem crash).
- **Exatamente um app:** abre diretamente, sem exibir o BottomSheet — evita um passo desnecessário para o usuário.
- **Dois ou mais apps:** exibe o BottomSheet de seleção.

A checagem `context.mounted` antes de chamar `_showOptionsBottomSheet` protege contra o cenário em que o widget foi desmontado durante os dois `await` anteriores (geocoding + `installedMaps`).

#### 3.2 Geocoding: `_getCoordinates`

```dart
Future<Coords?> _getCoordinates(String address) async {
  List<Location> locations = await locationFromAddress(address);
  if (locations.isNotEmpty) {
    final loc = locations.first;
    return Coords(loc.latitude, loc.longitude);
  }
  return null;
}
```

- Chama `locationFromAddress` do pacote `geocoding`, que consulta o geocoder nativo do dispositivo (não requer chave de API).
- Retorna `Coords?` (nullable). Se o geocoding falhar (endereço ambíguo, sem internet, etc.), o método captura a exceção, loga um warning e retorna `null`.
- O tipo `Coords` pertence ao pacote `map_launcher` e serve como contrato entre o geocoding e o lançamento do mapa.

#### 3.3 Lançamento do app: `_launchMap`

```dart
Future<void> _launchMap(AvailableMap map, Coords? coords, String title) async {
  await map.showMarker(coords: coords ?? Coords(0, 0), title: title);
}
```

- Recebe um `AvailableMap` (objeto do `map_launcher` que representa um app instalado) e chama `showMarker`, que abre o app externo com um marcador no endereço indicado.
- O fallback `Coords(0, 0)` é usado quando o geocoding falhou. Nesse caso, o mapa abrirá apontando para as coordenadas nulas — comportamento aceitável como degradação graceful.

#### 3.4 BottomSheet de seleção: `_showOptionsBottomSheet`

Construído com `showModalBottomSheet` com bordas arredondadas no topo (`BorderRadius.vertical`). O conteúdo é uma `Column` com `mainAxisSize: MainAxisSize.min` para que a folha ocupe apenas o espaço necessário.

**Seção de apps de mapa:**
Cada `AvailableMap` da lista `installedMaps` é mapeado para um `ListTile`. Ao tocar, o app é aberto via `_launchMap` e, após o retorno, o BottomSheet é fechado com `Navigator.pop` — com verificação `context.mounted` antes.

**Seção "Copiar endereço":**
Um `ListTile` fixo que:
1. Chama `Clipboard.setData` com o endereço completo.
2. Fecha o BottomSheet.
3. Exibe um `SnackBar` flutuante confirmando a cópia.

A ordem das verificações `context.mounted` nesse trecho é relevante: o `await Clipboard.setData` é uma operação assíncrona — o widget pode ter sido desmontado nesse intervalo, então a checagem ocorre após o `await`, antes de qualquer interação com o contexto.

---

### 4. Modificações nos componentes existentes

#### `AddressCard` — novo parâmetro `onTap`

```dart
// ANTES
class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onDelete;
  // ...
  ListTile(
    leading: ...,
    title: ...,
    subtitle: ...,
    trailing: ...
  )
}

// DEPOIS
class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onTap;    // ← novo
  final VoidCallback? onDelete;
  // ...
  ListTile(
    ...
    onTap: onTap,               // ← novo
    trailing: ...
  )
}
```

O parâmetro `onTap` é opcional (`VoidCallback?`), preservando a compatibilidade com os usos existentes que não passam o callback. O `ListTile` do Flutter ignora o gesto de toque quando `onTap` é `null`.

#### `AddressListView` — instância do serviço e wiring do `onTap`

```dart
// ANTES
class AddressListView extends StatelessWidget {
  final int? limit;
  const AddressListView({super.key, this.limit});
  // ...
  return AddressCard(
    address: address,
    onDelete: () => controller.deleteAddress(address),
  );
}

// DEPOIS
class AddressListView extends StatelessWidget {
  final int? limit;
  final MapLauncherService _mapLauncherService = MapLauncherService(); // ← novo

  AddressListView({super.key, this.limit}); // const removido
  // ...
  return AddressCard(
    address: address,
    onTap: () => _mapLauncherService.openMapPicker(context, address.address), // ← novo
    onDelete: () => controller.deleteAddress(address),
  );
}
```

Dois pontos merecem atenção:

- **Remoção do `const`:** O construtor precisou deixar de ser `const` porque a classe agora inicializa um campo de instância (`_mapLauncherService = MapLauncherService()`). Campos de instância com inicializador não são permitidos em construtores `const`.
- **Acesso ao `context`:** O `openMapPicker` precisa de um `BuildContext` para exibir o `BottomSheet`. O `context` é obtido diretamente do método `build`, que é o ponto correto para isso em um `StatelessWidget`.

#### `HistoryPage` — remoção do `const` no `body`

```dart
// ANTES
body: const Padding(padding: ..., child: AddressListView())

// DEPOIS
body: Padding(padding: ..., child: AddressListView())
```

Consequência direta da remoção do construtor `const` de `AddressListView`: qualquer `const` que dependia do construtor constante de `AddressListView` precisou ser removido em cascata.

---

### 5. Fluxo completo de execução (happy path)

```
Usuário toca no AddressCard
        │
        ▼
AddressListView.onTap → MapLauncherService.openMapPicker(context, address)
        │
        ▼
_getCoordinates(address)
  → geocoding.locationFromAddress("Rua X, 123, São Paulo")
  → Coords(-23.5505, -46.6333)
        │
        ▼
MapLauncher.installedMaps
  → [AvailableMap(Google Maps), AvailableMap(Waze)]
        │
        ▼
context.mounted? → true
        │
        ▼
_showOptionsBottomSheet(context, maps, coords, address)
  → showModalBottomSheet(...)
        │
   ┌────┴────────────────────┐
   │                         │
Toca em "Google Maps"   Toca em "Copiar"
   │                         │
_launchMap(...)          Clipboard.setData(...)
map.showMarker(...)      Navigator.pop(context)
Navigator.pop(context)   SnackBar("Endereço copiado!")
```