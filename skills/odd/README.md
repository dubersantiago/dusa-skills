# ODD — Organic Driven Development

Adaptación portable (Claude Code, Codex, Cursor…) de **Organic Driven Development**, el flujo de trabajo de [Gentle Shell](https://github.com/Gentleman-Programming/gentle-shell), creado por Alan Buscaglia (Gentleman Programming) y publicado con licencia MIT. Esta adaptación no es oficial ni está respaldada por ese proyecto. Fuente usada: el protocolo de `contracts/review-provider-contract-mirror/v1.4.0/bundle/routing/pi.md`, `docs/readme-reference.md` y la skill `work-unit-commits` (commit `f4cc69a`, 2026-11-09).

## La idea

Toda solicitud entra en el flujo, sin pedirlo. El trabajo crece de forma orgánica: lo pequeño se queda pequeño y solo lo que no se puede retomar desde el diff gana estructura.

```text
Autorizar → Explorar → Resolver incertidumbre → Clasificar ─┬─ pequeño ─────────────────────┬─→ Implementar tarea a tarea → Cerrar con evidencia
                                                            └─ grande → Registrar (1 doc) ───┘
```

| | Pequeño | Grande |
|---|---|---|
| Cuándo | Entendido + riesgo contenido + reanudable con el pedido y `git diff` | Falla la prueba de reanudación (varias sesiones, espera externa, requisitos largos) |
| Documento | Ninguno | `docs/odd/tasks/<feature>.md`: Specs literales, Tasks, Log |
| Commits | Solo si los pides | Por unidad de trabajo (~400 líneas por porción, heurística) |
| Delegación | Ninguna | Solo si un disparador se cumple de verdad |

## Diferencias con SDD (del mismo repo)

| | `sdd` | `odd` |
|---|---|---|
| Arranque | Todo trabajo pasa por spec + plan aprobados | Solo el trabajo grande lleva documento; lo pequeño va directo |
| Control | Aprobación del plan, autorización y aprobación por tarea | Una autorización inicial del cambio; preguntas solo ante decisiones reales |
| Pausa | Obligatoria tras cada tarea | Continúa tarea a tarea hasta cerrar o hasta "Necesita tu decisión" |
| Commits | Siempre el usuario | El agente, por unidad de trabajo (configurable) |
| Registro | Bitácora exhaustiva de eventos | Log breve; las specs citan literal al usuario |

Usa `sdd` cuando quieras control paso a paso (zonas sensibles, equipos que revisan cada tarea) y `odd` para el trabajo diario.

## Qué se adaptó respecto al original

| Original (Gentle Shell) | Aquí |
|---|---|
| Espejo del documento en memoria Engram | Opcional: solo si hay una herramienta de memoria disponible |
| Revisión nativa RDD (`gentle-ai review assess`, consentimiento por candidato) | No incluida. Los cambios de alto riesgo llevan un verificador independiente (subagente) |
| Etiqueta de fase `gentle_odd_phase` y modos de Pi | No incluidos |
| Skills `work-unit-commits` y `chained-pr` | Resumidas en `references/entrega.md` |
| Commits del agente por unidad de trabajo | Igual por defecto; `Commits: usuario` en `docs/odd/config.md` para hacerlos tú |

## Uso

```bash
npx skills add <usuario>/dusa-skills --skill odd -a claude-code
```

Como ODD debe correr en **cada** solicitud, agrega esto al `CLAUDE.md` / `AGENTS.md` del proyecto:

```markdown
## Flujo de trabajo
Usa la skill `odd` (Organic Driven Development) en toda solicitud. Configuración en `docs/odd/config.md`; documentos de feature en `docs/odd/tasks/`.
```

Opcional: copia `odd/templates/config-template.md` de la skill a `docs/odd/config.md` del proyecto (TDD, runner, política de commits, estrategia de entrega, áreas de alto riesgo).

## Archivos

| Archivo | Contenido |
|---|---|
| `odd/SKILL.md` | Protocolo de 7 pasos, tamaño, alto riesgo, línea de riesgo, documento de feature |
| `odd/references/delegacion.md` | Disparadores de delegación y prompts de escritor, explorador y verificador |
| `odd/references/pruebas.md` | TDD, qué testear, comparación diferencial, scratch |
| `odd/references/entrega.md` | Commits por unidad de trabajo, presupuesto, estrategias de PR |
| `odd/templates/feature-template.md` | Plantilla de `docs/odd/tasks/<feature>.md` |
| `odd/templates/config-template.md` | Plantilla de `docs/odd/config.md` |
