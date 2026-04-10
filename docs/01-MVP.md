# Busca por CEP — MVP

> Este documento descreve o escopo mínimo para um app funcional de busca por CEP.
> Deve ser usado como referência para geração de código com Claude Code.

---

## Stack

- **Framework:** Flutter (Dart)
- **Gerenciamento de estado:** a definir (sugestão: Riverpod ou BLoC)
- **Armazenamento local:** Hive (leve, sem setup de SQLite)
- **API de CEP:** ViaCEP (`https://viacep.com.br/ws/{cep}/json/`)
- **HTTP client:** Dio ou http

---

## Estrutura de dados

```dart
class CepRecord {
  final String cep;          // "01001000" (sem hífen, chave única)
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;
  final String complemento;  // pode ser vazio
  final DateTime consultadoEm; // timestamp da última consulta
}
```

---

## Telas

### 1. Tela Inicial (Home)

**Elementos:**
- Campo de texto para CEP com máscara `XXXXX-XXX` (aceita apenas dígitos, máximo 8)
- Botão de busca (desabilitado enquanto CEP tiver menos de 8 dígitos)
- Lista dos últimos 3 CEPs consultados (ordenados por `consultadoEm` DESC)
- Botão "Ver todos" (sempre visível, desabilitado se ≤ 3 itens no histórico)
- Estado vazio quando não há histórico (imagem ilustrativa + texto orientativo)

**Estado vazio:**
- Título: "Nenhum CEP consultado ainda"
- Descrição: "Busque um CEP para visualizar o endereço e acessar rapidamente depois."

### 2. Modal de Endereço (BottomSheet)

**Exibido quando:**
- Busca retorna com sucesso
- Usuário clica em item do histórico (tela inicial ou "Ver todos")

**Conteúdo:**
- Endereço completo: logradouro, bairro, cidade — UF
- CEP formatado

**Ações:**
- Abrir localização (intent/URL para app de mapas)
- Compartilhar endereço (share intent do sistema)
- Copiar endereço (clipboard, sem intent)

### 3. Tela "Ver Todos"

**Elementos:**
- Campo de busca no topo (filtra por CEP ou endereço)
- Lista completa do histórico, ordenada por mais recentes
- Cada item mostra: endereço resumido (rua + bairro), CEP, botão excluir

---

## Fluxo de busca

```
Usuário digita CEP (8 dígitos)
        │
        ▼
  CEP existe no Hive?
     ┌────┴────┐
    SIM       NÃO
     │         │
     │         ▼
     │   Exibir loading
     │         │
     │         ▼
     │   GET viacep.com.br/ws/{cep}/json/
     │         │
     │    ┌────┴────┐
     │  SUCESSO   ERRO
     │    │         │
     │    │         ▼
     │    │    Snackbar com mensagem de erro
     │    │
     │    ▼
     │  Salvar no Hive (com timestamp atual)
     │
     ├────┘
     ▼
Atualizar timestamp no Hive
     │
     ▼
Abrir modal com endereço e ações
```

---

## Regras de negócio (MVP)

1. **Validação de CEP:** apenas dígitos, exatamente 8 caracteres. Botão desabilitado se inválido.
2. **Cache local:** antes de chamar a API, verificar se o CEP já existe no Hive. Se existir, usar os dados locais.
3. **Atualização de posição:** ao consultar um CEP já existente, atualizar o `consultadoEm` para `DateTime.now()`.
4. **Ordenação:** sempre por `consultadoEm` decrescente.
5. **Tela inicial mostra no máximo 3 itens.**
6. **Botão "Ver todos" habilitado somente quando histórico > 3 itens.**
7. **Exclusão imediata:** ao clicar no ícone de excluir, o item é removido da lista e do Hive.
8. **Abrir localização:** montar URL `geo:0,0?q={endereço URL-encoded}` e delegar ao SO via `url_launcher`.
9. **Compartilhar:** usar `share_plus` para enviar texto do endereço.
10. **Copiar:** usar `Clipboard.setData` do Flutter.

---

## Tratamento de erros (mínimo)

| Cenário | Mensagem (Snackbar) |
|---|---|
| CEP não encontrado (API retorna `"erro": true`) | "CEP não encontrado. Verifique o número informado." |
| Falha de rede / timeout | "Sem conexão com a internet. Tente novamente." |
| Erro genérico (500+) | "Erro ao buscar o CEP. Tente novamente mais tarde." |

- Timeout da requisição: 10 segundos.
- Loading removido imediatamente ao receber qualquer resposta.
- CEP com erro **não** é salvo no histórico.

---

## Ações com o sistema operacional (Inlets)

O app delega ao SO. Não abre mapas internamente.

| Ação | Implementação |
|---|---|
| Abrir localização | `url_launcher` com `geo:0,0?q={endereço}` (Android) / `maps://?q={endereço}` (iOS) |
| Compartilhar | `share_plus` com texto do endereço completo |
| Copiar | `Clipboard.setData()` + Snackbar "Endereço copiado" |

---

## Atividades para implementação

### Setup do projeto
- [ ] Criar projeto Flutter
- [ ] Configurar dependências: `dio`, `hive`, `hive_flutter`, `url_launcher`, `share_plus`, `mask_text_input_formatter` (ou similar)
- [ ] Configurar estrutura de pastas (sugestão: features, core, shared)

### Camada de dados
- [ ] Criar model `CepRecord` com adaptador Hive
- [ ] Implementar repositório local (`CepLocalRepository`): salvar, buscar por CEP, listar ordenado, excluir, contar
- [ ] Implementar serviço de API (`ViaCepService`): GET com tratamento de erros e timeout
- [ ] Implementar caso de uso / controller de busca (verificar cache → API → salvar → retornar)

### Tela Inicial
- [ ] Layout: campo de CEP com máscara, botão de busca, lista de 3 itens, botão "Ver todos"
- [ ] Estado vazio (imagem + texto)
- [ ] Estado de loading durante busca
- [ ] Snackbar para erros
- [ ] Abrir modal ao concluir busca com sucesso
- [ ] Abrir modal ao clicar em item do histórico
- [ ] Lógica de habilitar/desabilitar botão "Ver todos"

### Modal de Endereço
- [ ] BottomSheet com endereço completo
- [ ] Botão "Abrir localização" (url_launcher)
- [ ] Botão "Compartilhar" (share_plus)
- [ ] Botão "Copiar" (clipboard + snackbar de confirmação)

### Tela "Ver Todos"
- [ ] Layout: campo de busca + lista completa
- [ ] Carregar todos os itens do Hive ordenados por timestamp
- [ ] Filtro local por CEP ou endereço
- [ ] Botão de excluir por item
- [ ] Abrir modal ao clicar em item

### Testes mínimos
- [ ] Teste unitário do repositório local (salvar, buscar, excluir, ordenar)
- [ ] Teste unitário do serviço de API (mock de sucesso e erro)
- [ ] Teste unitário do caso de uso de busca (cache hit vs. cache miss)
