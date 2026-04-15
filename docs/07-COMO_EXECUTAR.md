# Como executar o projeto localmente

## Pré-requisitos

| Ferramenta | Versão mínima | Observação |
|---|---|---|
| Flutter | 3.41.x (stable) | Inclui Dart 3.11.4 |
| Android SDK | API 21+ | Para rodar no emulador/dispositivo Android |
| JDK | 17+ | Necessário para o build Android |
| Xcode | 15+ | Apenas para rodar no iOS/macOS |

Verifique se o ambiente está configurado corretamente:

```bash
flutter doctor
```

Todos os itens relevantes ao alvo (Android ou iOS) devem estar marcados com `✓`.

---

## 1. Clonar o repositório

```bash
git clone https://github.com/RafaelClaumann/fast-location.git
cd fast-location
```

---

## 2. Instalar dependências

```bash
flutter pub get
```

Esse comando lê o `pubspec.yaml` e baixa todos os pacotes declarados:

**Dependências do app:**

| Pacote | Versão | Responsabilidade |
|---|---|---|
| `hive` | `^2.2.3` | Persistência local (banco NoSQL em arquivo) |
| `hive_flutter` | `^1.1.0` | Integração do Hive com o Flutter |
| `provider` | `^6.1.1` | Gerenciamento de estado com `ChangeNotifier` |
| `dio` | `^5.4.1` | Requisições HTTP para a API ViaCEP |
| `map_launcher` | `^3.1.0` | Detecta apps de mapa instalados e os abre via deep link |
| `geocoding` | `^3.0.0` | Converte endereço textual em coordenadas geográficas |
| `logger` | `^2.0.2` | Logs estruturados em desenvolvimento |

**Dependências de desenvolvimento:**

| Pacote | Versão | Responsabilidade |
|---|---|---|
| `build_runner` | `^2.4.8` | Executor de geração de código em tempo de desenvolvimento |
| `hive_generator` | `^2.0.1` | Geração do `TypeAdapter` para os modelos Hive |

---

## 3. Gerar o código do Hive (`build_runner`)

O `AddressModel` usa anotações do Hive que precisam de um **TypeAdapter** gerado em tempo de desenvolvimento. O arquivo `address_model.g.dart` deve existir em `lib/src/shared/models/` antes do primeiro build.

Se o arquivo **já existir** no repositório, este passo pode ser pulado. Se não existir (clone limpo ou arquivo deletado), execute:

```bash
dart run build_runner build
```

Em caso de conflito com arquivos gerados anteriormente:

```bash
dart run build_runner build --delete-conflicting-outputs
```

O que o comando gera:

```
lib/src/shared/models/
├── address_model.dart        ← você escreve
└── address_model.g.dart      ← gerado pelo build_runner (AddressModelAdapter)
```

> **Por que isso é necessário?** O `main.dart` registra explicitamente `Hive.registerAdapter(AddressModelAdapter())`. Se o `AddressModelAdapter` não existir (porque o `.g.dart` não foi gerado), o projeto não compila.

---

## 4. Conectar um dispositivo ou iniciar um emulador

**Listar dispositivos disponíveis:**

```bash
flutter devices
```

**Iniciar o emulador Android (Android Studio):**

```bash
flutter emulators --launch <emulator_id>
```

Ou abra o AVD Manager pelo Android Studio e inicie o emulador manualmente.

---

## 5. Executar o projeto

```bash
flutter run
```

Para escolher o dispositivo explicitamente quando houver mais de um conectado:

```bash
flutter run -d <device_id>
```

Para rodar em modo release (sem hot reload, mais próximo da produção):

```bash
flutter run --release
```

---

## Observações sobre funcionalidades específicas

### Consulta de CEP

O app consome a API pública `viacep.com.br`. É necessário que o dispositivo/emulador tenha **acesso à internet**.

### Abertura em app de mapas (`map_launcher` + `geocoding`)

O `geocoding` usa o **geocoder nativo do dispositivo**, que por sua vez consulta os servidores do Google (Android) ou Apple (iOS). Portanto:

- O dispositivo precisa de **acesso à internet** para converter o endereço em coordenadas.
- No emulador Android, certifique-se de que o **Google Play Services** está instalado (emuladores com a imagem "Google APIs" ou "Google Play" já incluem).
- O `map_launcher` só lista apps **realmente instalados**. No emulador padrão sem Google Play, nenhum app de mapa estará disponível — o app trata isso silenciosamente (sem crash) e não abrirá o seletor.

### Persistência (Hive)

O Hive armazena os dados em um arquivo local no dispositivo. Ao desinstalar o app ou limpar os dados pelo sistema, o histórico de endereços é apagado. Não há banco de dados remoto.

---

## Estrutura de pastas

```
lib/
├── main.dart                          # Ponto de entrada; inicializa Hive e Provider
└── src/
    ├── modules/
    │   ├── home/
    │   │   ├── page/home_page.dart     # Tela principal (busca por CEP)
    │   │   └── services/
    │   │       └── map_launcher_service.dart  # Integração com apps de mapa
    │   └── history/
    │       └── page/history_page.dart  # Tela de histórico de endereços
    └── shared/
        ├── controllers/
        │   └── address_controller.dart # ChangeNotifier; gerencia a lista de endereços
        ├── models/
        │   ├── address_model.dart      # Modelo Hive
        │   └── address_model.g.dart    # Gerado pelo build_runner
        └── components/
            ├── address_card.dart       # Card de um endereço (com onTap e onDelete)
            └── address_list_view.dart  # Lista reutilizada em HomePage e HistoryPage
```