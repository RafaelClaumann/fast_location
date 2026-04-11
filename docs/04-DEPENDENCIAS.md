# Gerenciamento de Dependências no Flutter

> Para quem vem do ecossistema Java/Maven/Gradle.

---

## O que é o `pubspec.yaml`?

É o equivalente ao `pom.xml` (Maven) ou `build.gradle` (Gradle). Ele centraliza metadados do projeto e a lista de dependências.

```yaml
name: fast_location
description: Aplicativo de localização rápida.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## Qual é o repositório de pacotes?

O repositório central é o [pub.dev](https://pub.dev), equivalente ao Maven Central ou ao npm registry. Todos os pacotes públicos do ecossistema Dart/Flutter ficam lá.

---

## Como adicionar uma dependência?

**Opção 1 — via CLI (recomendado):**

```bash
flutter pub add nome_do_pacote
```

Isso edita o `pubspec.yaml` automaticamente e já executa o download.

**Opção 2 — manualmente:**

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  nome_do_pacote: ^1.0.0
```

Depois execute:

```bash
flutter pub get
```

> Equivalente a rodar `mvn install` ou `gradle build` após editar o `pom.xml`.

---

## Como remover uma dependência?

```bash
flutter pub remove nome_do_pacote
```

Ou remova manualmente a linha do `pubspec.yaml` e rode `flutter pub get`.

---

## Como atualizar dependências?

**Atualizar tudo (respeitando as restrições de versão do `pubspec.yaml`):**

```bash
flutter pub upgrade
```

**Atualizar um pacote específico:**

```bash
flutter pub upgrade nome_do_pacote
```

**Atualizar além das restrições declaradas (com cuidado):**

```bash
flutter pub upgrade --major-versions
```

> Equivalente ao `mvn versions:use-latest-releases`.

---

## O que é o `pubspec.lock`?

É o equivalente ao `package-lock.json` ou ao `gradle.lockfile`. Ele registra as versões exatas resolvidas de todas as dependências (diretas e transitivas), garantindo builds reproduzíveis.

- **Commite o `pubspec.lock`** em projetos de aplicativo (garante consistência entre a equipe).
- **Não commite o `pubspec.lock`** em pacotes/bibliotecas publicadas (deixe o consumidor resolver as versões).

---

## Como funcionam os ranges de versão?

| Sintaxe         | Significado                                      | Equivalente Maven       |
|-----------------|--------------------------------------------------|-------------------------|
| `^1.2.0`        | `>=1.2.0 <2.0.0` (compatível com semver)         | `[1.2.0, 2.0.0)`       |
| `>=1.2.0 <2.0.0`| Range explícito                                  | `[1.2.0, 2.0.0)`       |
| `1.2.0`         | Versão exata                                     | `[1.2.0]`              |
| `any`           | Qualquer versão (evite)                          | `[0.0.0,)`             |

---

## O que são `dependencies` vs `dev_dependencies`?

| Seção              | Uso                                              | Equivalente Maven       |
|--------------------|--------------------------------------------------|-------------------------|
| `dependencies`     | Pacotes usados em produção                       | `<scope>compile</scope>`|
| `dev_dependencies` | Apenas em desenvolvimento/testes                 | `<scope>test</scope>`   |

---

## Como verificar pacotes desatualizados?

```bash
flutter pub outdated
```

Exibe uma tabela com a versão atual, a versão resolvida e a versão mais recente disponível para cada dependência.

---

## Dependências locais e do Git

**Pacote local (path):**

```yaml
dependencies:
  meu_pacote:
    path: ../meu_pacote
```

**Pacote direto do GitHub:**

```yaml
dependencies:
  meu_pacote:
    git:
      url: https://github.com/usuario/meu_pacote.git
      ref: main  # branch, tag ou commit
```

---

## Resumo de comandos

| Comando                        | O que faz                                      |
|-------------------------------|------------------------------------------------|
| `flutter pub get`             | Baixa as dependências declaradas               |
| `flutter pub add <pacote>`    | Adiciona e baixa um novo pacote                |
| `flutter pub remove <pacote>` | Remove um pacote                               |
| `flutter pub upgrade`         | Atualiza dependências respeitando os ranges    |
| `flutter pub outdated`        | Lista pacotes com versões mais recentes        |
| `flutter pub deps`            | Exibe a árvore de dependências transitivas     |
