# FastLocation — Checklist de Desenvolvimento

> App de consulta de CEP e endereços para entregadores da FastDelivery

| Prazo | Nota |
|-------|------|
| 14/04/2026 até 23h59 (Brasília) | 100% |
| 15/04/2026 até 23h59 (Brasília) | 60% |

---

## 01 — Criando o projeto

- [ ] Criar o projeto básico em Flutter
- [ ] Remover a implementação de exemplo gerada automaticamente
- [ ] Remover código para demais plataformas (manter somente Android e iOS)
- [ ] Refatorar o método `main()`

---

## 02 — Instalando as libs do projeto

### Dependências do app

- [ ] `dio: ^4.0.6`
- [ ] `flutter_mobx: ^2.0.4`
- [ ] `mobx: ^2.0.6+1`
- [ ] `hive: ^2.1.0`
- [ ] `hive_flutter: ^1.1.0`
- [ ] `path: ^1.8.0`
- [ ] `path_provider: ^2.0.2`
- [ ] `path_provider_android: ^2.0.14`
- [ ] `path_provider_ios: ^2.0.9`
- [ ] `map_launcher: ^2.2.1+1`
- [ ] `geocoding: ^2.1.1`

### Dependências de desenvolvimento (dev)

- [ ] `mobx_codegen: ^2.0.1+3`
- [ ] `build_runner: ^2.0.5`
- [ ] `hive_generator: ^2.0.0`

---

## 03 — Criando as estruturas compartilhadas

- [ ] Criar diretório `lib/src/shared/` com os subdiretórios:
    - [ ] `colors/` — classe com as cores usadas no app
    - [ ] `components/` — componentes compartilhados entre módulos
    - [ ] `metrics/` — constantes de valores de espaçamentos
    - [ ] `storage/` — configuração e classes de armazenamento local
- [ ] Criar diretório `lib/src/routes/` — classe com constantes de nomes de rotas das telas
- [ ] Criar diretório `lib/src/http/` — classe de configuração do Dio para comunicação HTTP

---

## 04 — Criando a página de abertura

- [ ] Criar diretório `lib/src/modules/initial/page/`
- [ ] Criar classe da tela de inicialização (splash screen):
    - [ ] Implementar redirecionamento automático para a home
    - [ ] Implementar animação da tela de abertura

---

## 05 — Criando o módulo Home

- [ ] Criar subdiretórios: `components/`, `controller/`, `model/`, `page/`, `repositories/`, `service/`

### model/
- [ ] Criar classe com a estrutura de dados para retorno da API externa (`https://viacep.com.br/ws`)

### repositories/
- [ ] Criar classe de comunicação com a API externa (ViaCEP)
- [ ] Criar classe de comunicação com o armazenamento local (Hive)

### service/
- [ ] Criar classe com as regras de negócio e orquestração dos repositórios

### controller/
- [ ] Criar classe MobX para controle da página e uso dos services

### components/
- [ ] Criar componente de lista de endereços consultados
- [ ] Criar componente do último endereço consultado
- [ ] Criar componente de estado vazio (empty state) para buscas sem resultado

### page/
- [ ] Criar página com gerenciamento de estado:
    - [ ] Integrar o controller criado
    - [ ] Usar o widget `Observer` do MobX Flutter para reatividade na tela
    - [ ] Usar reações do MobX para tratar cenários de erro nas consultas
    - [ ] Implementar ação: nova consulta de CEP
    - [ ] Implementar ação: acesso ao histórico (navegação para nova página)
    - [ ] Implementar ação: traçar rota com o último endereço consultado

---

## 06 — Criando o módulo History

- [ ] Criar subdiretórios: `controller/`, `page/`

### controller/
- [ ] Criar classe MobX para controle da página e carregamento dos dados históricos do armazenamento local

### page/
- [ ] Criar página com gerenciamento de estado:
    - [ ] Integrar o controller criado
    - [ ] Usar o widget `Observer` do MobX Flutter para reatividade na tela
    - [ ] Carregar os dados históricos automaticamente ao acessar a página

---

## Resultado esperado (critérios de aceite)

- [ ] Comunicação com a API pública para consulta de CEP e endereços
- [ ] Armazenamento local para consultas recorrentes
- [ ] Gerenciamento de estado com interfaces reativas
- [ ] Componente com campos para consulta de CEP
- [ ] Componente com exibição dos dados consultados
- [ ] Tela de loading durante consultas externas
- [ ] Componente para resultados não encontrados
- [ ] Tela de histórico de endereços consultados
- [ ] Ação para traçar rota da localização atual até o último endereço consultado

---

## Entrega

1. [ ] Criar repositório remoto (ex: GitHub)
2. [ ] Publicar o código no repositório
3. [ ] Incluir instruções de execução no README
4. [ ] Entregar o link do repositório no AVA
