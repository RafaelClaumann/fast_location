## Persistência local com Hive + Refatoração para `AddressController`

### Resumo

Esta PR integra persistência local de endereços usando **Hive** e introduz a camada de controller (`AddressController`) para centralizar a lógica de negócio, desacoplando a UI da fonte de dados.

### O que foi feito

- **Inicialização do Hive** em `main.dart` com `Hive.initFlutter()` e registro do `AddressModelAdapter` gerado pelo `build_runner`
- **`AddressController`** (`ChangeNotifier`) criado como ponto central para:
  - Carregar endereços (estáticos + persistidos no Hive)
  - Adicionar novos CEPs
  - Deletar endereços individuais
- **`HomePage`** refatorada para consumir `AddressController` via listener, eliminando lista local e lógica inline
- **`AddressRepository`** expandido com:
  - `deleteAddress(AddressModel)` — deleção direta pelo objeto Hive
  - `clearAll()` — limpeza completa do banco
  - Integração do pacote `logger` para logs coloridos no console de debug
- **Documentação técnica** adicionada em `docs/05-QA.md` cobrindo controllers e estrutura de listas

### Arquivos alterados

| Arquivo | Mudança |
|---|---|
| `lib/main.dart` | Inicialização assíncrona do Hive |
| `lib/src/shared/controllers/address_controller.dart` | **Novo** — controller com `ChangeNotifier` |
| `lib/src/modules/home/page/home_page.dart` | Refatorada para usar o controller |
| `lib/src/modules/home/repositories/address_repository.dart` | Novos métodos + logger |
| `pubspec.yaml` / `pubspec.lock` | Dependências: `hive_flutter`, `logger` |
| `docs/05-QA.md` | Documentação de QA expandida |