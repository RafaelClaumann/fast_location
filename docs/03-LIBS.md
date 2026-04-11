# Bibliotecas do Projeto

## Dependências do app

### `dio`
Cliente HTTP para Dart/Flutter. Substitui o `http` padrão com recursos adicionais como interceptors (para adicionar headers globais, tratar erros de forma centralizada), cancelamento de requisições, suporte a FormData e timeouts configuráveis. Usado para comunicar com a API do ViaCEP.

---

### `mobx`
Biblioteca de gerenciamento de estado baseada em programação reativa. Permite criar `Store`s com `@observable` (estado reativo), `@action` (métodos que alteram o estado) e `@computed` (valores derivados). A UI é notificada automaticamente sempre que um observable muda.

---

### `flutter_mobx`
Integração do MobX com Flutter. Fornece o widget `Observer`, que observa os observables usados dentro dele e reconstrói automaticamente a UI quando esses valores mudam. Sem esse pacote, o MobX sozinho não consegue reagir à árvore de widgets do Flutter.

---

### `hive`
Banco de dados local leve e rápido para Dart/Flutter, baseado em chave-valor. Não depende de SQL e armazena dados em arquivos binários. Usado para persistir o histórico de endereços consultados localmente no dispositivo.

---

### `hive_flutter`
Extensão do Hive com utilitários específicos para Flutter, como a inicialização simplificada com `Hive.initFlutter()`, que configura automaticamente o diretório de armazenamento correto para cada plataforma.

---

### `path`
Biblioteca para manipulação de caminhos de arquivos e diretórios de forma cross-platform. Fornece utilitários como `path.join()` para concatenar caminhos sem se preocupar com separadores de sistema operacional (`/` vs `\`).

---

### `path_provider`
Fornece acesso aos diretórios padrão do sistema operacional, como o diretório de documentos (`getApplicationDocumentsDirectory()`) e o diretório temporário. Usado em conjunto com o Hive para definir onde salvar os arquivos do banco de dados.

---

### `path_provider_android`
Implementação Android do `path_provider`. É a camada nativa que resolve os caminhos reais no Android. Declarada explicitamente para garantir a versão correta na resolução de dependências.

---

### `path_provider_ios`
Implementação iOS do `path_provider`. Mesma função do `path_provider_android`, porém para a plataforma iOS.

---

### `map_launcher`
Permite abrir aplicativos de mapa instalados no dispositivo (Google Maps, Waze, Apple Maps etc.) com coordenadas ou endereço de destino. Usado para a funcionalidade de traçar rota até o último endereço consultado.

---

### `geocoding`
Converte endereços em coordenadas geográficas (latitude/longitude) e vice-versa. Usado para transformar o endereço retornado pela API do ViaCEP em coordenadas antes de passar para o `map_launcher`.

---

## Dependências de desenvolvimento (dev)

### `mobx_codegen`
Gerador de código para o MobX. Lê as anotações `@observable`, `@action`, `@computed` e gera o código boilerplate necessário (o arquivo `.g.dart`) automaticamente. Sem ele, seria necessário escrever todo o código reativo manualmente.

---

### `build_runner`
Ferramenta que executa os geradores de código no projeto Dart/Flutter. É o "motor" que roda o `mobx_codegen` e o `hive_generator`. Executado via terminal com `dart run build_runner build`.

---

### `hive_generator`
Gerador de código para o Hive. Lê a anotação `@HiveType` nas classes de modelo e gera os `TypeAdapter`s necessários para o Hive conseguir serializar e desserializar os objetos automaticamente.