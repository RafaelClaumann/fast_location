## Provider + Componente `AddressListView` Reutilizável

### Resumo

Esta PR substitui o gerenciamento manual de estado (`addListener`/`setState`) pelo pacote **Provider**, eleva o `AddressController` para o topo da árvore de widgets e extrai a lógica de exibição de endereços em um componente reutilizável (`AddressListView`), permitindo que `HistoryPage` consuma dados reais em vez de uma lista estática hardcoded.

---

### 1. Introdução do `provider` e elevação do `AddressController`

**Antes:** cada tela instanciava seu próprio `AddressController` localmente e se conectava a ele manualmente via `addListener`:

```dart
// home_page.dart — ANTES
class _HomePageState extends State<HomePage> {
  final _addressController = AddressController(); // instância local

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() => setState(() {})); // observação manual
    _addressController.loadAddresses();
  }
}
```

Isso significava que cada tela tinha sua **própria instância isolada** do controller — `HomePage` e `HistoryPage` nunca compartilhavam o mesmo estado.

**Depois:** o `AddressController` é criado uma única vez em `main.dart` e injetado na raiz da árvore via `ChangeNotifierProvider`:

```dart
// main.dart — DEPOIS
runApp(
  ChangeNotifierProvider(
    create: (context) => AddressController()..loadAddresses(),
    child: const MyApp(),
  ),
);
```

O operador `..loadAddresses()` é uma **cascade notation**: cria o controller e já chama `loadAddresses()` na mesma expressão, antes de o widget ser montado. O `ChangeNotifierProvider` é quem gerencia o ciclo de vida do controller — ele chama `dispose()` automaticamente quando o provider é removido da árvore.

---

### 2. Como as telas acessam o controller agora

O Provider disponibiliza duas formas de acesso via `BuildContext`, com semânticas distintas:

**`context.watch<T>()`** — subscreve o widget ao controller: toda vez que `notifyListeners()` for chamado, o `build()` desse widget é agendado novamente. É o substituto direto do `addListener` + `setState`.

**`context.read<T>()`** — lê o controller sem criar subscrição. Usado para disparar ações pontuais (ex: clique de botão) onde não faz sentido reconstruir a UI só por ter lido o objeto.

```dart
// home_page.dart — acesso para escrita (sem subscrição)
void _searchCep() async {
  FocusScope.of(context).unfocus(); // fecha o teclado antes de qualquer coisa
  final isCepNotEmpty = _cepController.text.isNotEmpty;
  if (isCepNotEmpty) {
    context.read<AddressController>().addAddress(_cepController.text);
    _cepController.clear();
  }
}
```

A `HomePage` não usa `context.watch` diretamente porque ela delegou a responsabilidade de observar o controller para o componente `AddressListView` (ver seção 3). O `initState` completo foi removido da `HomePage` — ela não precisa mais gerenciar o ciclo de vida do controller.

---

### 3. Novo componente `AddressListView`

**Arquivo:** `lib/src/shared/components/address_list_view.dart`

É um `StatelessWidget` que encapsula toda a lógica de exibição da lista de endereços: busca o controller, aplica o limite opcional, trata o estado vazio e monta o `ListView.builder`.

```dart
class AddressListView extends StatelessWidget {
  final int? limit;

  const AddressListView({super.key, this.limit});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddressController>(); // subscrição

    var displayAddresses = controller.addresses;

    if (limit != null && displayAddresses.length > limit!) {
      displayAddresses = displayAddresses.sublist(0, limit);
    }

    if (controller.addresses.isEmpty) {
      return const Center(child: Text('Nenhum endereço encontrado.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: displayAddresses.length,
      itemBuilder: (context, index) {
        final address = displayAddresses[index];
        return AddressCard(
          address: address,
          onDelete: () => controller.deleteAddress(address),
        );
      },
    );
  }
}
```

**Decisões de implementação relevantes:**

- **`context.watch`** aqui é intencional: é este widget, e não a tela pai, que precisa se reconstruir quando o controller notificar mudanças. Isso evita reconstruir o `Scaffold` inteiro da `HomePage` a cada atualização.

- **`shrinkWrap: true` + `ClampingScrollPhysics`**: o `ListView.builder` por padrão tenta ocupar todo o espaço disponível e usa sua própria física de scroll. Quando ele é filho de uma `Column` ou de outro scrollable, isso gera conflito. `shrinkWrap: true` faz o `ListView` se dimensionar pelo tamanho do seu conteúdo, e `ClampingScrollPhysics` substitui a física padrão (que teria bounce no iOS) por uma que se comporta como um bloco fixo, delegando o scroll para o pai.

- **`limit` e `sublist`**: o parâmetro `limit` é `int?` (nullable). A checagem `limit != null && displayAddresses.length > limit!` garante que o corte só acontece se o parâmetro foi informado **e** a lista realmente tem mais itens do que o limite — sem isso, `sublist` lançaria `RangeError`.

- **O `onDelete` captura `address` por closure**: cada `itemBuilder` cria uma closure que "lembra" qual `address` corresponde àquele índice. Quando o botão é pressionado, o delete é chamado diretamente com o objeto correto, sem depender do índice (que poderia mudar se a lista fosse modificada antes do tap).

---

### 4. Refatoração das telas

**`HomePage`** — antes tinha ~30 linhas de lógica de lista inline; agora delega para `AddressListView(limit: 3)`, que exibe apenas as 3 buscas mais recentes na tela principal:

```dart
// ANTES: ListView.builder inline com ~20 linhas
// DEPOIS:
Expanded(child: AddressListView(limit: 3)),
```

Além da migração para Provider, dois ajustes de UX foram feitos no fluxo de busca:

- **`FocusScope.of(context).unfocus()`** no início de `_searchCep()`: fecha o teclado virtual imediatamente ao confirmar a busca, independente de como a função foi acionada (botão ou teclado). Sem isso, o teclado permanece aberto depois do clique, exigindo um tap extra do usuário para dispensá-lo.

- **`onSubmitted`** no `TextField`: conecta a tecla de confirmação do teclado virtual diretamente ao `_searchCep()`. Antes, o único jeito de disparar a busca era o botão "Buscar". Agora o usuário pode digitar o CEP e pressionar "Enter" (ou equivalente no teclado do dispositivo) sem tirar as mãos do teclado.

```dart
TextField(
  controller: _cepController,
  keyboardType: TextInputType.number,
  onSubmitted: (_) {
    _searchCep(); // o parâmetro `_` é o valor do campo, ignorado pois já lemos via _cepController.text
  },
),
```

O parâmetro recebido pelo `onSubmitted` é o valor atual do campo como `String`, mas é descartado (`_`) porque a leitura já acontece dentro de `_searchCep()` via `_cepController.text` — evitando duplicidade.

**`HistoryPage`** — era uma tela com lista estática hardcoded (dois endereços fictícios). Agora consome dados reais do Hive via o controller compartilhado, sem nenhuma lógica própria:

```dart
// ANTES: lista fictícia local
final List<AddressModel> _history = [
  AddressModel(cep: '01001-000', address: 'Praça da Sé...'),
  AddressModel(cep: '20040-002', address: 'Avenida Rio Branco...'),
];

// DEPOIS: componente reutilizável sem limite (exibe tudo)
body: const Padding(
  padding: EdgeInsets.all(8.0),
  child: AddressListView(), // limit não informado = exibe todos
),
```

O `_HistoryPageState` ficou sem nenhum campo ou método próprio — na prática poderia ser convertido para `StatelessWidget`, mas foi mantido como `StatefulWidget` para facilitar futuras adições.

---

### Arquivos alterados

| Arquivo | Tipo | Mudança |
|---|---|---|
| `lib/main.dart` | Modificado | Adiciona `ChangeNotifierProvider` na raiz; `AddressController` criado e carregado aqui |
| `lib/src/shared/components/address_list_view.dart` | **Novo** | Componente reutilizável com suporte a `limit`, estado vazio e `shrinkWrap` |
| `lib/src/modules/home/page/home_page.dart` | Modificado | Remove controller local, `initState` e `ListView` inline; usa `AddressListView(limit: 3)` e `context.read` |
| `lib/src/modules/history/page/history_page.dart` | Modificado | Remove lista estática; passa a usar `AddressListView()` com dados reais |
| `pubspec.yaml` | Modificado | Adiciona dependência `provider: ^6.1.1` |