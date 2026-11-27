# Contrato SDUI v1 — kanvas → sd_widget

O kanvas exporta telas como JSON que o [sd_widget](https://github.com/thim/sd_widget)
renderiza em Flutter. Este diretório é a **fonte da verdade** desse formato; o sd_widget
guarda uma cópia em `test/contract/sdui/v1/` e roda os mesmos exemplos nos testes dele.

| Arquivo | O que é |
|---|---|
| `schema.json` | JSON Schema (draft 2020-12) de todos os nós e propriedades |
| `fixtures/*.json` | Exemplos — cada tipo e cada recurso planejado aparece em pelo menos um |
| `fixtures/manifest.json` | Para cada exemplo: tipos usados, recursos planejados e status. **Gerado**, não edite à mão |

## Formato

Cada nó é `{"type": "<tipo>", "data": {…}}` — exatamente o que o `defaultWidget()` do
sd_widget já entende. A raiz pode ser um nó ou uma lista de nós. Só a raiz pode ter, além
disso, `"sdui": 1` (versão) e `"meta"` (origem, arquivo, frame, avisos do exportador); o
sd_widget ignora chaves além de `type`/`data`, então isso não quebra nada.

```json
{"sdui": 1, "meta": {"source": "kanvas", "name": "Tela inicial"},
 "type": "column", "data": {"spacing": 16, "children": [
   {"type": "text", "data": {"text": "Olá", "fontSize": 28, "fontWeight": 700}}
 ]}}
```

### Convenções

- **Unidades**: 1 px do kanvas = 1 dp (pixel lógico) do Flutter.
- **Cores**: `#RGB`, `#RRGGBB` ou `#AARRGGBB` — alfa **primeiro**, como no Flutter
  (`Color(0xAARRGGBB)`). O kanvas converte do RGBA interno ao exportar.
- **Tamanhos** (`width`, `height`): número ≥ 0 ou `"infinity"` (ocupa o espaço disponível).
- **Espaçamentos** (`padding`, `margin`): número, `[horizontal, vertical]`,
  `[esquerda, topo, direita, base]` ou `{left, top, right, bottom}`.
- **Ações** (`button`, `tap`): `type` é `push_named`, `open_webview`, `open_url`, `pop` ou
  `custom` — os nomes que o `SDActionType` realmente lê (o README do sd_widget cita
  `push_webview`/`push_external`, que caem em `custom`). `event` opcional com `name` e `metadata`.
- **Chaves desconhecidas são erro** no schema: pega erro de digitação no exportador. A
  única exceção é `item_data`, que o próprio sd_widget injeta em listas.

## Status dos recursos

Todo o v1 é suportado pelo sd_widget (fase 1). Os exemplos têm status `current` e rodam
nos testes do sd_widget.

`"x-status": "planned"` continua disponível para recursos novos: marque no schema o que o
sd_widget **ainda não** suporta. O exemplo que usa o recurso fica `planned` no manifesto e
pulado nos testes do sd_widget; ao implementar, remova a marca e regenere o manifesto.

Comportamento de `decoration`: sem `borderColor` e sem `width` não há borda (antes da
fase 1 o sd_widget sempre desenhava uma borda preta de 1 px).

## Como o kanvas vai mapear (fase 2)

| kanvas | SDUI |
|---|---|
| Frame com auto-layout coluna/linha | `container` (tamanho, fundo, raio, borda, padding, `clip`) + `column`/`row` com `spacing`, alinhamentos e `mainAxisSize` (*Abraçar* → `min`) |
| Frame sem auto-layout | `container` + `stack`, filhos em `positioned` (aviso: não se adapta a telas de outros tamanhos) |
| Filho *Preencher* no eixo principal | `expanded` |
| Filho *Preencher* no eixo cruzado | `crossAxisAlignment: stretch` no pai, ou `sized_box` com `"infinity"` |
| Retângulo / elipse | `container` com `decoration` (`shape: circle` na elipse) |
| Texto | `text` com estilo explícito (fonte, tamanho, peso, alinhamento, altura de linha) |
| Imagem | `image` com a URL pública do asset |
| Path | `svg` gerado pelo crate `kanvas-svg` |
| Opacidade < 1 / rotação ≠ 0 | `opacity` / `rotate` em volta do nó |
| Item com ação (painel *Exportar*) | `tap` em volta do nó, ou `button` se o papel for "botão nativo" |
| Instância de componente | v1: conteúdo copiado no lugar; templates com `ref` ficam para depois |
| Oculto | não exportado |

O que não tiver equivalente (gradiente, várias camadas de preenchimento, borda
interna/externa…) vira um aviso em `meta.warnings`, nunca um JSON inválido.

## Evoluindo o contrato

1. Edite `schema.json` e/ou adicione um exemplo em `fixtures/`.
2. Regenere o manifesto: `cargo run -p kanvas-sdui --example manifest`.
3. `cargo test -p kanvas-sdui` confere: exemplos válidos, manifesto correto e todo tipo e
   recurso planejado coberto por algum exemplo.
4. No sd_widget: `tool/sync_contract.sh <ref>` copia esta pasta e os testes rodam os
   exemplos `current`.

Mudanças incompatíveis viram `v2/` (e `"sdui": 2`); o v1 continua sendo aceito.
