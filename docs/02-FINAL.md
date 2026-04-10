# Busca por CEP — Melhorias Incrementais

> Este documento descreve funcionalidades e refinamentos a serem aplicados **após o MVP estar funcional**.
> Cada seção é independente e pode ser implementada isoladamente.
> Deve ser usado como referência para geração de código com Claude Code.

---

## 1. Exclusão com Undo (Snackbar)

**Problema que resolve:** No MVP, a exclusão é imediata e irreversível. Toques acidentais removem dados sem recuperação.

**Comportamento esperado:**
- Ao clicar em excluir, o item é removido visualmente da lista de imediato.
- Um Snackbar aparece na parte inferior com a mensagem "CEP removido" e o botão "Desfazer".
- O Snackbar permanece visível por 5 segundos.
- Se o usuário clicar em "Desfazer", o item é restaurado na mesma posição.
- Se o tempo expirar, a remoção é confirmada e o registro é excluído do banco local.
- Não deve haver diálogo de confirmação prévio — o padrão undo é mais fluido (Material Design).

**Detalhes técnicos:**
- A exclusão do Hive só acontece após o timeout do Snackbar (ou ao navegar para outra tela).
- Durante os 5 segundos, o registro fica em um estado "pendente de exclusão" (pode ser gerenciado via estado local, sem alterar o banco).
- Se o usuário excluir outro item enquanto um Snackbar já está ativo, o Snackbar anterior é descartado e a exclusão pendente é confirmada imediatamente.

### Atividades
- [ ] Refatorar lógica de exclusão para "soft delete" temporário (estado em memória)
- [ ] Implementar Snackbar com ação "Desfazer" e duração de 5 segundos
- [ ] Confirmar exclusão no Hive ao expirar Snackbar ou ao sair da tela
- [ ] Tratar cenário de exclusões consecutivas (descartar Snackbar anterior)
- [ ] Garantir que a lista reflete exclusões pendentes visualmente

---

## 2. Limite máximo do histórico

**Problema que resolve:** Sem limite, o histórico cresce indefinidamente, consumindo armazenamento e degradando performance de listagem.

**Comportamento esperado:**
- O histórico comporta no máximo 100 registros.
- Ao salvar um novo CEP que faria o total ultrapassar 100, o registro com `consultadoEm` mais antigo é removido automaticamente.
- O usuário não é notificado sobre a remoção automática.
- Consultar um CEP já existente (cache hit) não conta como novo registro — apenas atualiza o timestamp.

**Detalhes técnicos:**
- Antes de inserir, verificar `count()`. Se `>= 100`, deletar o registro com menor timestamp.
- Essa lógica deve estar no repositório local, não no controller/UI.

### Atividades
- [ ] Adicionar método `count()` no repositório local
- [ ] Adicionar método `excluirMaisAntigo()` no repositório local
- [ ] Integrar verificação de limite no fluxo de salvamento (antes do `put`)
- [ ] Teste unitário: inserir 101 registros e verificar que o mais antigo foi removido

---

## 3. Paginação e scroll infinito na tela "Ver Todos"

**Problema que resolve:** No MVP, todos os itens são carregados de uma vez. Com 100 registros, isso é aceitável, mas a paginação prepara o app para crescer e melhora a percepção de performance.

**Comportamento esperado:**
- Carregar os primeiros 15 itens ao abrir a tela.
- Ao atingir o final da lista (scroll), carregar os próximos 15.
- Exibir um indicador de loading no rodapé da lista durante o carregamento.
- Parar de carregar quando não houver mais itens.

**Detalhes técnicos:**
- Implementar com `ScrollController` e listener de posição.
- A query no Hive (ou Drift/Isar, caso migre) deve suportar offset e limit.
- O debounce do campo de busca (300ms) deve resetar a paginação ao filtrar.

### Atividades
- [ ] Implementar método `listarPaginado(offset, limit)` no repositório
- [ ] Adicionar `ScrollController` com detecção de final de lista
- [ ] Exibir loading indicator no rodapé durante carregamento
- [ ] Resetar paginação ao digitar no campo de busca
- [ ] Controlar flag `hasMore` para parar de buscar quando não houver mais itens
- [ ] Teste: simular 50 registros e validar que carrega em blocos de 15

---

## 4. Debounce configurável na busca

**Problema que resolve:** Busca sem debounce executa filtragem a cada keystroke, causando processamento desnecessário mesmo em listas locais.

**Comportamento esperado:**
- O campo de busca na tela "Ver todos" aplica debounce de 300ms.
- A filtragem só dispara após o usuário parar de digitar pelo intervalo configurado.
- Durante a digitação contínua, nenhuma filtragem é executada.
- O valor do intervalo é definido como constante, facilmente ajustável.

**Detalhes técnicos:**
- Usar `Timer` do Dart ou pacote `easy_debounce` / `rxdart` com `debounceTime`.
- Definir constante: `const kSearchDebounceMs = 300;`
- Ao limpar o campo (texto vazio), restaurar a lista completa imediatamente (sem debounce).

### Atividades
- [ ] Criar constante `kSearchDebounceMs` em arquivo de configuração
- [ ] Implementar debounce no `onChanged` do campo de busca
- [ ] Garantir que limpeza do campo restaura lista sem debounce
- [ ] Resetar paginação ao filtrar (integração com item 3)
- [ ] Teste: simular digitação rápida e verificar que filtragem dispara apenas uma vez

---

## 5. Geocoding para localização precisa

**Problema que resolve:** No MVP, a URL de localização usa o endereço textual, que pode ser ambíguo (ruas com nomes iguais em cidades diferentes, endereços incompletos).

**Comportamento esperado:**
- Após obter o endereço do ViaCEP, o sistema consulta um serviço de geocoding para obter latitude e longitude.
- As coordenadas são armazenadas no registro do histórico (campos opcionais `latitude` e `longitude`).
- A ação "Abrir localização" usa as coordenadas quando disponíveis, e fallback para endereço textual quando não.
- Se o geocoding falhar, o fluxo continua normalmente (a busca não deve ser bloqueada por falha no geocoding).

**Detalhes técnicos:**
- API sugerida: Nominatim (OSM, gratuita, sem chave) ou Google Geocoding API (paga, mais precisa).
- Nominatim: `https://nominatim.openstreetmap.org/search?q={endereço}&format=json&limit=1`
- Respeitar rate limit do Nominatim (1 req/segundo, User-Agent obrigatório).
- URL com coordenadas: `geo:{lat},{lng}` (Android) / `maps://?ll={lat},{lng}` (iOS).
- O geocoding é executado em paralelo ou logo após a busca do CEP — nunca bloqueando o modal.

**Campos adicionais no model:**
```dart
class CepRecord {
  // ... campos existentes
  final double? latitude;
  final double? longitude;
}
```

### Atividades
- [ ] Adicionar campos opcionais `latitude` e `longitude` no model (migration do Hive)
- [ ] Implementar serviço de geocoding (`GeocodingService`) com Nominatim
- [ ] Chamar geocoding após busca bem-sucedida (não bloqueante)
- [ ] Salvar coordenadas no registro
- [ ] Atualizar lógica de "Abrir localização" para usar coordenadas quando disponíveis
- [ ] Tratamento de erro: falha no geocoding não impede o fluxo
- [ ] Respeitar rate limit (1 req/s para Nominatim)
- [ ] Teste unitário do serviço de geocoding (mock de sucesso, falha, resposta vazia)

---

## 6. Estado vazio da tela "Ver Todos"

**Problema que resolve:** Se o usuário excluir todos os itens enquanto estiver na tela "Ver todos", a tela fica sem conteúdo e sem orientação visual.

**Comportamento esperado:**
- Quando a lista na tela "Ver todos" fica vazia (por exclusões), exibir estado vazio com a mensagem: "Nenhum CEP no histórico".
- O usuário pode navegar de volta à tela inicial normalmente.
- Na tela inicial, o estado vazio padrão (com imagem ilustrativa) é exibido.
- O botão "Ver todos" na tela inicial reflete o estado atualizado (desabilitado se ≤ 3 itens).

### Atividades
- [ ] Criar widget de estado vazio para a tela "Ver todos" (diferente do da Home)
- [ ] Monitorar contagem da lista e exibir estado vazio quando `items.isEmpty`
- [ ] Garantir que ao retornar à Home, o estado do botão "Ver todos" é recalculado
- [ ] Teste: excluir todos os itens na tela e validar exibição do estado vazio

---

## 7. Feedback tátil e animações

**Problema que resolve:** O MVP funciona, mas a experiência é estática. Micro-interações tornam o app mais polido e responsivo.

**Comportamento esperado:**
- Haptic feedback leve ao copiar endereço e ao excluir item.
- Animação de entrada nos itens da lista (fade + slide sutil ao carregar).
- Animação de saída ao excluir item (slide para a direita ou fade out).
- Transição suave ao abrir/fechar o BottomSheet (modal).
- Skeleton loading no lugar do indicador circular durante a busca.

### Atividades
- [ ] Adicionar `HapticFeedback.lightImpact()` nas ações de copiar e excluir
- [ ] Implementar `AnimatedList` para exclusão com animação
- [ ] Adicionar animação de entrada nos itens (staggered fade-in)
- [ ] Criar widget de skeleton loading para o estado de carregamento
- [ ] Revisar transição do BottomSheet (curva e duração)

---

## 8. Testes de integração e widget tests

**Problema que resolve:** O MVP cobre apenas testes unitários. Testes de integração garantem que os fluxos completos funcionam de ponta a ponta.

### Atividades
- [ ] Widget test da tela inicial: verificar estado vazio, lista com itens, botão desabilitado/habilitado
- [ ] Widget test do modal: verificar exibição do endereço e presença dos 3 botões de ação
- [ ] Widget test da tela "Ver todos": verificar filtragem, exclusão, scroll
- [ ] Teste de integração: fluxo completo de busca → modal → copiar
- [ ] Teste de integração: fluxo de busca com cache hit (sem chamada de API)
- [ ] Teste de integração: fluxo de exclusão com undo
- [ ] Mock da API para testes (interceptor do Dio ou `http_mock_adapter`)

---

## Ordem sugerida de implementação

| Prioridade | Item | Justificativa |
|---|---|---|
| 1 | Exclusão com Undo | Previne perda de dados, baixo esforço |
| 2 | Limite do histórico | Previne crescimento descontrolado |
| 3 | Debounce configurável | Melhora performance da busca |
| 4 | Estado vazio "Ver Todos" | Corrige edge case de UX |
| 5 | Paginação e scroll infinito | Performance com muitos registros |
| 6 | Testes de integração | Qualidade e confiança no código |
| 7 | Feedback tátil e animações | Polimento de experiência |
| 8 | Geocoding | Funcionalidade adicional, depende de API externa |

---

## Notas para Claude Code

- Cada seção deste documento pode ser passada isoladamente como contexto para geração de código.
- Referenciar o `01-MVP.md` como base — as melhorias pressupõem que o MVP já está implementado.
- Ao implementar cada item, atualizar os testes existentes para cobrir o novo comportamento.
- Manter a mesma estrutura de pastas e padrões definidos no MVP.
