# Plano: separar o dado do layout

Hoje o JSON SDUI que o kanvas exporta traz estrutura e conteúdo juntos: textos,
valores e itens de lista ficam dentro dos nós. Isso tem três custos.

- **Download.** Qualquer mudança de conteúdo (saldo, nome, extrato) obriga a baixar a
  tela inteira de novo. O conteúdo muda a cada abertura, então o cache de layout quase
  nunca acerta.
- **Renderização.** Um conteúdo novo vira um layout novo. O `SDLayoutView` analisa o JSON
  de novo e reconstrói a árvore toda, mesmo que só um número tenha mudado.
- **Publicação.** Para trocar um texto de produção é preciso republicar a tela. Para
  mostrar dados do usuário, o backend teria de gerar o JSON de layout por usuário, sem
  aproveitar CDN nem cache.

A proposta é tratar o **layout** como um modelo imutável e versionado, que se baixa
raramente e se analisa uma vez. O **dado** vira um documento pequeno, com ciclo de vida
próprio. O sd_widget junta os dois na hora de desenhar.

## Onde estamos

| Peça | Estado |
|---|---|
| Contrato SDUI v1 (schema, exemplos, testes nos dois repositórios) | feito (fases 0 e 1) |
| Exportador kanvas → SDUI, painel *Exportar SDUI*, rota no worker | feito (fases 2 e 3) |
| Cache de layout no sd_widget (`SDLayoutRepository` e `SDLayoutView`) | **este PR** |
| Placeholders `$campo` com `item_data` (só dentro de listas) | existe, limitado |

Medidas na tela exportada pelo kanvas (fixture 20):

| Formato | Tamanho |
|---|---|
| JSON formatado | 13,4 KB |
| JSON compacto | 4,0 KB |
| JSON compacto sem `meta` | 3,9 KB |
| Com gzip | **0,9 KB** |

Com isso, o tamanho do layout em si não é o problema. O que pesa é:

1. **Idas e voltas à rede.** Mesmo com 304, cada abertura de tela espera uma resposta.
2. **O dado, que muda sempre.** Hoje ele arrasta o layout junto.
3. **As imagens.**
4. **O trabalho de análise e reconstrução no aparelho.**

O plano ataca nessa ordem.

## Visão geral

```
                 publicação (kanvas)                         app (sd_widget)
 ┌───────────┐   ┌──────────────────────────────┐   ┌───────────────────────────────┐
 │  editor   │──▶│ R2 / CDN                     │──▶│ SDLayoutRepository            │
 │ (tela +   │   │  manifest.json   (curto, ETag)│   │  memória → disco → rede       │
 │  vínculos)│   │  layouts/<hash>.json (imutável)│   │  layout analisado 1x por hash │
 └───────────┘   │  components/<hash>.json       │   └──────────────┬────────────────┘
                 │  assets/<hash>.<ext>          │                  │ junta
                 └──────────────────────────────┘   ┌──────────────▼────────────────┐
 ┌───────────┐                                     │ SDDataScope (dado da tela)    │
 │ backend   │────── GET /dados/home  (TTL curto) ─▶│  só os widgets vinculados     │
 │ do app    │                                     │  ao caminho que mudou rebuildam│
 └───────────┘                                     └───────────────────────────────┘
```

## 1. Contrato: o que muda no JSON

Todas as mudanças são **aditivas**: novos campos com `"x-status": "planned"` até o
sd_widget suportar. Um layout que usa vínculos declara isso em `requires`, para que um
app antigo recuse o layout em vez de mostrar `$saldo` na tela.

### 1.1 Vínculo (`bind`)

Qualquer propriedade de texto ou valor pode apontar para um caminho no documento de dados:

```json
{ "type": "text", "data": { "text": { "bind": "conta.saldo", "format": "moeda", "fallback": "—" }, "fontSize": 28 } }
```

- `bind`: o caminho no dado, com pontos e índices (`extrato.0.valor`).
- `format` (opcional): um formatador registrado no app. Por exemplo `moeda`, `data` ou
  `porcentagem`, sempre com a localidade do aparelho.
- `fallback` (opcional): o que aparece se o caminho não existir. Isso permite
  publicar um layout antes do backend.
- A string simples continua valendo. O `$campo` atual vira um atalho de `{"bind": "campo"}`
  dentro de listas.

Também podem receber vínculo `visible` (mostrar ou esconder) e `url` de imagem.
Propriedades visuais (cor, tamanho) só recebem vínculo numa fase posterior, se surgir
necessidade, para não transformar o layout em linguagem de programação.

### 1.2 Repetição (`repeat`)

Listas vindas do dado:

```json
{ "type": "repeat", "data": { "source": "extrato", "direction": "column", "spacing": 8,
  "lazy": true, "item": { "type": "list_tile", "data": { "title": { "bind": "item.descricao" } } } } }
```

- Dentro de `item`, `item.*` aponta para o elemento atual da lista e `index` para a posição dele.
- Com `lazy: true`, a lista é montada sob demanda (`ListView.builder`). Isso substitui o
  `list_builder` com `ListBuilder` em código.

### 1.3 Componentes compartilhados (`ref`)

Instâncias de componentes do kanvas (botões, cartões, linhas de extrato) deixam de ser
copiadas em cada tela:

```json
{ "type": "ref", "data": { "component": "botao-primario@a1b2c3", "overrides": { "label": { "bind": "acao.titulo" } } } }
```

Os componentes ficam em `components/<hash>.json`, baixados uma vez e reaproveitados entre
telas. Os `overrides` usam as mesmas chaves dos overrides do kanvas (`PropKey`), e o
override de conteúdo de texto já existe lá.

### 1.4 Envelope e manifesto

O layout publicado leva uma raiz mais rica e sai sem `meta.warnings` nem `exportedAt`, que
mudariam o hash:

```json
{ "sdui": 1, "requires": ["bind", "repeat"], "data": { "schema": "home@3" }, "type": "...", "data": {...} }
```

`data.schema` nomeia a forma do dado esperado. O backend do app e o kanvas compartilham
essa definição (fase 4.3).

O manifesto é pequeno e é a única coisa revalidada com frequência:

```json
{ "version": 42, "screens": { "home": "layouts/9f3c.json", "perfil": "layouts/77aa.json" },
  "components": "components/1d2e.json", "minClient": 3 }
```

## 2. Publicação e download

| Recurso | URL | Cache-Control | No app |
|---|---|---|---|
| Manifesto | `/sdui/<app>/manifest.json` | `max-age=60, stale-while-revalidate=86400` + ETag | revalidado na abertura do app e quando ele volta ao primeiro plano |
| Layout | `/sdui/<app>/layouts/<hash>.json` | `max-age=31536000, immutable` | `SDLayoutRepository` com `maxAge` infinito: hash novo é URL nova |
| Componentes | `/sdui/<app>/components/<hash>.json` | `immutable` | idem; um arquivo para todas as telas |
| Imagens | `/sdui/<app>/assets/<hash>.<ext>` | `immutable` | `precacheImage` das imagens da próxima tela |
| Dado | API do app (`/dados/home`) | do backend (`no-cache` ou TTL curto) + ETag | `SDDataRepository` com política própria |

Consequências:

- **Abrir uma tela já vista não vai à rede** para o layout. Só o manifesto é revalidado,
  uma vez para todas as telas. Isso elimina a ida e volta por tela que o cache atual
  ainda faz quando o cache venceu.
- **Publicar uma tela nova** gera um hash novo e um manifesto novo. Os apps descobrem a
  mudança na próxima revalidação e baixam só os arquivos novos, em segundo plano
  (`prefetch`).
- **Rollback** é trocar o manifesto de volta: os arquivos antigos continuam no R2.
- **Compressão.** JSON compacto, com gzip ou brotli no Cloudflare, sai em cerca de
  1 KB por tela. Não vale inventar chaves curtas ou um formato binário antes de medir.
- O `minClient` do manifesto impede que um app antigo carregue telas que dependem de
  recursos novos. Esse app continua com o último manifesto compatível em cache.

## 3. Renderização no sd_widget

1. **Analisar uma vez por hash.** Hoje cada `JsonViewDataBuilder` tem `args` mutáveis, e
   `item_data` é gravado dentro do mapa. Esses nós passam a ser **imutáveis**
   (`SDNode(type, props, children)`), criados uma vez por hash e compartilhados entre
   montagens da mesma tela. O `SDLayoutView` já guarda a árvore por versão; o próximo
   passo é guardá-la no repositório, entre telas.
2. **Dado reativo por caminho.** Um `SDDataScope` (um `InheritedModel<String>` cujo
   aspecto é o caminho) envolve a tela. Um widget vinculado a `conta.saldo` se registra
   só nesse aspecto. Quando chega um dado novo, o escopo compara os valores por caminho e
   **só os widgets cujo caminho mudou são reconstruídos**. O layout não é reanalisado.
3. **Listas preguiçosas.** O `repeat` com `lazy` usa `ListView.builder`/`SliverList` e
   chaves por item (`key` ou `index`), para que inserir um item no extrato não refaça os
   outros.
4. **Primeiro frame sem rede.** Com o layout e o último dado em disco, a tela abre já
   preenchida. O dado novo chega e só os campos que mudaram são atualizados. Sem dado em
   cache, os campos mostram o `fallback`, ou um esqueleto opcional por vínculo
   (`"skeleton": true`).

## 4. Mudanças por repositório

### kanvas

- **4.1 Vínculos no editor.**
  - No painel *Exportar*, um texto pode ser marcado como "vinculado a dado", com
    caminho, formato e fallback.
  - Um frame com auto-layout pode ser marcado como "repetir com", com a fonte; o primeiro
    filho vira o modelo do item.
  - Isso exige um campo novo no `Shape`, com op e inverso, como os outros campos.
- **4.2 Dados de exemplo.** Cada arquivo guarda um JSON de exemplo por tela. O editor
  mostra os textos vinculados com esses valores e repete o modelo do item pelo tamanho da
  lista. É assim que o designer vê a tela real.
- **4.3 Schema do dado.**
  - O exportador gera, a partir dos vínculos, o schema do dado esperado (por exemplo
    `home@3`: `conta.saldo: number`, `extrato[]: {descricao, valor}`).
  - Esse schema é publicado junto com o layout.
  - O backend do app valida a resposta contra ele no CI, o que pega quebra de contrato
    antes de produção.
- **4.4 Publicar.**
  - Novo `POST /api/files/:id/publish`: exporta as telas marcadas, calcula os hashes e
    grava layouts, componentes, assets e manifesto no R2 sob uma rota pública.
  - É a fase 4 já planejada; resolve também o Cloudflare Access na frente das rotas.
- **4.5 `ref` no exportador.** Uma instância de componente vira `ref` com os overrides do
  kanvas. O componente principal entra no pacote de componentes.

### sd_widget

- **4.6** Manter o `SDLayoutRepository` deste PR e acrescentar:
  - a leitura do manifesto;
  - `maxAge` infinito para URLs com hash;
  - `prefetch` das telas do manifesto.
- **4.7** `SDDataRepository`: a mesma mecânica de cache e ETag, com política por tela
  (ex.: `networkFirst` com timeout de 800 ms e cache como fallback).
- **4.8** `SDNode` imutável, `bind`, `repeat`, `ref`, `SDDataScope` e formatadores
  registráveis (`registry.addFormatter('moeda', ...)`).
- **4.9** Remover o `dart:io` de `sd_data.dart`, que quebra o Flutter Web. O `loadZip`
  passa para um import condicional; o gzip, na prática, fica a cargo do HTTP.

## 5. Fases

| Fase | Entrega | Critério de pronto |
|---|---|---|
| **A** | Cache de layout (este PR) | Tela vista abre sem rede; layout quebrado ou de versão desconhecida não substitui o bom |
| **B** | Publicação com hash e manifesto (kanvas 4.4 + sd_widget 4.6) | Segunda abertura de qualquer tela faz 0 requisições de layout; rollback por manifesto |
| **C** | `bind` + `SDDataScope` + `SDDataRepository` (contrato 1.1, kanvas 4.1–4.2, sd_widget 4.7–4.8) | Atualizar o saldo reconstrói só o widget do saldo (teste conta builds) |
| **D** | `repeat` lazy + schema do dado (1.2, 4.3) | Extrato de 1000 itens monta só o que está na tela; CI do backend valida contra `home@N` |
| **E** | `ref` e pacote de componentes (1.3, 4.5) | Componente usado em N telas é baixado uma vez |
| **F** | Medição e ajustes | Ver métricas abaixo |

A ordem é intencional. **B** já tira a rede do caminho da abertura, sem mudar o contrato.
**C** é a separação de fato e depende do editor saber vincular.

## 6. Métricas

Instrumentadas via `SDLayoutView.onLayout` (origem e idade do cache) e um callback
equivalente no dado:

- Taxa de acerto do cache de layout (memória, disco ou rede) e idade média do que é mostrado.
- Tempo até o primeiro frame com conteúdo, com e sem cache.
- Bytes por abertura de tela, separados em layout, dado e imagens.
- Rebuilds por atualização de dado (meta: proporcional aos campos que mudaram).
- Layouts recusados (`SDLayoutException`) por versão do app, para saber quando é seguro
  usar um recurso novo do contrato.

## 7. Riscos e decisões em aberto

- **Dado e layout fora de sincronia.** Um layout novo pode esperar campos que o backend
  ainda não manda. Mitigação: `fallback` obrigatório no editor para vínculos novos,
  `data.schema` versionado e validação no CI do backend.
- **Até onde vai a lógica no layout.** Formatadores e `visible` cobrem a maior parte dos
  casos. Condições compostas e cálculos ficam no backend, que já entrega o dado pronto
  para exibir. Isso evita transformar o SDUI em linguagem de programação.
- **Dado sensível em cache.** O dado (saldo, extrato) não pode ir para o mesmo
  armazenamento do layout. O `SDDataRepository` recebe um `SDLayoutStore` próprio, que o
  app pode ligar a armazenamento criptografado e limpar no logout.
- **Hash e conteúdo dinâmico do kanvas.** `exportedAt` e `warnings` saem do layout
  publicado, ou o hash mudaria a cada exportação. Ficam num relatório de publicação à
  parte.
- **Tamanho do cache em disco.** `KeyValueLayoutStore` sobre `shared_preferences` serve
  para dezenas de telas. Acima disso, o app deve usar um store em arquivos ou Hive. A
  interface já permite isso.
